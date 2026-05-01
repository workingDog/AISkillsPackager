//
//  SkillComposer.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/04/30.
//
import Foundation
import SwiftUI



struct SkillPort: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var type: String
    var isRequired: Bool = false
}

@Observable
@MainActor
final class SkillDefinition: Identifiable, Hashable {
    let id: UUID
    var name: String
    var summary: String
    var markdown: String
    var declaredInputs: [SkillPort]
    var declaredOutputs: [SkillPort]
    var usageInstructions: String
    var sourceURL: URL?

    init(
        id: UUID = UUID(),
        name: String,
        summary: String,
        markdown: String,
        declaredInputs: [SkillPort] = [],
        declaredOutputs: [SkillPort] = [],
        usageInstructions: String = "",
        sourceURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.markdown = markdown
        self.declaredInputs = declaredInputs
        self.declaredOutputs = declaredOutputs
        self.usageInstructions = usageInstructions
        self.sourceURL = sourceURL
    }

    static func == (lhs: SkillDefinition, rhs: SkillDefinition) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static let samples: [SkillDefinition] = [
        SkillDefinition(
            name: "Web Research",
            summary: "Searches the web and extracts structured findings.",
            markdown: """
                ---
                name: Web Research
                summary: Searches the web and extracts structured findings.
                inputs:
                  - name: query
                    type: text
                outputs:
                  - name: findings
                    type: json
                usageInstructions: Use when fresh external information is required.
                ---
                # Web Research
                Gather current information and return structured findings.
                """,
            declaredInputs: [.init(name: "query", type: "text", isRequired: true)],
            declaredOutputs: [.init(name: "findings", type: "json", isRequired: true)],
            usageInstructions: "Use when fresh external information is required."
        ),
        SkillDefinition(
            name: "Outline Writer",
            summary: "Converts research findings into a structured outline.",
            markdown: """
                ---
                name: Outline Writer
                summary: Converts research findings into a structured outline.
                inputs:
                  - name: findings
                    type: json
                outputs:
                  - name: outline
                    type: markdown
                usageInstructions: Use after research to shape the answer structure.
                ---
                # Outline Writer
                Convert source findings into a concise outline.
                """,
            declaredInputs: [.init(name: "findings", type: "json", isRequired: true)],
            declaredOutputs: [.init(name: "outline", type: "markdown", isRequired: true)],
            usageInstructions: "Use after research to shape the answer structure."
        ),
        SkillDefinition(
            name: "Draft Composer",
            summary: "Turns an outline into a polished final draft.",
            markdown: """
                ---
                name: Draft Composer
                summary: Turns an outline into a polished final draft.
                inputs:
                  - name: outline
                    type: markdown
                outputs:
                  - name: article
                    type: markdown
                usageInstructions: Use last to produce the final response.
                ---
                # Draft Composer
                Turn an outline into polished prose.
                """,
            declaredInputs: [.init(name: "outline", type: "markdown", isRequired: true)],
            declaredOutputs: [.init(name: "article", type: "markdown", isRequired: true)],
            usageInstructions: "Use last to produce the final response."
        )
    ]
    
}
