//
//  PackageDetailsView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI


struct PackageDetailsView: View {
    @Environment(SkillComposerModel.self) private var model
    @Binding var isExporting: Bool

    var body: some View {
        @Bindable var bindableModel = model

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox("Package") {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Package name", text: $bindableModel.packageState.package.name)

                        TextField("Global instructions", text: $bindableModel.packageState.package.globalInstructions, axis: .vertical)
                            .lineLimit(3...6)

                        Text("\(bindableModel.packageState.package.skills.count) skills selected")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .textFieldStyle(.roundedBorder)
                }

                GroupBox("Selected Skills") {
                    if bindableModel.packageState.package.skills.isEmpty {
                        ContentUnavailableView(
                            "No skills selected",
                            systemImage: "square.stack.3d.up.slash",
                            description: Text("Choose skills in the library.")
                        )
                    } else {
                        List {
                            ForEach(bindableModel.packageState.package.skills.sorted(by: { $0.executionOrder < $1.executionOrder })) { item in
                                PackagedSkillCard(packagedSkill: item)
                                    .listRowSeparator(.hidden)
                            }
                            .onMove(perform: bindableModel.moveSkill)
                        }
                        .listStyle(.plain)
                        .frame(minHeight: 260)
                    }
                }

                GroupBox("Mappings") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mappings are now created and edited in the Graph tab by dragging from output ports to input ports.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if bindableModel.graphState.edges.isEmpty {
                            Label("No graph connections yet", systemImage: "point.3.connected.trianglepath.dotted")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(bindableModel.graphState.edges) { edge in
                                EdgeSummaryRow(edge: edge)
                            }
                        }
                    }
                }

                GroupBox("Validation") {
                    if bindableModel.graphState.validationIssues.isEmpty {
                        Label("No validation issues", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(bindableModel.graphState.validationIssues) { issue in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: issue.severity == .error ? "exclamationmark.triangle.fill" : "info.circle.fill")
                                        .foregroundStyle(issue.severity == .error ? .red : .orange)

                                    Text(issue.message)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }

                GroupBox("Compiled Instructions Preview") {
                    ScrollView(.horizontal) {
                        Text(bindableModel.compiledInstructions())
                            .font(.system(.footnote, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 240, alignment: .topLeading)
                }
            }
            .padding(20)
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button("Export Package") {
                    do {
                        try bindableModel.prepareExport()
                        isExporting = true
                    } catch {
                        print("Export failed: \(error)")
                    }
                }.buttonStyle(.glass)
                .disabled(bindableModel.packageState.package.skills.isEmpty)
                .padding(8)
            }
        }
    }
}

struct EdgeSummaryRow: View {
    @Environment(SkillComposerModel.self) private var model

    let edge: SkillEdge

    var body: some View {
        let fromSkill = model.skill(for: edge.from.skillID)
        let toSkill = model.skill(for: edge.to.skillID)
        let fromPort = model.outputPort(skillID: edge.from.skillID, portID: edge.from.portID)
        let toPort = model.inputPort(skillID: edge.to.skillID, portID: edge.to.portID)
        let issue = model.graphState.issue(for: edge.id)

        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(fromSkill?.name ?? "Unknown").\(fromPort?.name ?? "?")")
                    .font(.subheadline.weight(.medium))

                Text("to \(toSkill?.name ?? "Unknown").\(toPort?.name ?? "?")")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !edge.transform.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Transform: \(edge.transform)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

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
