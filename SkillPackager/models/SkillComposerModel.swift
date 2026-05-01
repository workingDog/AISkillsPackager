//
//  SkillComposerModel.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI
import Observation



@Observable
@MainActor
final class SkillComposerModel {
    var library: [SkillDefinition] = []
    var selectedSkillIDs: Set<UUID> = []
    var package = SkillPackage()
    
    @ObservationIgnored
    private let parser = SkillMarkdownParser()

    var graphNodes: [SkillGraphNode] = []
    var edges: [SkillEdge] = []

    var dragStartPort: PortHandle?
    var dragCurrentPoint: CGPoint?
    var hoveredInputPort: PortHandle?

    var validationIssues: [EdgeValidationIssue] = []
    
    var portFrames: [PortHandle: CGRect] = [:]
    
    var selectedProvider: ExportProvider = .openAIResponses

    var exportDocument = ExportPayload(data: Data())
    var exportSuggestedFilename = "skill-package.json"

    
    init() {
        self.library = SkillDefinition.samples
    }

    func registerPortFrame(_ handle: PortHandle, frame: CGRect) {
        portFrames[handle] = frame
    }

    func portFrame(for handle: PortHandle) -> CGRect? {
        portFrames[handle]
    }

    func skill(for id: UUID) -> SkillDefinition? {
        library.first(where: { $0.id == id })
    }

    func node(for skillID: UUID) -> SkillGraphNode? {
        graphNodes.first(where: { $0.skillID == skillID })
    }

    func inputPort(skillID: UUID, portID: UUID) -> SkillPort? {
        skill(for: skillID)?.declaredInputs.first(where: { $0.id == portID })
    }

    func outputPort(skillID: UUID, portID: UUID) -> SkillPort? {
        skill(for: skillID)?.declaredOutputs.first(where: { $0.id == portID })
    }

    func port(handle: PortHandle) -> SkillPort? {
        switch handle.side {
        case .input:
            inputPort(skillID: handle.skillID, portID: handle.portID)
        case .output:
            outputPort(skillID: handle.skillID, portID: handle.portID)
        }
    }

    func rebuildGraph() {
        let ordered = package.skills.sorted { $0.executionOrder < $1.executionOrder }

        graphNodes = ordered.enumerated().map { index, item in
            let existing = graphNodes.first(where: { $0.skillID == item.skillID })
            let column = index % 4
            let row = index / 4

            return SkillGraphNode(
                id: existing?.id ?? UUID(),
                skillID: item.skillID,
                title: item.displayName,
                position: existing?.position ?? GraphPoint(
                    x: 220 + Double(column) * 320,
                    y: 160 + Double(row) * 240
                )
            )
        }

        validateEdges()
    }

    func beginEdgeDrag(from handle: PortHandle, at point: CGPoint) {
        guard handle.side == .output else { return }
        dragStartPort = handle
        dragCurrentPoint = point
        hoveredInputPort = nil
    }

    func updateEdgeDrag(point: CGPoint, hoveredInput: PortHandle?) {
        dragCurrentPoint = point
        hoveredInputPort = hoveredInput
    }

    func endEdgeDrag(over inputHandle: PortHandle?) {
        defer {
            dragStartPort = nil
            dragCurrentPoint = nil
            hoveredInputPort = nil
        }

        guard let start = dragStartPort,
              let target = inputHandle,
              start.side == .output,
              target.side == .input,
              start.skillID != target.skillID
        else { return }

        let edge = SkillEdge(
            from: .init(skillID: start.skillID, portID: start.portID),
            to: .init(skillID: target.skillID, portID: target.portID)
        )

        edges.removeAll {
            $0.to.skillID == edge.to.skillID && $0.to.portID == edge.to.portID
        }
        edges.append(edge)
        validateEdges()
    }

    func removeEdge(_ edge: SkillEdge) {
        edges.removeAll { $0.id == edge.id }
        validateEdges()
    }

