//
//  PackagedSkillCard.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


struct PackagedSkillCard: View {
    @Environment(SkillComposerModel.self) var model: SkillComposerModel
    let packagedSkill: PackagedSkill

    var body: some View {
        @Bindable var packagedSkill = packagedSkill

        VStack(alignment: .leading, spacing: 8) {
            Text(packagedSkill.displayName)
                .font(.headline)

            if let skill = model.skill(for: packagedSkill.skillID) {
                Text(skill.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Local instructions", text: $packagedSkill.localInstructions, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)

                if !skill.declaredInputs.isEmpty {
                    Text("Inputs: " + skill.declaredInputs.map { "\($0.name): \($0.type)" }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !skill.declaredOutputs.isEmpty {
                    Text("Outputs: " + skill.declaredOutputs.map { "\($0.name): \($0.type)" }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
