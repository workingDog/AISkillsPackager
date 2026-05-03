//
//  EdgeInspectorView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI

struct EdgeInspectorView: View {
    @Environment(SkillComposerModel.self) private var model

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Connections")
                .font(.headline)

            if model.graphState.edges.isEmpty {
                ContentUnavailableView(
                    "No connections",
                    systemImage: "point.3.connected.trianglepath.dotted",
                    description: Text("Drag from an output port to an input port.")
                )
            } else {
                ForEach(model.graphState.edges) { edge in
                    edgeRow(edge)
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func edgeRow(_ edge: SkillEdge) -> some View {
        let fromSkill = model.skill(for: edge.from.skillID)
        let toSkill = model.skill(for: edge.to.skillID)
        let fromPort = model.outputPort(skillID: edge.from.skillID, portID: edge.from.portID)
        let toPort = model.inputPort(skillID: edge.to.skillID, portID: edge.to.portID)
        let issue = model.graphState.issue(for: edge.id)

        return HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(fromSkill?.name ?? "Unknown").\(fromPort?.name ?? "?")")
                    .font(.subheadline.weight(.medium))
                Text("to \(toSkill?.name ?? "Unknown").\(toPort?.name ?? "?")")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let issue {
                    Label(issue.message, systemImage: issue.severity == .error ? "exclamationmark.triangle.fill" : "info.circle.fill")
                        .font(.caption)
                        .foregroundStyle(issue.severity == .error ? .red : .orange)
                }
            }

            Spacer()

            Button(role: .destructive) {
                model.graphState.removeEdge(edge)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
        }
        .padding(10)
        .background(Color.black.opacity(0.03), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}


