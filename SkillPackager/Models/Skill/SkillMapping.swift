//
//  SkillMapping.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI
import Foundation


@MainActor
@Observable
final class SkillMapping: Identifiable, Hashable {
    let id: UUID
    var fromSkillID: UUID
    var fromOutput: String
    var toSkillID: UUID
    var toInput: String
    var transform: String

    init(
        id: UUID = UUID(),
        fromSkillID: UUID,
        fromOutput: String,
        toSkillID: UUID,
        toInput: String,
        transform: String = ""
    ) {
        self.id = id
        self.fromSkillID = fromSkillID
        self.fromOutput = fromOutput
        self.toSkillID = toSkillID
        self.toInput = toInput
        self.transform = transform
    }

    static func == (lhs: SkillMapping, rhs: SkillMapping) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

