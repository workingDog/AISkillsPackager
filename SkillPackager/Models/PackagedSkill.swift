//
//  PackagedSkill.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


@Observable
@MainActor
final class PackagedSkill: Identifiable, Hashable {
    let id: UUID
    var skillID: UUID
    var displayName: String
    var localInstructions: String
    var executionOrder: Int

    init(
        id: UUID = UUID(),
        skillID: UUID,
        displayName: String,
        localInstructions: String,
        executionOrder: Int
    ) {
        self.id = id
        self.skillID = skillID
        self.displayName = displayName
        self.localInstructions = localInstructions
        self.executionOrder = executionOrder
    }

    static func == (lhs: PackagedSkill, rhs: PackagedSkill) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
