//
//  GraphModels.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import Observation
import CoreGraphics


/*
struct GraphPoint: Codable, Hashable {
    var x: Double
    var y: Double

    var cgPoint: CGPoint { CGPoint(x: x, y: y) }

    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

@MainActor
@Observable
final class SkillGraphNode: Identifiable, Hashable {
    let id: UUID
    var skillID: UUID
    var title: String
    var position: GraphPoint

    init(id: UUID = UUID(), skillID: UUID, title: String, position: GraphPoint) {
        self.id = id
        self.skillID = skillID
        self.title = title
        self.position = position
    }

    static func == (lhs: SkillGraphNode, rhs: SkillGraphNode) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

*/
