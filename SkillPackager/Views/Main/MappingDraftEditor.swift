//
//  MappingDraftEditor.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI


struct MappingDraftEditor: View {
    @Environment(SkillComposerModel.self) private var model

    var body: some View {
        @Bindable var bindableModel = model

        if bindableModel.graphState.draftMapping != nil {
            VStack(alignment: .leading, spacing: 10) {
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                    GridRow {
                        Picker("From Skill", selection: Binding(
                            get: { bindableModel.graphState.draftMapping?.fromSkillID },
                            set: { newValue in
                                bindableModel.graphState.draftMapping?.fromSkillID = newValue
                                bindableModel.graphState.draftMapping?.fromPortID = nil
                            }
                        )) {
                            Text("Select").tag(Optional<UUID>.none)
                            ForEach(bindableModel.packageState.package.skills.sorted(by: { $0.executionOrder < $1.executionOrder })) { item in
                                Text(item.displayName).tag(Optional(item.skillID))
                            }
                        }
                        
                        Picker("To Skill", selection: Binding(
                            get: { bindableModel.graphState.draftMapping?.toSkillID },
                            set: { newValue in
                                bindableModel.graphState.draftMapping?.toSkillID = newValue
                                bindableModel.graphState.draftMapping?.toPortID = nil
                            }
                        )) {
                            Text("Select").tag(Optional<UUID>.none)
                            ForEach(bindableModel.packageState.package.skills.sorted(by: { $0.executionOrder < $1.executionOrder })) { item in
                                Text(item.displayName).tag(Optional(item.skillID))
                            }
                        }
                    }
                    
                    GridRow {
                        Picker("From Output", selection: Binding(
                            get: { bindableModel.graphState.draftMapping?.fromPortID },
                            set: { bindableModel.graphState.draftMapping?.fromPortID = $0 }
                        )) {
                            Text("Select").tag(Optional<UUID>.none)
                            ForEach(availableOutputs) { port in
                                Text(port.name).tag(Optional(port.id))
                            }
                        }
                        
                        Picker("To Input", selection: Binding(
                            get: { bindableModel.graphState.draftMapping?.toPortID },
                            set: { bindableModel.graphState.draftMapping?.toPortID = $0 }
                        )) {
                            Text("Select").tag(Optional<UUID>.none)
                            ForEach(availableInputs) { port in
                                Text(port.name).tag(Optional(port.id))
                            }
                        }
                    }
                }
                
                TextField(
                    "Optional transform rule",
                    text: Binding(
                        get: { bindableModel.graphState.draftMapping?.transform ?? "" },
                        set: { bindableModel.graphState.draftMapping?.transform = $0 }
                    )
                )
                .textFieldStyle(.roundedBorder)
                
                Button("Add Mapping") {
                    bindableModel.addMappingFromDraft()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canAdd)
            }
            .padding(12)
            .background(Color.black.opacity(0.03), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            EmptyView()
        }
    }

    private var availableOutputs: [SkillPort] {
        guard let skillID = model.graphState.draftMapping?.fromSkillID,
              let skill = model.skill(for: skillID) else { return [] }
        return skill.declaredOutputs
    }

    private var availableInputs: [SkillPort] {
        guard let skillID = model.graphState.draftMapping?.toSkillID,
              let skill = model.skill(for: skillID) else { return [] }
        return skill.declaredInputs
    }

    private var canAdd: Bool {
        guard let draft = model.graphState.draftMapping else { return false }
        return draft.fromSkillID != nil &&
               draft.fromPortID != nil &&
               draft.toSkillID != nil &&
               draft.toPortID != nil
    }
}

struct MappingEditorRow: View {
    @Environment(SkillComposerModel.self) private var model
    let edge: SkillEdge

    var body: some View {
        @Bindable var edge = edge

        let fromSkill = model.skill(for: edge.from.skillID)
        let toSkill = model.skill(for: edge.to.skillID)
        let fromPort = model.outputPort(skillID: edge.from.skillID, portID: edge.from.portID)
        let toPort = model.inputPort(skillID: edge.to.skillID, portID: edge.to.portID)
        let issue = model.graphState.issue(for: edge.id)
        let isSelected = model.graphState.selectedEdgeID == edge.id

        VStack(alignment: .leading, spacing: 8) {
            Text("\(fromSkill?.name ?? "Unknown").\(fromPort?.name ?? "?") -> \(toSkill?.name ?? "Unknown").\(toPort?.name ?? "?")")
                .font(.subheadline.weight(.medium))

            HStack {
                TextField("Optional transform rule", text: $edge.transform)
                    .textFieldStyle(.roundedBorder)
                
                Spacer()
                
                Button(role: .destructive) {
                    model.removeEdge(edge)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .buttonStyle(.borderless)
            }

            if let issue {
                Label(
                    issue.message,
                    systemImage: issue.severity == .error ? "exclamationmark.triangle.fill" : "info.circle.fill"
                )
                .font(.caption)
                .foregroundStyle(issue.severity == .error ? .red : .orange)
            }

        }
        .padding(12)
        .background(
            isSelected ? Color.accentColor.opacity(0.12) : Color.black.opacity(0.03),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isSelected ? Color.accentColor.opacity(0.45) : .clear, lineWidth: 1.5)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            model.selectEdge(edge)
        }
        .onChange(of: edge.transform) { 
            model.validateEdges()
        }
    }
}
