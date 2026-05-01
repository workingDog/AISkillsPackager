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
            Picker("Provider", selection: $model.selectedProvider) {
                ForEach(ExportProvider.allCases) { provider in
                    Text(provider.rawValue).tag(provider)
                }
            }
            .pickerStyle(.segmented)

            Button("Render Export JSON") {
                renderedJSON = renderJSON(for: model.selectedProvider, model: model)
            }
            .buttonStyle(.borderedProminent)

            ScrollView {
                Text(renderedJSON.isEmpty ? "Render an export payload to preview it here." : renderedJSON)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 320)
            .padding(12)
            .background(.quaternary.opacity(0.25), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .onAppear {
            if renderedJSON.isEmpty {
                renderedJSON = renderJSON(for: model.selectedProvider, model: model)
            }
        }
    }

    private func renderJSON(for provider: ExportProvider, model: SkillComposerModel) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            switch provider {
            case .openAIResponses:
                let payload = ProviderExporter.openAIRequest(from: model)
                return String(decoding: try encoder.encode(payload), as: UTF8.self)

            case .geminiGenerateContent:
                let payload = ProviderExporter.geminiRequest(from: model)
                return String(decoding: try encoder.encode(payload), as: UTF8.self)
            }
        } catch {
            return "Failed to encode payload: \(error)"
        }
    }
}

