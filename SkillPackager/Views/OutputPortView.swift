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
                .fill(portColor)
                .frame(width: 12, height: 12)
                .overlay {
                    Circle()
                        .stroke(isActive ? Color.accentColor : Color.clear, lineWidth: 2)
                        .frame(width: 18, height: 18)
                }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(isActive ? Color.accentColor.opacity(0.14) : Color.black.opacity(0.04))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(isActive ? Color.accentColor.opacity(0.45) : Color.clear, lineWidth: 1.5)
        )
        .contentShape(Capsule())
        .highPriorityGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("graph-space"))
                .onChanged { value in
                    if model.dragStartPort != handle {
                        model.beginEdgeDrag(from: handle, at: portCenter(for: handle) ?? value.startLocation)
                    }

                    let hovered = nearestInputHandle(to: value.location)
                    model.updateEdgeDrag(point: value.location, hoveredInput: hovered)
                }
                .onEnded { value in
                    let hovered = nearestInputHandle(to: value.location)
                    model.endEdgeDrag(over: hovered)
                }
        )
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        model.registerPortFrame(handle, frame: proxy.frame(in: .named("graph-space")))
                    }
                    .onChange(of: proxy.frame(in: .named("graph-space"))) { _, newFrame in
                        model.registerPortFrame(handle, frame: newFrame)
                    }
            }
        )
    }

    private var isActive: Bool {
        model.dragStartPort == handle
    }

    private var portColor: Color {
        isActive ? .accentColor : port.type.color
    }

    private func portCenter(for handle: PortHandle) -> CGPoint? {
        guard let frame = model.portFrame(for: handle) else { return nil }
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
            guard let frame = model.portFrame(for: handle) else { return false }
            let dx = frame.midX - point.x
            let dy = frame.midY - point.y
            return sqrt(dx * dx + dy * dy) < threshold
        }
    }
}


/*
struct OutputPortView: View {
    @Environment(SkillComposerModel.self) private var model

    let handle: PortHandle
    let port: SkillPort

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
                .fill(port.type.color)
                .frame(width: 12, height: 12)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(Color.black.opacity(0.04))
        )
        .contentShape(Capsule())
        .highPriorityGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("graph-space"))
                .onChanged { value in
                    if model.dragStartPort == nil {
                        model.beginEdgeDrag(from: handle, at: portCenter(for: handle) ?? value.startLocation)
                    }

                    let hovered = nearestInputHandle(to: value.location)
                    model.updateEdgeDrag(point: value.location, hoveredInput: hovered)
                }
                .onEnded { value in
                    let hovered = nearestInputHandle(to: value.location)
                    model.endEdgeDrag(over: hovered)
                }
        )
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        model.registerPortFrame(handle, frame: proxy.frame(in: .named("graph-space")))
                    }
                    .onChange(of: proxy.frame(in: .named("graph-space"))) { _, newFrame in
                        model.registerPortFrame(handle, frame: newFrame)
                    }
            }
        )
    }

    private func portCenter(for handle: PortHandle) -> CGPoint? {
        guard let frame = model.portFrame(for: handle) else { return nil }
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
            guard let frame = model.portFrame(for: handle) else { return false }
            let dx = frame.midX - point.x
            let dy = frame.midY - point.y
            return sqrt(dx * dx + dy * dy) < threshold
        }
    }
}
*/
