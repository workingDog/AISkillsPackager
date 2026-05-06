//
//  SkillComposerModel.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI


@Observable
@MainActor
final class SkillComposerModel {
    var libraryState = SkillLibraryState()
    var packageState = SkillPackageState()
    var graphState = SkillGraphState()

    var selectedSkills: [SkillDefinition] {
        libraryState.library.filter { libraryState.selectedSkillIDs.contains($0.id) }
    }
    
    init() { }

    func skill(for id: UUID) -> SkillDefinition? {
        libraryState.library.first(where: { $0.id == id })
    }

    func inputPort(skillID: UUID, portID: UUID) -> SkillPort? {
        skill(for: skillID)?.declaredInputs.first(where: { $0.id == portID })
    }

    func outputPort(skillID: UUID, portID: UUID) -> SkillPort? {
        skill(for: skillID)?.declaredOutputs.first(where: { $0.id == portID })
    }

    func toggleSelection(for skill: SkillDefinition) {
        libraryState.toggleSelection(for: skill)
        rebuildPackageFromSelection()
    }
    
    func moveSkill(from offsets: IndexSet, to destination: Int) {
        packageState.package.skills.move(fromOffsets: offsets, toOffset: destination)

        for (index, skill) in packageState.package.skills.enumerated() {
            skill.executionOrder = index
        }

        graphState.rebuildGraph(from: packageState.package.skills)
        validateEdges()
    }
    
    func rebuildPackageFromSelection() {
        let orderedSelectedSkills = selectedSkills.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }

        let existingInstructionsBySkillID = Dictionary(
            uniqueKeysWithValues: packageState.package.skills.map { ($0.skillID, $0.localInstructions) }
        )

        packageState.package.skills = orderedSelectedSkills.enumerated().map { index, skill in
            PackagedSkill(
                skillID: skill.id,
                displayName: skill.name,
                localInstructions: existingInstructionsBySkillID[skill.id] ?? skill.usageInstructions,
                executionOrder: index
            )
        }

        let validSkillIDs = Set(orderedSelectedSkills.map(\.id))
        graphState.edges.removeAll {
            !validSkillIDs.contains($0.from.skillID) || !validSkillIDs.contains($0.to.skillID)
        }

        if graphState.edges.isEmpty {
            graphState.edges = buildDefaultEdges(for: orderedSelectedSkills)
        }

        graphState.rebuildGraph(from: packageState.package.skills)
        validateEdges()
    }

    func validateEdges() {
        graphState.validationIssues.removeAll()

        for edge in graphState.edges {
            guard let fromPort = outputPort(skillID: edge.from.skillID, portID: edge.from.portID),
                  let toPort = inputPort(skillID: edge.to.skillID, portID: edge.to.portID) else {
                graphState.validationIssues.append(
                    .init(edgeID: edge.id, severity: .error, message: "Edge references a missing port.")
                )
                continue
            }

            if !toPort.type.accepts(fromPort.type) {
                graphState.validationIssues.append(
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
                let isConnected = graphState.edges.contains {
                    $0.to.skillID == skill.id && $0.to.portID == input.id
                }

                if !isConnected {
                    graphState.validationIssues.append(
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
    
    func issue(for edgeID: UUID) -> EdgeValidationIssue? {
        graphState.validationIssues.first(where: { $0.edgeID == edgeID })
    }

    func compiledInstructions() -> String {
        let orderedSkills = packageState.package.skills.sorted { $0.executionOrder < $1.executionOrder }

        var lines: [String] = []
        lines.append("You are given a catalogue of reusable skills.")

        let global = packageState.package.globalInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
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
                lines.append("Inputs: " + skill.declaredInputs.map { "\($0.name): \($0.type.rawValue)" }.joined(separator: ", "))
            }

            if !skill.declaredOutputs.isEmpty {
                lines.append("Outputs: " + skill.declaredOutputs.map { "\($0.name): \($0.type.rawValue)" }.joined(separator: ", "))
            }

            lines.append("")
        }

        if !graphState.edges.isEmpty {
            lines.append("Mappings:")
            for edge in graphState.edges {
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

    func prepareExport() throws {
        let orderedSkills = packageState.package.skills.sorted { $0.executionOrder < $1.executionOrder }

        let manifest = PackageManifest(
            name: packageState.package.name,
            globalInstructions: packageState.package.globalInstructions,
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
            mappings: graphState.edges.compactMap { edge in
                guard let fromPort = outputPort(skillID: edge.from.skillID, portID: edge.from.portID),
                      let toPort = inputPort(skillID: edge.to.skillID, portID: edge.to.portID) else {
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

        packageState.exportDocument = ExportPayload(data: try encoder.encode(manifest))
        packageState.exportSuggestedFilename =
            packageState.package.name
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: " ", with: "-")
                .lowercased() + ".json"
    }

    private func buildDefaultEdges(for skills: [SkillDefinition]) -> [SkillEdge] {
        guard skills.count > 1 else { return [] }

        var edges: [SkillEdge] = []

        for (source, target) in zip(skills, skills.dropFirst()) {
            guard let pair = firstCompatiblePortPair(from: source, to: target) else { continue }
            edges.append(
                SkillEdge(
                    from: PortReference(skillID: source.id, portID: pair.output.id),
                    to: PortReference(skillID: target.id, portID: pair.input.id)
                )
            )
        }

        return edges
    }

    private func firstCompatiblePortPair(from source: SkillDefinition, to target: SkillDefinition) -> (output: SkillPort, input: SkillPort)? {
        for output in source.declaredOutputs {
            for input in target.declaredInputs where input.type.accepts(output.type) {
                return (output, input)
            }
        }
        return nil
    }
}

@MainActor
extension SkillComposerModel {
    
    func selectEdge(_ edge: SkillEdge) {
        graphState.selectedEdgeID = edge.id
        graphState.draftMapping = nil
    }

    func beginNewMapping() {
        graphState.beginNewMapping()
    }

    func cancelNewMapping() {
        graphState.cancelNewMapping()
    }

    func selectedEdge() -> SkillEdge? {
        guard let id = graphState.selectedEdgeID else { return nil }
        return graphState.edge(for: id)
    }

    func addMappingFromDraft() {
        guard let draft = graphState.draftMapping,
              let fromSkillID = draft.fromSkillID,
              let fromPortID = draft.fromPortID,
              let toSkillID = draft.toSkillID,
              let toPortID = draft.toPortID
        else { return }

        addEdge(
            from: PortHandle(skillID: fromSkillID, portID: fromPortID, side: .output),
            to: PortHandle(skillID: toSkillID, portID: toPortID, side: .input),
            transform: draft.transform
        )

        graphState.draftMapping = nil
    }

    func addEdge(from: PortHandle, to: PortHandle, transform: String = "") {
        let edge = SkillEdge(
            from: .init(skillID: from.skillID, portID: from.portID),
            to: .init(skillID: to.skillID, portID: to.portID),
            transform: transform
        )

        graphState.edges.removeAll {
            $0.to.skillID == edge.to.skillID && $0.to.portID == edge.to.portID
        }

        graphState.edges.append(edge)
        graphState.selectedEdgeID = edge.id
        graphState.draftMapping = nil
        validateEdges()
    }

    func handleEdgeDragEnd(over inputHandle: PortHandle?) {
        guard let result = graphState.endEdgeDrag(over: inputHandle) else { return }
        addEdge(from: result.from, to: result.to)
    }

    func removeEdge(_ edge: SkillEdge) {
        graphState.removeEdge(edge)
        validateEdges()
    }
}
