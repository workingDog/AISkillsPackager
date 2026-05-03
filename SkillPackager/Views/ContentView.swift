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
    @Environment(InterfaceManager.self) var interface
    
    @State private var isImporting = false
    @State private var isExporting = false
    @State private var selectedSection: PackageSection? = .details

    var body: some View {
        NavigationSplitView {
            SkillLibraryPane(isImporting: $isImporting)
                .navigationTitle("Skills")
                .navigationSplitViewColumnWidth(min: 300, ideal: 350, max: 500)
                .background(interface.backColor)
        } content: {
            PackageSectionPane(selectedSection: $selectedSection)
                .navigationTitle("Package")
                .navigationSplitViewColumnWidth(min: 250, ideal: 280, max: 450)
                .background(interface.backColor)
        } detail: {
            PackageDetailWorkspace(selectedSection: selectedSection, isExporting: $isExporting)
            .navigationTitle(selectedSection?.title ?? "Workspace")
            .navigationSplitViewColumnWidth(min: 700, ideal: 1200, max: .infinity)
            .background(interface.backColor)
        }
        .background(interface.backColor)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: true
        ) { result in
            switch result {
                case .success(let urls):
                    model.libraryState.importSkillMarkdownFiles(urls: urls)
                case .failure(let error):
                    print("---> import error: \(error)")
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: model.packageState.exportDocument,
            contentType: .json,
            defaultFilename: model.packageState.exportSuggestedFilename
        ) { result in
            switch result {
                case .success: print("---> export successful")
                case .failure(let error): print("---> export error: \(error)")
            }
        }
        .task {
            if model.packageState.package.skills.isEmpty, !model.selectedSkills.isEmpty {
                model.rebuildPackageFromSelection()
            } else if !model.packageState.package.skills.isEmpty, model.graphState.graphNodes.isEmpty {
                model.graphState.rebuildGraph(from: model.packageState.package.skills)
            }
        }
    }
}

enum PackageSection: String, CaseIterable, Identifiable, Hashable {
    case details = "Details"
    case graph = "Graph"
    case providers = "Providers"
    case skills = "Skills"

    var id: String { rawValue }

    var title: String { rawValue }

    var systemImage: String {
        switch self {
            case .details: "slider.horizontal.3"
            case .graph: "point.3.connected.trianglepath.dotted"
            case .providers: "paperplane"
            case .skills: "sparkles.rectangle.stack"
        }
    }
}
