//
//  SkillLibraryPane.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI


struct SkillLibraryPane: View {
    @Environment(InterfaceManager.self) var interface
    @Environment(SkillComposerModel.self) var model: SkillComposerModel
    
    @Binding var isImporting: Bool
    
    @State private var showSettings = false
    
    var body: some View {
        List(model.libraryState.library) { skill in
            Button {
                model.toggleSelection(for: skill)
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: model.libraryState.selectedSkillIDs.contains(skill.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(model.libraryState.selectedSkillIDs.contains(skill.id) ? Color.green : Color.blue)
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
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environment(interface)
                .presentationDetents([.large])
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                }.buttonStyle(.glass)
                 .padding(.top, 10)
            }
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    isImporting = true
                } label: {
                    VStack {
                        Text("Import")
                        Text("Skills")
                    }
                }.buttonStyle(.glass)
                .padding(.top, 10)
            }
        }
    }
    
    private func portSummary(for skill: SkillDefinition) -> String {
        let inputs = skill.declaredInputs.map(\.name).joined(separator: ", ")
        let outputs = skill.declaredOutputs.map(\.name).joined(separator: ", ")

        return switch (inputs.isEmpty, outputs.isEmpty) {
            case (false, false): "In: \(inputs)  Out: \(outputs)"
            case (false, true): "In: \(inputs)"
            case (true, false): "Out: \(outputs)"
            case (true, true): ""
        }
    }
    
}
