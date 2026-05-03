////
////  Models.swift
////  SkillPackager
////
////  Created by Ringo Wathelet on 2026/04/30.
////
//
import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers



//@Model
//final class Item {
//    var timestamp: Date
//    
//    init(timestamp: Date) {
//        self.timestamp = timestamp
//    }
//}
//
//

struct PackageManifest: Codable {
    
    struct SkillNode: Codable {
        var skillID: UUID
        var displayName: String
        var executionOrder: Int
        var localInstructions: String
        var inputs: [SkillPort]
        var outputs: [SkillPort]
        var markdown: String
    }

    struct MappingNode: Codable {
        var fromSkillID: UUID
        var fromOutput: String
        var toSkillID: UUID
        var toInput: String
        var transform: String
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
