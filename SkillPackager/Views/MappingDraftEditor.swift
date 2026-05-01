//
//  MappingDraftEditor.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


struct MappingDraftEditor: View {
    @Environment(SkillComposerModel.self) var model: SkillComposerModel

    @Binding var draftFromSkillID: UUID?
    @Binding var draftToSkillID: UUID?
    @Binding var draftFromOutput: String
    @Binding var draftToInput: String
    @Binding var draftTransform: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add Mapping")
                .font(.headline)

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    Picker("From Skill", selection: $draftFromSkillID) {
                        Text("Select").tag(Optional<UUID>.none)
                        ForEach(model.package.skills.sorted(by: { $0.executionOrder < $1.executionOrder }), id: \.self) { item in
                            Text(item.displayName).tag(Optional(item.skillID))
                        }
                    }

                    Picker("To Skill", selection: $draftToSkillID) {
                        Text("Select").tag(Optional<UUID>.none)
                        ForEach(model.package.skills.sorted(by: { $0.executionOrder < $1.executionOrder })) { item in
                            Text(item.displayName).tag(Optional(item.skillID))
                        }
                    }
                }

                GridRow {
                    Picker("From Output", selection: $draftFromOutput) {
                        Text("Select").tag("")
                        ForEach(availableOutputs, id: \.self) { output in
                            Text(output).tag(output)
                        }
                    }

                    Picker("To Input", selection: $draftToInput) {
                        Text("Select").tag("")
                        ForEach(availableInputs, id: \.self) { input in
                            Text(input).tag(input)
                        }
                    }
                }
            }

            TextField("Optional transform rule", text: $draftTransform)
                .textFieldStyle(.roundedBorder)

            Button("Add Mapping") {
                guard let fromSkillID = draftFromSkillID,
                      let toSkillID = draftToSkillID,
                      !draftFromOutput.isEmpty,
                      !draftToInput.isEmpty
                else { return }

                model.addMapping(
                    fromSkillID: fromSkillID,
                    fromOutput: draftFromOutput,
                    toSkillID: toSkillID,
                    toInput: draftToInput,
                    transform: draftTransform
                )

                draftTransform = ""
                draftFromOutput = ""
                draftToInput = ""
            }
            .buttonStyle(.borderedProminent)
            .disabled(draftFromSkillID == nil || draftToSkillID == nil || draftFromOutput.isEmpty || draftToInput.isEmpty)
        }
    }

    private var availableOutputs: [String] {
        guard let id = draftFromSkillID, let skill = model.skill(for: id) else { return [] }
        return skill.declaredOutputs.map(\.name)
    }

    private var availableInputs: [String] {
        guard let id = draftToSkillID, let skill = model.skill(for: id) else { return [] }
        return skill.declaredInputs.map(\.name)
    }
}
