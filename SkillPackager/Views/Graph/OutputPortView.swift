//
//  OutputPortView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI



struct OutputPortView: View {
    @Environment(SkillComposerModel.self) private var model

    let handle: PortHandle
    let port: SkillPort
    let portFrames: [PortHandle: CGRect]

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(port.name)
                    .font(.caption.weight(.medium))
                Text(port.type.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Circle()
                .fill(isActive ? .accentColor : port.type.color)
                .frame(width: 12, height: 12)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(isActive ? Color.accentColor.opacity(0.14) : Color.black.opacity(0.04))
        )
        .contentShape(Capsule())
        .highPriorityGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("graph-space"))
                .onChanged { value in
                    if model.graphState.dragStartPort != handle {
                        model.graphState.beginEdgeDrag(
                            from: handle,
                            at: portCenter(for: handle) ?? value.startLocation
                        )
                    }

                    let hovered = nearestInputHandle(to: value.location)
                    model.graphState.updateEdgeDrag(
                        point: value.location,
                        hoveredInput: hovered
                    )
                }
                .onEnded { value in
                    let hovered = nearestInputHandle(to: value.location)
                    model.handleEdgeDragEnd(over: hovered)
                }
        )
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: PortFramePreferenceKey.self,
                    value: [handle: proxy.frame(in: .named("graph-space"))]
                )
            }
        )
    }

    private var isActive: Bool {
        model.graphState.dragStartPort == handle
    }

    private func portCenter(for handle: PortHandle) -> CGPoint? {
        guard let frame = portFrames[handle] else { return nil }
        return CGPoint(x: frame.midX, y: frame.midY)
    }

    private func nearestInputHandle(to point: CGPoint) -> PortHandle? {
        let threshold: CGFloat = 36

        let allInputs = model.selectedSkills.flatMap { skill in
            skill.declaredInputs.map {
                PortHandle(skillID: skill.id, portID: $0.id, side: .input)
            }
        }

        return allInputs.first { handle in
            guard let frame = portFrames[handle] else { return false }
            let dx = frame.midX - point.x
            let dy = frame.midY - point.y
            return sqrt(dx * dx + dy * dy) < threshold
        }
    }
}
