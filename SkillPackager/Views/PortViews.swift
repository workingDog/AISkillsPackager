//
//  PortViews.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


/*
struct InputPortView: View {
    @Environment(SkillComposerModel.self) private var model

    let handle: PortHandle
    let port: SkillPort
    let registerFrame: (PortHandle, CGRect) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(fillColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(port.name)
                    .font(.caption.weight(.medium))
                Text(port.type.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if port.isRequired {
                Image(systemName: "asterisk.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(isHovered ? Color.orange.opacity(0.14) : Color.black.opacity(0.04))
        )
        .overlay(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        registerFrame(handle, proxy.frame(in: .named("graph-space")))
                    }
                    .onChange(of: proxy.frame(in: .named("graph-space"))) { _, newFrame in
                        registerFrame(handle, newFrame)
                    }
            }
        )
        .onTapGesture {
            model.hoveredInputPort = handle
        }
    }

    private var isHovered: Bool {
        model.hoveredInputPort == handle
    }

    private var fillColor: Color {
        isHovered ? .orange : port.type.color
    }
}

struct OutputPortView: View {
    @Environment(SkillComposerModel.self) private var model

    let handle: PortHandle
    let port: SkillPort
    let registerFrame: (PortHandle, CGRect) -> Void

    @State private var currentLocation: CGPoint = .zero

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
        .overlay(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        registerFrame(handle, proxy.frame(in: .named("graph-space")))
                    }
                    .onChange(of: proxy.frame(in: .named("graph-space"))) { _, newFrame in
                        registerFrame(handle, newFrame)
                    }
            }
        )
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("graph-space"))
                .onChanged { value in
                    currentLocation = value.location
                    let hovered = nearestInputHandle(to: value.location)
                    model.beginEdgeDrag(from: handle, at: value.startLocation)
                    model.updateEdgeDrag(point: value.location, hoveredInput: hovered)
                }
                .onEnded { value in
                    let hovered = nearestInputHandle(to: value.location)
                    model.endEdgeDrag(over: hovered)
                }
        )
    }

    private func nearestInputHandle(to point: CGPoint) -> PortHandle? {
        let threshold: CGFloat = 26

        let allInputs = model.selectedSkills.flatMap { skill in
            skill.declaredInputs.map { PortHandle(skillID: skill.id, portID: $0.id, side: .input) }
        }

        return allInputs.first { handle in
            guard let frame = portFrame(for: handle) else { return false }
            return hypot(frame.midX - point.x, frame.midY - point.y) < threshold
        }
    }

    private func portFrame(for handle: PortHandle) -> CGRect? {
        model.portFrame(for: handle)
    }

}

*/
