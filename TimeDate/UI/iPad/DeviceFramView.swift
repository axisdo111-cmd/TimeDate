//
//  DeviceFramView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 26/12/2025.
//
//  Cadre adaptatif iPad (9" → 13")
//  Purement esthétique – aucun layout interne
//

import SwiftUI

// MARK: - Frame Style

enum DeviceFrameStyle: String, CaseIterable, Identifiable {
    case blackStandard
    case casioMetal
    case darkPro
    case customPreset

    var id: String { rawValue }
}

// MARK: - DeviceFrameView

struct DeviceFrameView<Content: View>: View {

    let style: DeviceFrameStyle
    let content: Content

    init(
        style: DeviceFrameStyle = .blackStandard,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            let metrics = frameMetrics(for: geo.size)

            ZStack {
                // Bezel background
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .fill(bezelFill(for: style))
                    .overlay(
                        RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                            .stroke(bezelStroke(for: style), lineWidth: metrics.strokeWidth)
                    )
                    .shadow(radius: metrics.outerShadow)

                // Content inset
                content
                    .padding(metrics.thickness)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Frame Metrics

private struct FrameMetrics {
    let thickness: CGFloat
    let cornerRadius: CGFloat
    let strokeWidth: CGFloat
    let outerShadow: CGFloat
}

// MARK: - Metrics computation (9" → 13")

private func frameMetrics(for size: CGSize) -> FrameMetrics {

    let shortestSide = min(size.width, size.height)

    // Approximation robuste iPad :
    // ~740 pt (9") → ~1024 pt (13")
    let minSide: CGFloat = 740
    let maxSide: CGFloat = 1024

    let progress = max(0, min(1, (shortestSide - minSide) / (maxSide - minSide)))

    let thickness = lerp(from: 6, to: 32, t: progress)
    let radius    = lerp(from: 16, to: 30, t: progress)

    return FrameMetrics(
        thickness: thickness,
        cornerRadius: radius,
        strokeWidth: 1,
        outerShadow: 6
    )
}

private func lerp(from a: CGFloat, to b: CGFloat, t: CGFloat) -> CGFloat {
    a + (b - a) * t
}

// MARK: - Style Rendering

private func bezelFill(for style: DeviceFrameStyle) -> AnyShapeStyle {
    switch style {

    case .blackStandard:
        return AnyShapeStyle(
            Color.black.opacity(0.94)
        )

    case .casioMetal:
        // Aluminium brossé “soft” sans asset
        return AnyShapeStyle(
            LinearGradient(
                colors: [
                    Color(.systemGray4),
                    Color(.systemGray3),
                    Color(.systemGray5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )

    case .darkPro:
        return AnyShapeStyle(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.92),
                    Color(.systemGray6).opacity(0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )

    case .customPreset:
        // Placeholder sûr (modifiable plus tard)
        return AnyShapeStyle(
            Color(.systemIndigo).opacity(0.35)
        )
    }
}

private func bezelStroke(for style: DeviceFrameStyle) -> Color {
    switch style {
    case .blackStandard:
        return Color.white.opacity(0.08)
    case .casioMetal:
        return Color.black.opacity(0.20)
    case .darkPro:
        return Color.white.opacity(0.06)
    case .customPreset:
        return Color.white.opacity(0.12)
    }
}
