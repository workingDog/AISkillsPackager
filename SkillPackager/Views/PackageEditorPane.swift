//
//  PackageEditorPane.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI


struct PackageEditorPane: View {
    @Environment(SkillComposerModel.self) private var model
    @Binding var isExporting: Bool

    var body: some View {
        TabView {
            PackageDetailsView(isExporting: $isExporting)
                .tabItem {
                    Label("Details", systemImage: "slider.horizontal.3")
                }

            GraphTabView()
                .tabItem {
                    Label("Graph", systemImage: "point.3.connected.trianglepath.dotted")
                }

            ExportPane()
                .tabItem {
                    Label("Providers", systemImage: "paperplane")
                }
        }
        .tabViewStyle(.sidebarAdaptable)
        .task {
            if model.package.skills.isEmpty, !model.selectedSkillIDs.isEmpty {
                model.rebuildPackageFromSelection()
            } else if !model.package.skills.isEmpty, model.graphNodes.isEmpty {
                model.rebuildGraph()
            }
        }
    }
}
