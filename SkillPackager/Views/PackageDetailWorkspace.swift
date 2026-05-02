//
//  PackageDetailWorkspace.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


struct PackageDetailWorkspace: View {
    let selectedSection: PackageSection?
    @Binding var isExporting: Bool

    var body: some View {
        Group {
            switch selectedSection {
                case .details: PackageDetailsView(isExporting: $isExporting)
                case .graph: GraphTabView()
                case .providers: ExportPane()
                case .skills: DisplaySkills()
                case nil:
                    ContentUnavailableView(
                        "No Section Selected",
                        systemImage: "sidebar.right",
                        description: Text("Choose a package section from the middle column.")
                    )
                }
        }
    }
}

