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
    
    var body: some View {
        ScrollView {
            ForEach(model.selectedSkills) { skill in
                MKView(title: skill.name, text: skill.markdown)
            }
        }
    }
}

