//
//  TDButtonStyle.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import SwiftUI

struct TDKeyButtonStyle: ButtonStyle {

    enum Kind {
        case number
        case unit
        case op
        case equals
        case danger
    }

    let kind: Kind
    let cornerRadius: CGFloat = 18

    @Environment(\.colorScheme) private var scheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(
                ZStack {
                    // Fond principal
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(background)

                    // Highlight haut (effet relief)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(scheme == .dark ? 0.10 : 0.25),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .blendMode(.overlay)

                    // Cadre (important en mode jour)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            Color.black.opacity(scheme == .dark ? 0.30 : 0.15),
                            lineWidth: 1
                        )
                }
            )
            // Ombre basse = épaisseur
            .shadow(
                color: Color.black.opacity(scheme == .dark ? 0.55 : 0.25),
                radius: configuration.isPressed ? 2 : 6,
                x: 0,
                y: configuration.isPressed ? 1 : 5
            )
            // Effet pression
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    // MARK: - Colors

    private var background: Color {
        switch kind {
        case .number, .unit:
            return Color(.secondarySystemBackground)
        case .op:
            return Color.blue
        case .equals:
            return Color.orange
        case .danger:
            return Color.red
        }
    }

    private var foreground: Color {
        switch kind {
        case .number, .unit:
            return Color.blue
        case .op, .equals, .danger:
            return .white
        }
    }
}
