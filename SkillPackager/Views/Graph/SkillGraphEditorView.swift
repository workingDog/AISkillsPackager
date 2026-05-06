//
//  SkillGraphEditorView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


struct PortFramePreferenceKey: PreferenceKey {
    static var defaultValue: [PortHandle: CGRect] = [:]

    static func reduce(value: inout [PortHandle: CGRect], nextValue: () -> [PortHandle: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

struct SkillGraphEditorView: View {
    @Environment(SkillComposerModel.self) private var model
    @State private var portFrames: [PortHandle: CGRect] = [:]

    let canvasSize: CGSize
    let zoomScale: CGFloat

    var body: some View {
        ZStack {
            background

            ForEach(model.graphState.graphNodes) { node in
                SkillNodeCard(
                    node: node,
                    portFrames: portFrames,
                    zoomScale: zoomScale
                )
            }

            Canvas { context, _ in
                for edge in model.graphState.edges {
                    drawEdge(edge, in: context)
                }

                if let start = model.graphState.dragStartPort,
                   let startFrame = portFrames[start],
                   let current = model.graphState.dragCurrentPoint {
                    let startPoint = CGPoint(x: startFrame.midX, y: startFrame.midY)
                    let path = edgePath(from: startPoint, to: current)

                    context.stroke(
                        path,
                        with: .color(.accentColor.opacity(0.7)),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 6])
                    )
                }
            }
            .allowsHitTesting(false)
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .coordinateSpace(name: "graph-space")
        .transaction { transaction in
            transaction.animation = nil
        }
        .onPreferenceChange(PortFramePreferenceKey.self) { newFrames in
            portFrames = newFrames
        }
        .onAppear {
            if model.graphState.graphNodes.isEmpty {
                model.graphState.rebuildGraph(from: model.packageState.package.skills)
            }
        }
    }

    private var background: some View {
        ZStack {
            Color.blue.opacity(0.15)

            Canvas { context, size in
                let spacing: CGFloat = 28

                for x in stride(from: 0, through: size.width, by: spacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(.black.opacity(0.04)), lineWidth: 1)
                }

                for y in stride(from: 0, through: size.height, by: spacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(.black.opacity(0.04)), lineWidth: 1)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func drawEdge(_ edge: SkillEdge, in context: GraphicsContext) {
        let fromHandle = PortHandle(skillID: edge.from.skillID, portID: edge.from.portID, side: .output)
        let toHandle = PortHandle(skillID: edge.to.skillID, portID: edge.to.portID, side: .input)

        guard let fromFrame = portFrames[fromHandle],
              let toFrame = portFrames[toHandle] else { return }

        let start = CGPoint(x: fromFrame.midX, y: fromFrame.midY)
        let end = CGPoint(x: toFrame.midX, y: toFrame.midY)
        let path = edgePath(from: start, to: end)
        let issue = model.graphState.issue(for: edge.id)
        let isSelected = model.graphState.selectedEdgeID == edge.id

        let color: Color = {
            if let issue {
                return issue.severity == .error ? .red : .orange
            }
            return isSelected ? .green : .accentColor
        }()

        context.stroke(
            path,
            with: .color(color.opacity(0.9)),
            style: StrokeStyle(lineWidth: isSelected ? 6 : 4, lineCap: .round)
        )
    }

    private func edgePath(from start: CGPoint, to end: CGPoint) -> Path {
        var path = Path()
        let dx = max(80, abs(end.x - start.x) * 0.45)
        path.move(to: start)
        path.addCurve(
            to: end,
            control1: CGPoint(x: start.x + dx, y: start.y),
            control2: CGPoint(x: end.x - dx, y: end.y)
        )
        return path
    }
}
