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
    @Environment(InterfaceManager.self) private var interface
    @Binding var isExporting: Bool

    var body: some View {
        @Bindable var bindableModel = model

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Package name", text: $bindableModel.packageState.package.name)

                        TextField(
                            "Global instructions",
                            text: $bindableModel.packageState.package.globalInstructions,
                            axis: .vertical
                        )
                        .lineLimit(3...6)

                        Text("\(bindableModel.packageState.package.skills.count) skills selected")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .textFieldStyle(.roundedBorder)
                } label: {
                    Text("Package").font(.headline)
                }
                .background(Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: 14))

                GroupBox {
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
                } label: {
                    Text("Selected Skills").font(.headline)
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mappings can be created in text form here or visually in the Graph tab.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack {
                            Button("New Mapping") {
                                bindableModel.beginNewMapping()
                            }
                            .buttonStyle(.borderedProminent)

                            if bindableModel.graphState.draftMapping != nil {
                                Button("Cancel") {
                                    bindableModel.cancelNewMapping()
                                }
                                .buttonStyle(.bordered)
                            }
                        }

                        if bindableModel.graphState.draftMapping != nil {
                            MappingDraftEditor()
                        }

                        Text("Mapping list")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        if bindableModel.graphState.edges.isEmpty {
                            Label("No graph connections yet", systemImage: "point.3.connected.trianglepath.dotted")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(bindableModel.graphState.edges) { edge in
                                MappingEditorRow(edge: edge)
                            }
                        }
                    }
                } label: {
                    Text("Mappings").font(.headline)
                }
                .background(Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                GroupBox {
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
                } label: {
                    Text("Validation").font(.headline)
                }
                .background(Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                GroupBox {
                    ScrollView(.horizontal) {
                        Text(bindableModel.compiledInstructions())
                            .font(.system(size: CGFloat(interface.textSize), design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 240, alignment: .topLeading)
                } label: {
                    Text("Instructions Preview").font(.headline)
                }
                .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
                }
                .buttonStyle(.glass)
                .disabled(bindableModel.packageState.package.skills.isEmpty)
                .padding(8)
            }
        }
    }
}
