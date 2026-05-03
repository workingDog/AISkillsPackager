//
//  GraphValidationPanel.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI

struct GraphValidationPanel: View {
    @Environment(SkillComposerModel.self) private var model

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Validation", systemImage: "checklist")
                .font(.headline)

            if model.graphState.validationIssues.isEmpty {
                Label("No validation issues", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.subheadline)
            } else {
                ForEach(model.graphState.validationIssues) { issue in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: issue.severity == .error ? "exclamationmark.triangle.fill" : "info.circle.fill")
                            .foregroundStyle(issue.severity == .error ? .red : .orange)

                        Text(issue.message)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