    func validateEdges() {
        validationIssues.removeAll()

        for edge in edges {
            guard let fromPort = outputPort(skillID: edge.from.skillID, portID: edge.from.portID),
                  let toPort = inputPort(skillID: edge.to.skillID, portID: edge.to.portID) else {
                validationIssues.append(
                    .init(edgeID: edge.id, severity: .error, message: "Edge references a missing port.")
                )
                continue
            }

            if !toPort.type.accepts(fromPort.type) {
                validationIssues.append(
                    .init(
                        edgeID: edge.id,
                        severity: .error,
                        message: "Type mismatch: \(fromPort.type.rawValue) cannot connect to \(toPort.type.rawValue)."
                    )
                )
            }
        }

        for skill in selectedSkills {
            for input in skill.declaredInputs where input.isRequired {
                let isConnected = edges.contains {
                    $0.to.skillID == skill.id && $0.to.portID == input.id
                }

                if !isConnected {
                    validationIssues.append(
                        .init(
                            edgeID: UUID(),
                            severity: .warning,
                            message: "\(skill.name) requires input '\(input.name)' but it is not connected."
                        )
                    )
                }
            }
        }
    }

    var selectedSkills: [SkillDefinition] {
        library.filter { selectedSkillIDs.contains($0.id) }
    }

    func issue(for edgeID: UUID) -> EdgeValidationIssue? {
        validationIssues.first(where: { $0.edgeID == edgeID })
    }
    
    func moveSkill(from offsets: IndexSet, to destination: Int) {
        package.skills.move(fromOffsets: offsets, toOffset: destination)

        for (index, skill) in package.skills.enumerated() {
            skill.executionOrder = index
        }

        rebuildGraph()
    }
    
    func addMapping(
          fromSkillID: UUID,
          fromOutput: String,
          toSkillID: UUID,
          toInput: String,
          transform: String
      ) {
          guard fromSkillID != toSkillID else { return }

          guard let fromPort = skill(for: fromSkillID)?
              .declaredOutputs
              .first(where: { $0.name == fromOutput }),
                let toPort = skill(for: toSkillID)?
              .declaredInputs
              .first(where: { $0.name == toInput })
          else { return }

          let edge = SkillEdge(
              from: PortReference(skillID: fromSkillID, portID: fromPort.id),
              to: PortReference(skillID: toSkillID, portID: toPort.id),
              transform: transform
          )

          edges.removeAll {
              $0.to.skillID == edge.to.skillID && $0.to.portID == edge.to.portID
          }

          edges.append(edge)
          validateEdges()
      }
    
    func importSkillMarkdownFiles(urls: [URL]) {
        for url in urls {
            guard url.lastPathComponent.lowercased() == "skill.md" || url.pathExtension.lowercased() == "md" else { continue }

            do {
                let skill = try parser.parseFile(at: url)
                if !library.contains(where: { $0.sourceURL == url }) {
                    library.append(skill)
                }
            } catch {
                print("Import failed for \(url.lastPathComponent): \(error)")
            }
        }
    }

}

@MainActor
extension SkillComposerModel {
    func compiledInstructions() -> String {
        let orderedSkills = package.skills.sorted { $0.executionOrder < $1.executionOrder }

        var lines: [String] = []
        lines.append("You are given a catalogue of reusable skills.")

        let global = package.globalInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
        if !global.isEmpty {
            lines.append(global)
        }

        lines.append("")
        lines.append("Use the skills in execution order unless mappings define a different dependency flow.")
        lines.append("")

        for item in orderedSkills {
            guard let skill = skill(for: item.skillID) else { continue }

            lines.append("Skill: \(item.displayName)")
            lines.append("Summary: \(skill.summary)")

            let local = item.localInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
            if !local.isEmpty {
                lines.append("When to use: \(local)")
            }

            if !skill.declaredInputs.isEmpty {
                let inputs = skill.declaredInputs
                    .map { "\($0.name): \($0.type.rawValue)" }
                    .joined(separator: ", ")
                lines.append("Inputs: \(inputs)")
            }

            if !skill.declaredOutputs.isEmpty {
                let outputs = skill.declaredOutputs
                    .map { "\($0.name): \($0.type.rawValue)" }
                    .joined(separator: ", ")
                lines.append("Outputs: \(outputs)")
            }

            lines.append("")
        }

        if !edges.isEmpty {
            lines.append("Mappings:")
            for edge in edges {
                let fromSkill = skill(for: edge.from.skillID)?.name ?? "Unknown"
                let toSkill = skill(for: edge.to.skillID)?.name ?? "Unknown"
                let fromPort = outputPort(skillID: edge.from.skillID, portID: edge.from.portID)?.name ?? "?"
                let toPort = inputPort(skillID: edge.to.skillID, portID: edge.to.portID)?.name ?? "?"

                var mappingLine = "- \(fromSkill).\(fromPort) -> \(toSkill).\(toPort)"
                let transform = edge.transform.trimmingCharacters(in: .whitespacesAndNewlines)
                if !transform.isEmpty {
                    mappingLine += " | transform: \(transform)"
                }
                lines.append(mappingLine)
            }
        }

        return lines.joined(separator: "\n")
    }
}

