//
//  Untitled.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/03.
//
import Foundation
import SwiftUI



@Observable
@MainActor
final class SkillPackageState {
    var package = SkillPackage()
    var selectedProvider: ExportProvider = .geminiExport

    var exportDocument = ExportPayload(data: Data())
    var exportSuggestedFilename = "skill-package.json"
}

