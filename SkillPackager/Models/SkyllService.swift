//
//  SkyllService.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/07.
//
import Foundation
import SwiftSkyllKit


@MainActor
final class SkyllService {
    static let shared = SkyllService()

    private let client: SkyllClient

    private init(client: SkyllClient = SkyllClient()) {
        self.client = client
    }

    func searchSkills(query: String, limit: Int = 10) async throws -> [SkyllSkill] {
        try await client.searchSkills(
            query: query,
            limit: limit,
            includeContent: true,
            includeReferences: false
        )
    }
}

