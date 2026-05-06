////
////  Models.swift
////  SkillPackager
////
////  Created by Ringo Wathelet on 2026/04/30.
////
//
import Foundation
import SwiftUI
import UniformTypeIdentifiers


struct PackageManifest: Codable {
    
    struct SkillNode: Identifiable, Codable {
        let id = UUID()
        var skillID: UUID
        var displayName: String
        var executionOrder: Int
        var localInstructions: String
        var inputs: [SkillPort]
        var outputs: [SkillPort]
        var markdown: String
        
        enum CodingKeys: String, CodingKey {
            case skillID, displayName, executionOrder, localInstructions
            case inputs, outputs, markdown
        }
    }

    struct MappingNode: Identifiable, Codable {
        let id = UUID()
        var fromSkillID: UUID
        var fromOutput: String
        var toSkillID: UUID
        var toInput: String
        var transform: String
        
        enum CodingKeys: String, CodingKey {
            case fromSkillID, fromOutput, toSkillID, toInput, transform
        }
    }

    var name: String
    var globalInstructions: String
    var compiledInstructions: String
    var skills: [SkillNode]
    var mappings: [MappingNode]
}

struct ExportPayload: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

enum ExportProvider: String, CaseIterable, Identifiable {
    case geminiExport = "Gemini"
    case openAIExport = "OpenAI"

    var id: String { rawValue }
}