@MainActor
extension SkillComposerModel {
    func toggleSelection(for skill: SkillDefinition) {
        if selectedSkillIDs.contains(skill.id) {
            selectedSkillIDs.remove(skill.id)
        } else {
            selectedSkillIDs.insert(skill.id)
        }

        rebuildPackageFromSelection()
    }
}

@MainActor
extension SkillComposerModel {
    func prepareExport() throws {
        let orderedSkills = package.skills.sorted { $0.executionOrder < $1.executionOrder }

        let manifest = PackageManifest(
            name: package.name,
            globalInstructions: package.globalInstructions,
            compiledInstructions: compiledInstructions(),
            skills: orderedSkills.compactMap { item in
                guard let skill = skill(for: item.skillID) else { return nil }

                return PackageManifest.SkillNode(
                    skillID: skill.id,
                    displayName: item.displayName,
                    executionOrder: item.executionOrder,
                    localInstructions: item.localInstructions,
                    inputs: skill.declaredInputs,
                    outputs: skill.declaredOutputs,
                    markdown: skill.markdown
                )
            },
            mappings: edges.compactMap { edge in
                guard
                    let fromPort = outputPort(skillID: edge.from.skillID, portID: edge.from.portID),
                    let toPort = inputPort(skillID: edge.to.skillID, portID: edge.to.portID)
                else {
                    return nil
                }

                return PackageManifest.MappingNode(
                    fromSkillID: edge.from.skillID,
                    fromOutput: fromPort.name,
                    toSkillID: edge.to.skillID,
                    toInput: toPort.name,
                    transform: edge.transform
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        exportDocument = ExportPayload(data: try encoder.encode(manifest))
        exportSuggestedFilename =
            package.name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")
            .lowercased() + ".json"
    }
}

@MainActor
extension SkillComposerModel {

        func rebuildPackageFromSelection() {
            let orderedSelectedSkills = selectedSkills.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }

            let existingInstructionsBySkillID = Dictionary(
                uniqueKeysWithValues: package.skills.map { ($0.skillID, $0.localInstructions) }
            )

            package.skills = orderedSelectedSkills.enumerated().map { index, skill in
                PackagedSkill(
                    skillID: skill.id,
                    displayName: skill.name,
                    localInstructions: existingInstructionsBySkillID[skill.id] ?? skill.usageInstructions,
                    executionOrder: index
                )
            }

            let validSkillIDs = Set(orderedSelectedSkills.map(\.id))
            edges.removeAll {
                !validSkillIDs.contains($0.from.skillID) || !validSkillIDs.contains($0.to.skillID)
            }

            if edges.isEmpty {
                edges = buildDefaultEdges(for: orderedSelectedSkills)
            }

            rebuildGraph()
            validateEdges()
        }

    private func buildDefaultEdges(for skills: [SkillDefinition]) -> [SkillEdge] {
        guard skills.count > 1 else { return [] }

        var newEdges: [SkillEdge] = []

        for pair in zip(skills, skills.dropFirst()) {
            let source = pair.0
            let target = pair.1

            guard let match = firstCompatiblePortPair(from: source, to: target) else { continue }

            newEdges.append(
                SkillEdge(
                    from: PortReference(skillID: source.id, portID: match.output.id),
                    to: PortReference(skillID: target.id, portID: match.input.id)
                )
            )
        }

        return newEdges
    }

    private func firstCompatiblePortPair(
        from source: SkillDefinition,
        to target: SkillDefinition
    ) -> (output: SkillPort, input: SkillPort)? {
        for output in source.declaredOutputs {
            for input in target.declaredInputs {
                if input.type.accepts(output.type) {
                    return (output, input)
                }
            }
        }
        return nil
    }
}
