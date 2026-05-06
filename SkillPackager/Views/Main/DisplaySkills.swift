//
//  DisplaySkills.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/02.
//
import Foundation
import SwiftUI


struct DisplaySkills: View {
    @Environment(SkillComposerModel.self) private var model
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                ForEach(model.selectedSkills) { skill in
                    if isEditing {
                        SkillEditView(skill: skill)
                    } else {
                        MKView(title: skill.name, text: skill.markdown)
                    }
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.5))
                        .frame(height: 6)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Picker("", selection: $isEditing) {
                    Text("Edit").tag(true)
                    Text("Preview").tag(false)
                }.pickerStyle(.segmented)
                Button("Save edit") {
                    // do save  todo
                    print("----> DisplaySkills save edit TODO")
                }.buttonStyle(.glass)
                    .disabled(!isEditing)
            }
        }
    }
}
