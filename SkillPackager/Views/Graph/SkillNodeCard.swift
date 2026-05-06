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
    let portFrames: [PortHandle: CGRect]
    let zoomScale: CGFloat

    @State private var dragAnchorOffset: CGSize?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
        }
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.green.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .position(
            x: node.position.x,
            y: node.position.y
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
            DragGesture(minimumDistance: 0, coordinateSpace: .named("graph-space"))
                .onChanged { value in
                    let unscaledStart = CGPoint(
                        x: value.startLocation.x / zoomScale,
                        y: value.startLocation.y / zoomScale
                    )

                    if dragAnchorOffset == nil {
                        dragAnchorOffset = CGSize(
                            width: unscaledStart.x - node.position.x,
                            height: unscaledStart.y - node.position.y
                        )
                    }

                    guard let dragAnchorOffset else { return }

                    let unscaledCurrent = CGPoint(
                        x: value.location.x / zoomScale,
                        y: value.location.y / zoomScale
                    )

                    var transaction = Transaction()
                    transaction.disablesAnimations = true

                    withTransaction(transaction) {
                        node.position = GraphPoint(
                            x: unscaledCurrent.x - dragAnchorOffset.width,
                            y: unscaledCurrent.y - dragAnchorOffset.height
                        )
                    }
                }
                .onEnded { _ in
                    dragAnchorOffset = nil
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
                            port: port,
                            portFrames: portFrames
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
    }
}
