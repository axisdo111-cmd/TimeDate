//
//  LCDBackground.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 17/12/2025.
//

import SwiftUI

struct LCDBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(lcdGradient)
            .overlay(lcdTexture)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
            )
    }

    private var lcdGradient: LinearGradient {
        let top = scheme == .dark
            ? Color(red: 0.20, green: 0.26, blue: 0.20)
            : Color(red: 0.88, green: 0.92, blue: 0.86)

        let bottom = scheme == .dark
            ? Color(red: 0.14, green: 0.20, blue: 0.14)
            : Color(red: 0.82, green: 0.88, blue: 0.80)

        return LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)
    }

    private var lcdTexture: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.18),
                Color.clear,
                Color.black.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blendMode(.overlay)
    }
}


private struct Scanlines: View {
    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let lineHeight: CGFloat = 2
            let gap: CGFloat = 4
            let step = lineHeight + gap
            let count = Int(h / step) + 1

            VStack(spacing: gap) {
                ForEach(0..<count, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.25))
                        .frame(height: lineHeight)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
