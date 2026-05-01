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
    var library: [SkillDefinition] = SkillDefinition.samples
    var selectedSkillIDs: Set<UUID> = []
    var package = SkillPackage()
    var exportDocument = ExportPayload(data: Data())
    var exportSuggestedFilename = "skill-package.json"

    @ObservationIgnored
    private let parser = SkillMarkdownParser()

    var selectedSkills: [SkillDefinition] {
        library.filter { selectedSkillIDs.contains($0.id) }
    }

    func toggleSelection(for skill: SkillDefinition) {
        if selectedSkillIDs.contains(skill.id) {
            selectedSkillIDs.remove(skill.id)
        } else {
            selectedSkillIDs.insert(skill.id)
        }
    }

    func rebuildPackageFromSelection() {
        let ordered = selectedSkills.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        package.skills = ordered.enumerated().map { index, skill in
            PackagedSkill(
                skillID: skill.id,
                displayName: skill.name,
                localInstructions: skill.usageInstructions,
                executionOrder: index
            )
        }

        let validIDs = Set(ordered.map(\.id))
        package.mappings.removeAll {
            !validIDs.contains($0.fromSkillID) || !validIDs.contains($0.toSkillID)
        }
    }

    func skill(for id: UUID) -> SkillDefinition? {
        library.first(where: { $0.id == id })
    }

    func packagedSkill(for id: UUID) -> PackagedSkill? {
        package.skills.first(where: { $0.skillID == id })
    }

    func addMapping(fromSkillID: UUID, fromOutput: String, toSkillID: UUID, toInput: String, transform: String) {
        guard fromSkillID != toSkillID else { return }
        let mapping = SkillMapping(
            fromSkillID: fromSkillID,
            fromOutput: fromOutput,
            toSkillID: toSkillID,
            toInput: toInput,
            transform: transform
        )
        package.mappings.append(mapping)
    }

    func removeMappings(at offsets: IndexSet) {
        package.mappings.remove(atOffsets: offsets)
    }

    func moveSkill(from offsets: IndexSet, to destination: Int) {
        package.skills.move(fromOffsets: offsets, toOffset: destination)
        for (index, item) in package.skills.enumerated() {
            item.executionOrder = index
        }
    }

    func compiledInstructions() -> String {
        let orderedSkills = package.skills.sorted { $0.executionOrder < $1.executionOrder }

        var lines: [String] = []
        lines.append("You are given a catalogue of reusable skills.")
        if !package.globalInstructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append(package.globalInstructions)
        }
        lines.append("")
        lines.append("Use the skills in execution order unless a mapping specifies dependent flow.")
        lines.append("")

        for item in orderedSkills {
            guard let skill = skill(for: item.skillID) else { continue }
            lines.append("Skill: \(item.displayName)")
            lines.append("Summary: \(skill.summary)")

            if !item.localInstructions.isEmpty {
                lines.append("When to use: \(item.localInstructions)")
            }

            if !skill.declaredInputs.isEmpty {
                let inputs = skill.declaredInputs.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
                lines.append("Inputs: \(inputs)")
            }

            if !skill.declaredOutputs.isEmpty {
                let outputs = skill.declaredOutputs.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
                lines.append("Outputs: \(outputs)")
            }

            lines.append("")
        }

        if !package.mappings.isEmpty {
            lines.append("Mappings:")
            for mapping in package.mappings {
                let source = skill(for: mapping.fromSkillID)?.name ?? "Unknown"
                let target = skill(for: mapping.toSkillID)?.name ?? "Unknown"
                var line = "- \(source).\(mapping.fromOutput) -> \(target).\(mapping.toInput)"
                if !mapping.transform.isEmpty {
                    line += " | transform: \(mapping.transform)"
                }
                lines.append(line)
            }
        }

        return lines.joined(separator: "\n")
    }

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
            mappings: package.mappings.map {
                .init(
                    fromSkillID: $0.fromSkillID,
                    fromOutput: $0.fromOutput,
                    toSkillID: $0.toSkillID,
                    toInput: $0.toInput,
                    transform: $0.transform
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        exportDocument = ExportPayload(data: try encoder.encode(manifest))
        exportSuggestedFilename = package.name.replacingOccurrences(of: " ", with: "-").lowercased() + ".json"
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
