//
//  SkillGraph.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/03.
//
import SwiftUI


struct GraphPoint: Hashable, Codable, Sendable {
    var x: Double
    var y: Double

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }

    var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

@Observable
@MainActor
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

struct PortReference: Hashable, Codable, Sendable {
    var skillID: UUID
    var portID: UUID
}

@Observable
@MainActor
final class SkillEdge: Identifiable, Hashable {
    let id: UUID
    var from: PortReference
    var to: PortReference
    var transform: String

    init(
        id: UUID = UUID(),
        from: PortReference,
        to: PortReference,
        transform: String = ""
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.transform = transform
    }

    static func == (lhs: SkillEdge, rhs: SkillEdge) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum ValidationSeverity: String, Hashable, Sendable {
    case warning
    case error
}

struct EdgeValidationIssue: Identifiable, Hashable, Sendable {
    let id = UUID()
    var edgeID: UUID
    var severity: ValidationSeverity
    var message: String
}

enum PortSide: Hashable, Sendable {
    case input
    case output
}

struct PortHandle: Hashable, Sendable {
    var skillID: UUID
    var portID: UUID
    var side: PortSide
}

