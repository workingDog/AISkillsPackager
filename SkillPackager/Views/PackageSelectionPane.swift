//
//  PackageSelectionPane.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


struct PackageSectionPane: View {
    @Environment(InterfaceManager.self) var interface
    
    @Binding var selectedSection: PackageSection?

    var body: some View {
        List(PackageSection.allCases, selection: $selectedSection) { section in
            Label(section.title, systemImage: section.systemImage)
                .tag(section)
                .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
    }
}
