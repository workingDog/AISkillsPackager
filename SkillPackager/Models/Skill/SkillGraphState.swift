//
//  SkillGraphState.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/03.
//
import Foundation
import SwiftUI


@Observable
@MainActor
final class SkillGraphState {
    var graphNodes: [SkillGraphNode] = []
    var edges: [SkillEdge] = []

    var dragStartPort: PortHandle?
    var dragCurrentPoint: CGPoint?
    var hoveredInputPort: PortHandle?

    var validationIssues: [EdgeValidationIssue] = []

    func node(for skillID: UUID) -> SkillGraphNode? {
        graphNodes.first(where: { $0.skillID == skillID })
    }
    
    func issue(for edgeID: UUID) -> EdgeValidationIssue? {
        validationIssues.first(where: { $0.edgeID == edgeID })
    }

    func rebuildGraph(from packagedSkills: [PackagedSkill]) {
        let ordered = packagedSkills.sorted { $0.executionOrder < $1.executionOrder }

        graphNodes = ordered.enumerated().map { index, item in
            let existing = graphNodes.first(where: { $0.skillID == item.skillID })
            let column = index % 4
            let row = index / 4

            return SkillGraphNode(
                id: existing?.id ?? UUID(),
                skillID: item.skillID,
                title: item.displayName,
                position: existing?.position ?? GraphPoint(
                    x: 220 + Double(column) * 320,
                    y: 160 + Double(row) * 240
                )
            )
        }
    }

    func beginEdgeDrag(from handle: PortHandle, at point: CGPoint) {
        guard handle.side == .output else { return }
        dragStartPort = handle
        dragCurrentPoint = point
        hoveredInputPort = nil
    }

    func updateEdgeDrag(point: CGPoint, hoveredInput: PortHandle?) {
        dragCurrentPoint = point
        hoveredInputPort = hoveredInput
    }

    func endEdgeDrag(over inputHandle: PortHandle?) -> (from: PortHandle, to: PortHandle)? {
        defer {
            dragStartPort = nil
            dragCurrentPoint = nil
            hoveredInputPort = nil
        }

        guard let start = dragStartPort,
              let target = inputHandle,
              start.side == .output,
              target.side == .input,
              start.skillID != target.skillID
        else { return nil }

        return (from: start, to: target)
    }

    func removeEdge(_ edge: SkillEdge) {
        edges.removeAll { $0.id == edge.id }
    }
}


