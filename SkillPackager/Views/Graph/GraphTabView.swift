//
//  GraphTabView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


struct GraphTabView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView([.horizontal, .vertical]) {
                SkillGraphEditorView(canvasSize: CGSize(width: 2400, height: 1600))
                    .frame(width: 2400, height: 1600)
            }

            GraphValidationPanel()

            EdgeInspectorView()
        }
        .padding(20)
    }
}
