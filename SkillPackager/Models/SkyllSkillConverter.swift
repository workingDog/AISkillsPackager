//
//  SkyllSkillConverter.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/07.
//
import Foundation
import SwiftSkyllKit


extension SkyllSkill {
    
    func asSkillDefinition() -> SkillDefinition {
        SkillDefinition(
            name: title,
            summary: description ?? "",
            markdown: rawContent ?? content ?? "",
            declaredInputs: [SkillPort(name: "prompt", type: .text, isRequired: true)],
            declaredOutputs: [SkillPort(name: "prompt", type: .text, isRequired: true)],
            usageInstructions: "",
            sourceURL: refs?.raw.flatMap(URL.init(string:))
                ?? refs?.github.flatMap(URL.init(string:))
                ?? refs?.skillsSh.flatMap(URL.init(string:))
        )
    }
}
