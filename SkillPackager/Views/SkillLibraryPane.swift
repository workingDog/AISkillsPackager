//
//  SkillLibraryPane.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


struct SkillLibraryPane: View {
    @Environment(SkillComposerModel.self) var model: SkillComposerModel
    @Binding var isImporting: Bool

    var body: some View {
        @Bindable var model = model

        List(model.library) { skill in
            Button {
                model.toggleSelection(for: skill)
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: model.selectedSkillIDs.contains(skill.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(model.selectedSkillIDs.contains(skill.id) ? Color.green : Color.blue)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(skill.name)
                            .font(.headline)
                        Text(skill.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)

                        if !skill.declaredInputs.isEmpty || !skill.declaredOutputs.isEmpty {
                            Text(portSummary(for: skill))
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Import SKILL.md") {
                    isImporting = true
                }

                Button("Build Package") {
                    model.rebuildPackageFromSelection()
                }
                .disabled(model.selectedSkillIDs.isEmpty)
            }
        }
    }

    private func portSummary(for skill: SkillDefinition) -> String {
        let inputs = skill.declaredInputs.map(\.name).joined(separator: ", ")
        let outputs = skill.declaredOutputs.map(\.name).joined(separator: ", ")

        switch (inputs.isEmpty, outputs.isEmpty) {
        case (false, false):
            return "In: \(inputs)  Out: \(outputs)"
        case (false, true):
            return "In: \(inputs)"
        case (true, false):
            return "Out: \(outputs)"
        case (true, true):
            return ""
        }
    }
}
