//
//  PackageDetailsView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI


struct PackageDetailsView: View {
    @Environment(SkillComposerModel.self) var model: SkillComposerModel
    @Binding var isExporting: Bool

    @State private var draftFromSkillID: UUID?
    @State private var draftToSkillID: UUID?
    @State private var draftFromOutput = ""
    @State private var draftToInput = ""
    @State private var draftTransform = ""

    var body: some View {
        @Bindable var model = model

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox("Package") {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Package name", text: $model.package.name)

                        TextField("Global instructions", text: $model.package.globalInstructions, axis: .vertical)
                            .lineLimit(3...6)

                        Text("\(model.package.skills.count) skills selected")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .textFieldStyle(.roundedBorder)
                }

                GroupBox("Selected Skills") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(model.package.skills.sorted(by: { $0.executionOrder < $1.executionOrder })) { item in
                            PackagedSkillCard(packagedSkill: item)
                        }
                        .onMove(perform: model.moveSkill)
                    }
                }

                GroupBox("Mappings") {
                    VStack(alignment: .leading, spacing: 12) {
                        MappingDraftEditor(
                            draftFromSkillID: $draftFromSkillID,
                            draftToSkillID: $draftToSkillID,
                            draftFromOutput: $draftFromOutput,
                            draftToInput: $draftToInput,
                            draftTransform: $draftTransform
                        )

                        ForEach(model.package.mappings) { mapping in
                            MappingRow(mapping: mapping)
                        }
                        .onDelete(perform: model.removeMappings)
                    }
                }

                GroupBox("Compiled Instructions Preview") {
                    ScrollView(.horizontal) {
                        Text(model.compiledInstructions())
                            .font(.system(.footnote, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 240, alignment: .topLeading)
                }

                HStack {
                    Button("Rebuild Graph") {
                        model.rebuildGraph()
                    }

                    Spacer()

                    Button("Export Package") {
                        do {
                            try model.prepareExport()
                            isExporting = true
                        } catch {
                            print("Export failed: \(error)")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.package.skills.isEmpty)
                }
            }
            .padding(20)
        }
    }
}

