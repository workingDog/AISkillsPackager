//
//  SkillGraphEditorView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI

struct SkillGraphEditorView: View {
    @Environment(SkillComposerModel.self) private var model
    @State private var portFrames: [PortHandle: CGRect] = [:]
    

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                background

                ForEach(model.graphNodes) { node in
                    SkillNodeCard(node: node)
                }

                Canvas { context, _ in
                    for edge in model.edges {
                        drawEdge(edge, in: context)
                    }

                    if let start = model.dragStartPort,
                       let startFrame = model.portFrame(for: start),
                       let current = model.dragCurrentPoint {
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

                VStack {
                    HStack {
                        Spacer()
                        validationPanel
                    }
                    Spacer()
                }
                .padding()
            }
            .contentShape(Rectangle())
            .coordinateSpace(name: "graph-space")
            .onAppear {
                if model.graphNodes.isEmpty {
                    model.rebuildGraph()
                }
            }
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.96, blue: 0.93),
                    Color(red: 0.89, green: 0.94, blue: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

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
        .ignoresSafeArea()
    }

    private var validationPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Validation", systemImage: "checklist")
                .font(.headline)

            if model.validationIssues.isEmpty {
                Label("No validation issues", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.subheadline)
            } else {
                ForEach(model.validationIssues.prefix(6)) { issue in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: issue.severity == .error ? "exclamationmark.triangle.fill" : "info.circle.fill")
                            .foregroundStyle(issue.severity == .error ? .red : .orange)
                        Text(issue.message)
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .padding(14)
        .frame(width: 320, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func registerPortFrame(_ handle: PortHandle, frame: CGRect) {
        model.registerPortFrame(handle, frame: frame)
    }

    private func drawEdge(_ edge: SkillEdge, in context: GraphicsContext) {
        let fromHandle = PortHandle(skillID: edge.from.skillID, portID: edge.from.portID, side: .output)
        let toHandle = PortHandle(skillID: edge.to.skillID, portID: edge.to.portID, side: .input)

        guard let fromFrame = model.portFrame(for: fromHandle),
              let toFrame = model.portFrame(for: toHandle) else { return }

        let start = CGPoint(x: fromFrame.midX, y: fromFrame.midY)
        let end = CGPoint(x: toFrame.midX, y: toFrame.midY)

        let path = edgePath(from: start, to: end)
        let issue = model.issue(for: edge.id)

        let color: Color = {
            if let issue {
                return issue.severity == .error ? .red : .orange
            }
            return .accentColor
        }()

        context.stroke(
            path,
            with: .color(color.opacity(0.85)),
            style: StrokeStyle(lineWidth: 4, lineCap: .round)
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

