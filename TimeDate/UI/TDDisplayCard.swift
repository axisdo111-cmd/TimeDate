//
//  TDDisplayCard.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import SwiftUI

struct TDDisplayCard: View {

    let mode: TDMode
    let expression: String
    let result: TDDisplayResult
    let didJustEvaluate: Bool
    let fixedHeight: CGFloat?

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {

            // ─────────────────────────────
            // Ligne intermédiaire (TOUJOURS PRÉSENTE)
            // ─────────────────────────────
            Text(result.secondary ?? " ")
                .font(intermediateFont)
                .foregroundStyle(lcdSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.70)

            // ─────────────────────────────
            // Résultat principal (TOUJOURS PRÉSENT)
            // ─────────────────────────────
            Text(result.main.isEmpty ? "0" : result.main)
                .font(mainFont)
                .foregroundStyle(lcdMain)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.45)
                .contentTransition(.numericText())

            // ─────────────────────────────
            // Ligne secondaire / expression (TOUJOURS PRÉSENTE)
            // ─────────────────────────────
            Text(expression.isEmpty ? " " : expression)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundStyle(lcdSecondary.opacity(0.85))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(18)
        // .frame(height: 135) // ⬅️ HAUTEUR FIXE (celle que tu aimes)
        .frame(height: fixedHeight) // Variable en fonction Iphone SE ou Pro Max
        .background(LCDBackground())
        .animation(.easeOut(duration: 0.15), value: result.main)
        .animation(.easeOut(duration: 0.15), value: result.secondary)
        .allowsHitTesting(false)   // 🔑 CRITIQUE
    }

    // MARK: - Fonts

    private var mainFont: Font {
        if mode == .calc {
            // 🔥 CALC : très gros chiffres
            return .system(
                size: scheme == .dark ? 54 : 50,
                weight: .medium,
                design: .monospaced
            )
        } else {
            // DATE-TIME : lisible mais plus compact
            return .system(
                size: scheme == .dark ? 36 : 34,
                weight: .medium,
                design: .rounded
            )
        }
    }

    private var intermediateFont: Font {
        .system(
            size: scheme == .dark ? 19 : 18,
            weight: .medium,
            design: .rounded
        )
    }

    // MARK: - LCD colors

    private var lcdMain: Color {
        scheme == .dark
            ? Color(red: 0.82, green: 0.94, blue: 0.80)
            : Color(red: 0.12, green: 0.24, blue: 0.14)
    }

    private var lcdSecondary: Color {
        scheme == .dark
            ? Color(red: 0.70, green: 0.86, blue: 0.68)
            : Color(red: 0.16, green: 0.30, blue: 0.18)
    }
}
