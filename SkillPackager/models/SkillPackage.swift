//
//  SkillPackage.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


@Observable
@MainActor
final class SkillPackage {
    var name: String
    var globalInstructions: String
    var skills: [PackagedSkill]
    var mappings: [SkillMapping]

    init(
        name: String = "New Skill Package",
        globalInstructions: String = "",
        skills: [PackagedSkill] = [],
        mappings: [SkillMapping] = []
    ) {
        self.name = name
        self.globalInstructions = globalInstructions
        self.skills = skills
        self.mappings = mappings
    }
}

