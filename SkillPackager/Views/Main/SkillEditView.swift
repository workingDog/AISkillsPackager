//
//  SkillEditView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/02.
//
import SwiftUI
import UniformTypeIdentifiers


struct SkillEditView: View {
    @AppStorage("fontSize") private var fontSize = 20.0
    
    let skill: SkillDefinition
    
    var body: some View {
        @Bindable var skill = skill
        
        VStack(alignment: .leading, spacing: 15) {
            Text(skill.name).font(.headline)
            
            TextEditor(text: $skill.markdown)
                .font(.system(size: fontSize))
                .autocorrectionDisabled(true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollContentBackground(.hidden)
                .padding(4)
                .background(.background, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }
}
