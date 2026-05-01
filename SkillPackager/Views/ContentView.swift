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
    @Environment(SkillComposerModel.self) var model: SkillComposerModel

    @State private var isImporting = false
    @State private var isExporting = false

    var body: some View {
        NavigationSplitView {
            SkillLibraryPane(isImporting: $isImporting)
                .navigationTitle("Skills")
        } detail: {
            PackageEditorPane(isExporting: $isExporting)
                .navigationTitle("Package Composer")
        }
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
    }
}
