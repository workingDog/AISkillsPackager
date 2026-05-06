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
            ZoomableSkillGraphView()

            GraphValidationPanel()

            EdgeInspectorView()
        }
        .padding(20)
    }
}
