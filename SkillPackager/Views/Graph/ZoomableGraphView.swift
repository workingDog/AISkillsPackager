//
//  ZoomableGraphView.swift
//  SkillPackager
//
//  Created by Ringo Wathelet on 2026/05/06.
//
import SwiftUI


struct ZoomableSkillGraphView: View {
    private let baseCanvasSize = CGSize(width: 2400, height: 1600)

    @State private var zoomScale: CGFloat = 1
    @State private var gestureStartZoom: CGFloat = 1

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    zoomScale = max(0.5, zoomScale - 0.1)
                    gestureStartZoom = zoomScale
                } label: {
                    Image(systemName: "minus.magnifyingglass")
                }

                Text("\(Int(zoomScale * 100))%")
                    .font(.caption.monospacedDigit())
                    .frame(minWidth: 48)

                Button {
                    zoomScale = min(2.5, zoomScale + 0.1)
                    gestureStartZoom = zoomScale
                } label: {
                    Image(systemName: "plus.magnifyingglass")
                }

                Button("Reset") {
                    zoomScale = 1
                    gestureStartZoom = 1
                }

                Spacer()
            }
            .buttonStyle(.bordered)

            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    SkillGraphEditorView(
                        canvasSize: baseCanvasSize,
                        zoomScale: zoomScale
                    )
                    .frame(width: baseCanvasSize.width, height: baseCanvasSize.height)
                    .scaleEffect(zoomScale, anchor: .topLeading)
                }
                .frame(
                    width: baseCanvasSize.width * zoomScale,
                    height: baseCanvasSize.height * zoomScale,
                    alignment: .topLeading
                )
                .padding(24)
            }
            .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .gesture(magnifyGesture)
        }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                zoomScale = min(max(gestureStartZoom * value.magnification, 0.5), 2.5)
            }
            .onEnded { value in
                zoomScale = min(max(gestureStartZoom * value.magnification, 0.5), 2.5)
                gestureStartZoom = zoomScale
            }
    }
}
