//
//  SkillNodeCard.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


struct SkillNodeCard: View {
    @Environment(SkillComposerModel.self) private var model

    let node: SkillGraphNode

    @State private var dragOffset: CGSize = .zero

    private let cardWidth: CGFloat = 280

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
        }
        .frame(width: cardWidth)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 8)
        .position(
            x: node.position.x + dragOffset.width,
            y: node.position.y + dragOffset.height
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(node.title)
                .font(.headline)

            if let skill = model.skill(for: node.skillID) {
                Text(skill.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.12),
                    Color.teal.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    node.position = GraphPoint(
                        x: node.position.x + value.translation.width,
                        y: node.position.y + value.translation.height
                    )
                    dragOffset = .zero
                }
        )
    }

    private var content: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Inputs")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                if let skill = model.skill(for: node.skillID) {
                    ForEach(skill.declaredInputs) { port in
                        InputPortView(
                            handle: PortHandle(skillID: node.skillID, portID: port.id, side: .input),
                            port: port
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 10) {
                Text("Outputs")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                if let skill = model.skill(for: node.skillID) {
                    ForEach(skill.declaredOutputs) { port in
                        OutputPortView(
                            handle: PortHandle(skillID: node.skillID, portID: port.id, side: .output),
                            port: port
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
    }
}
