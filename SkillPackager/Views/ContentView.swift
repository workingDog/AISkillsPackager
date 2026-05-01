//
//  Codex.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    @Environment(SkillComposerModel.self) private var model

    @State private var isImporting = false
    @State private var isExporting = false
    @State private var selectedSection: PackageSection? = .details

    private let appBackground = Color(red: 0.94, green: 0.95, blue: 0.92)
    private let sidebarBackground = Color(red: 0.90, green: 0.92, blue: 0.88)
    private let contentBackground = Color(red: 0.96, green: 0.96, blue: 0.94)

    var body: some View {
        NavigationSplitView {
            SkillLibraryPane(isImporting: $isImporting)
                .navigationTitle("Skills")
                .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 320)
                .background(sidebarBackground)
        } content: {
            PackageSectionPane(selectedSection: $selectedSection)
                .navigationTitle("Package")
                .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 260)
                .background(sidebarBackground)
        } detail: {
            PackageDetailWorkspace(
                selectedSection: selectedSection,
                isExporting: $isExporting
            )
            .navigationTitle(selectedSection?.title ?? "Workspace")
            .navigationSplitViewColumnWidth(min: 700, ideal: 1000, max: .infinity)
            .background(contentBackground)
        }
        .background(appBackground)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: true
        ) { result in
            guard case .success(let urls) = result else { return }
            model.importSkillMarkdownFiles(urls: urls)
        }
        .fileExporter(
            isPresented: $isExporting,
            document: model.exportDocument,
            contentType: .json,
            defaultFilename: model.exportSuggestedFilename
        ) { _ in }
        .task {
            if model.package.skills.isEmpty, !model.selectedSkillIDs.isEmpty {
                model.rebuildPackageFromSelection()
            } else if !model.package.skills.isEmpty, model.graphNodes.isEmpty {
                model.rebuildGraph()
            }
        }
    }
}

enum PackageSection: String, CaseIterable, Identifiable, Hashable {
    case details = "Details"
    case graph = "Graph"
    case providers = "Providers"

    var id: String { rawValue }

    var title: String { rawValue }

    var systemImage: String {
        switch self {
            case .details: "slider.horizontal.3"
            case .graph: "point.3.connected.trianglepath.dotted"
            case .providers: "paperplane"
        }
    }
}
