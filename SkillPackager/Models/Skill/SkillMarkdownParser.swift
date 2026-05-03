//
//  SkillMarkdownParser.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI
import Foundation


private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum SkillParserError: Error {
    case unreadableFile
}

struct SkillMarkdownParser {
    
    func parseFile(at url: URL) throws -> SkillDefinition {
        let markdown = try String(contentsOf: url, encoding: .utf8)
        return parse(markdown: markdown, sourceURL: url)
    }

    func parse(markdown: String, sourceURL: URL? = nil) -> SkillDefinition {
        let frontMatter = extractFrontMatter(from: markdown)
        let body = stripFrontMatter(from: markdown)

        let name = frontMatter["name"] as? String
            ?? firstHeading(in: body)
            ?? sourceURL?.deletingPathExtension().lastPathComponent
            ?? "Untitled Skill"

        let summary = frontMatter["summary"] as? String
            ?? firstParagraph(in: body)
            ?? ""

        let inputs = parsePorts(frontMatter["inputs"])
        let outputs = parsePorts(frontMatter["outputs"])
        let usageInstructions = frontMatter["usageInstructions"] as? String ?? ""

        return SkillDefinition(
            name: name,
            summary: summary,
            markdown: markdown,
            declaredInputs: inputs,
            declaredOutputs: outputs,
            usageInstructions: usageInstructions,
            sourceURL: sourceURL
        )
    }

    private func extractFrontMatter(from markdown: String) -> [String: Any] {
        guard markdown.hasPrefix("---\n") else { return [:] }
        let parts = markdown.components(separatedBy: "\n---\n")
        guard parts.count >= 2 else { return [:] }
        let yamlBlock = parts[0].replacingOccurrences(of: "---\n", with: "")
        return simpleYAMLParse(yamlBlock)
    }

    private func stripFrontMatter(from markdown: String) -> String {
        guard markdown.hasPrefix("---\n") else { return markdown }
        let parts = markdown.components(separatedBy: "\n---\n")
        guard parts.count >= 2 else { return markdown }
        return parts.dropFirst().joined(separator: "\n---\n")
    }

    private func firstHeading(in markdown: String) -> String? {
        markdown
            .split(separator: "\n")
            .first(where: { $0.hasPrefix("# ") })
            .map { String($0.dropFirst(2)).trimmingCharacters(in: .whitespaces) }
    }

    private func firstParagraph(in markdown: String) -> String? {
        markdown
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first(where: { !$0.isEmpty && !$0.hasPrefix("#") })
    }

    private func parsePorts(_ raw: Any?) -> [SkillPort] {
        guard let rows = raw as? [[String: Any]] else { return [] }
        return rows.map {
            SkillPort(
                name: $0["name"] as? String ?? "value",
                type: SkillDataType(rawValue: (($0["type"] as? String) ?? "text").lowercased()) ?? .text,
                isRequired: parseBool($0["required"])
            )
        }
    }
    
    private func parseBool(_ value: Any?) -> Bool {
        switch value {
        case let bool as Bool:
            return bool
        case let string as String:
            return string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true"
        default:
            return false
        }
    }

    private func simpleYAMLParse(_ yaml: String) -> [String: Any] {
        var result: [String: Any] = [:]
        var currentArrayKey: String?
        var currentArray: [[String: Any]] = []

        for rawLine in yaml.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(rawLine)

            if line.hasPrefix("  - ") {
                let content = line.replacingOccurrences(of: "  - ", with: "")
                let pair = content.split(separator: ":", maxSplits: 1).map(String.init)
                if pair.count == 2 {
                    currentArray.append([pair[0].trimmed: pair[1].trimmed])
                }
                continue
            }

            if line.hasPrefix("    "), var last = currentArray.popLast() {
                let pair = line.trimmed.split(separator: ":", maxSplits: 1).map(String.init)
                if pair.count == 2 {
                    last[pair[0].trimmed] = pair[1].trimmed
                }
                currentArray.append(last)
                continue
            }

            if let key = currentArrayKey, !currentArray.isEmpty {
                result[key] = currentArray
                currentArray = []
                currentArrayKey = nil
            }

            let pair = line.split(separator: ":", maxSplits: 1).map(String.init)
            guard pair.count == 2 else { continue }

            let key = pair[0].trimmed
            let value = pair[1].trimmed

            if value.isEmpty {
                currentArrayKey = key
            } else {
                result[key] = value
            }
        }

        if let key = currentArrayKey, !currentArray.isEmpty {
            result[key] = currentArray
        }

        return result
    }
    
    private func parseDataType(_ value: Any?) -> SkillDataType {
        let raw = (value as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? "text"

        return switch raw {
            case "text", "string": .text
            case "markdown", "md": .markdown
            case "json": .json
            case "image": .image
            case "audio": .audio
            case "number", "int", "float", "double": .number
            case "boolean", "bool": .boolean
            case "any": .any
            default: .text
        }
    }


}

