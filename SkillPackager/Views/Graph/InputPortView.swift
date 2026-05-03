//
//  InputPortView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/01.
//
import SwiftUI


struct InputPortView: View {
    @Environment(SkillComposerModel.self) private var model

    let handle: PortHandle
    let port: SkillPort
    
    private var isHovered: Bool {
        model.graphState.hoveredInputPort == handle
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isHovered ? .orange : port.type.color)
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
                .fill(isHovered ? Color.orange.opacity(0.16) : Color.black.opacity(0.04))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(isHovered ? Color.orange.opacity(0.45) : Color.clear, lineWidth: 1.5)
        )
        .contentShape(Capsule())
        .onTapGesture {
            model.graphState.hoveredInputPort = handle
        }
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: PortFramePreferenceKey.self,
                    value: [handle: proxy.frame(in: .named("graph-space"))]
                )
            }
        )
    }

}
