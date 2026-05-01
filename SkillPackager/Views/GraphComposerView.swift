//
//  GraphComposerView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import Foundation
import SwiftUI


struct GraphComposerView: View {
    @Environment(SkillComposerModel.self) var model: SkillComposerModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.96, green: 0.97, blue: 0.94),
                            Color(red: 0.92, green: 0.95, blue: 0.98)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Canvas { context, _ in
                for mapping in model.package.mappings {
                    guard let fromNode = model.node(for: mapping.fromSkillID),
                          let toNode = model.node(for: mapping.toSkillID) else { continue }

                    let start = CGPoint(x: fromNode.position.cgPoint.x + 120, y: fromNode.position.cgPoint.y + 44)
                    let end = CGPoint(x: toNode.position.cgPoint.x - 120, y: toNode.position.cgPoint.y + 44)

                    var path = Path()
                    path.move(to: start)
                    path.addCurve(
                        to: end,
                        control1: CGPoint(x: start.x + 80, y: start.y),
                        control2: CGPoint(x: end.x - 80, y: end.y)
                    )

                    context.stroke(
                        path,
                        with: .color(Color.accentColor.opacity(0.75)),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                }
            }

            ForEach(model.graphNodes) { node in
                GraphNodeView(node: node, skill: model.skill(for: node.skillID))
            }
        }
        .frame(minHeight: 520)
        .padding(.vertical, 8)
        .onAppear {
            if model.graphNodes.isEmpty {
                model.rebuildGraph()
            }
        }
    }
}

struct GraphNodeView: View {
    let node: SkillGraphNode
    let skill: SkillDefinition?

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        @Bindable var node = node

        VStack(alignment: .leading, spacing: 8) {
            Text(node.title)
                .font(.headline)

            if let skill {
                Text(skill.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                if !skill.declaredInputs.isEmpty {
                    Text("In: " + skill.declaredInputs.map(\.name).joined(separator: ", "))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if !skill.declaredOutputs.isEmpty {
                    Text("Out: " + skill.declaredOutputs.map(\.name).joined(separator: ", "))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .frame(width: 240, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
        .position(
            x: node.position.cgPoint.x + dragOffset.width,
            y: node.position.cgPoint.y + dragOffset.height
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let final = CGPoint(
                        x: node.position.cgPoint.x + value.translation.width,
                        y: node.position.cgPoint.y + value.translation.height
                    )
                    node.position = GraphPoint(final)
                    dragOffset = .zero
                }
        )
        .animation(.spring(duration: 0.25, bounce: 0.18), value: node.position)
    }
}

