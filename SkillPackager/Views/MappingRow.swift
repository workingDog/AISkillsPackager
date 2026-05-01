//
//  MappingRow.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


struct MappingRow: View {
    @Environment(SkillComposerModel.self) var model: SkillComposerModel
    let mapping: SkillMapping

    var body: some View {
        let fromName = model.skill(for: mapping.fromSkillID)?.name ?? "Unknown"
        let toName = model.skill(for: mapping.toSkillID)?.name ?? "Unknown"

        VStack(alignment: .leading, spacing: 6) {
            Text("\(fromName).\(mapping.fromOutput) -> \(toName).\(mapping.toInput)")
                .font(.headline)

            if !mapping.transform.isEmpty {
                Text("Transform: \(mapping.transform)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
