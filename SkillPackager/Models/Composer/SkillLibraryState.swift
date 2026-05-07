//
//  SkillLibraryState.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/03.
//
import Foundation
import SwiftUI


@Observable
@MainActor
final class SkillLibraryState {
    var library: [SkillDefinition] = []
    var selectedSkillIDs: Set<UUID> = []

    @ObservationIgnored
    private let parser = SkillMarkdownParser()

//    init(library: [SkillDefinition]) {
//        self.library = library
//    }
    
    init() {
      //  self.library = SkillDefinition.samples 
    }

    func toggleSelection(for skill: SkillDefinition) {
        if selectedSkillIDs.contains(skill.id) {
            selectedSkillIDs.remove(skill.id)
        } else {
            selectedSkillIDs.insert(skill.id)
        }
    }

    func importSkillMarkdownFiles(urls: [URL]) {
        for url in urls {
            guard url.lastPathComponent.lowercased() == "skill.md"
                || url.pathExtension.lowercased() == "md"
            else { continue }

            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let skill = try parser.parseFile(at: url)
                if !library.contains(where: { $0.sourceURL == url }) {
                    library.append(skill)
                }
            } catch {
                print("----> Import failed for \(url.lastPathComponent): \(error)")
            }
        }
    }

}
