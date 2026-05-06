//
//  ProviderExporters.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation


struct OpenAIResponsesRequest: Codable {
    
    struct InputItem: Identifiable, Codable {
        let id = UUID()
        let role: String
        let content: [ContentItem]
        
        enum CodingKeys: String, CodingKey {
            case role, content
        }
    }

    struct ContentItem: Identifiable, Codable {
        let id = UUID()
        let type: String
        let text: String
        
        enum CodingKeys: String, CodingKey {
            case type, text
        }
    }

    let model: String
    let instructions: String
    let input: [InputItem]
}

struct GeminiGenerateContentRequest: Codable {
    
    struct Content: Codable {
        let role: String?
        let parts: [Part]
    }

    struct Part: Identifiable, Codable {
        let id = UUID()
        let text: String
        
        enum CodingKeys: String, CodingKey {
            case text
        }
    }

    struct GenerationConfig: Codable {
        let responseMimeType: String?

        enum CodingKeys: String, CodingKey {
            case responseMimeType = "response_mime_type"
        }
    }

    let systemInstruction: Content
    let contents: [Content]
    let generationConfig: GenerationConfig?

    enum CodingKeys: String, CodingKey {
        case systemInstruction = "system_instruction"
        case contents
        case generationConfig = "generation_config"
    }
}

enum ProviderExporter {
    static func openAIRequest(from model: SkillComposerModel, modelName: String = "gpt-5") -> OpenAIResponsesRequest {
        let instructions = model.compiledInstructions()

        let userText = """
        Use this skill package to complete the user task.
        Respect the declared execution order and mappings.
        When a skill output feeds another skill input, preserve structure and field names where possible.
        Return the final result and mention which skills were effectively used.
        """

        return OpenAIResponsesRequest(
            model: modelName,
            instructions: instructions,
            input: [
                .init(
                    role: "user",
                    content: [
                        .init(type: "input_text", text: userText)
                    ]
                )
            ]
        )
    }

    static func geminiRequest(from model: SkillComposerModel, modelName: String = "gemini-2.5-flash") -> GeminiEnvelope {
        let instructions = model.compiledInstructions()

        let request = GeminiGenerateContentRequest(
            systemInstruction: .init(
                role: "system",
                parts: [.init(text: instructions)]
            ),
            contents: [
                .init(
                    role: "user",
                    parts: [
                        .init(text: """
                        Use this skill package to complete the task.
                        Respect execution order and mappings.
                        Return the final result and mention which skills were effectively used.
                        """)
                    ]
                )
            ],
            generationConfig: .init(responseMimeType: "text/plain")
        )

        return GeminiEnvelope(
            model: modelName,
            request: request
        )
    }
}

struct GeminiEnvelope: Codable {
    let model: String
    let request: GeminiGenerateContentRequest
}

