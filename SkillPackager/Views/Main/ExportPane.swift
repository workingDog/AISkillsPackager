//
//  ExportPane.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI


struct ExportPane: View {
    @Environment(SkillComposerModel.self) var model: SkillComposerModel

    @State private var renderedJSON = ""

    var body: some View {
        @Bindable var model = model

        VStack(alignment: .leading, spacing: 16) {
            Text("Package Export JSON").font(.title2).bold().padding(10)
            ScrollView {
                Text(renderedJSON.isEmpty ? "Render an export payload to preview it here." : renderedJSON)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 320)
            .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(10)
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Picker("", selection: $model.packageState.selectedProvider) {
                    ForEach(ExportProvider.allCases) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: model.packageState.selectedProvider) {
                    renderedJSON = renderJSON(for: model.packageState.selectedProvider, model: model)
                }.buttonStyle(.glass)
            }
        }
        .onAppear {
            if renderedJSON.isEmpty {
                renderedJSON = renderJSON(for: model.packageState.selectedProvider, model: model)
            }
        }
    }

    private func renderJSON(for provider: ExportProvider, model: SkillComposerModel) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            switch provider {
            case .openAIExport:
                let payload = ProviderExporter.openAIRequest(from: model)
                return String(decoding: try encoder.encode(payload), as: UTF8.self)

            case .geminiExport:
                let payload = ProviderExporter.geminiRequest(from: model)
                return String(decoding: try encoder.encode(payload), as: UTF8.self)
            }
        } catch {
            return "Failed to encode payload: \(error)"
        }
    }
}

