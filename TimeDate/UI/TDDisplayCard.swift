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

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {

            // Badge mode
            HStack {
                Text(mode == .calc ? "CALC" : "DATE-TIME")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color(.tertiarySystemFill))
                    )
                Spacer()
            }

            // Expression (toujours alignée à droite)
            if !expression.isEmpty {
                Text(expression)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            } else {
                // réserve un petit espace pour éviter que tout “remonte/descende”
                Color.clear.frame(height: 0)
            }

            // Résultat principal
            Text(result.main)
                .font(
                    .system(
                        size: didJustEvaluate ? 52 : 44,
                        weight: .regular,
                        design: .rounded
                    )
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.35)
                .contentTransition(.numericText())

            // Résultat secondaire (DRAFT / heure / durée)
            // Zone réservée stable + adaptation si texte long.
            SecondaryLine(text: result.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 18,
                    x: 0,
                    y: 8
                )
        )
        .animation(.easeOut(duration: 0.2), value: result.main)
        .animation(.easeOut(duration: 0.2), value: result.secondary)
    }
}

private struct SecondaryLine: View {
    let text: String?

    var body: some View {
        ZStack(alignment: .trailing) {

            // Réserve une hauteur stable (évite l'effet yoyo)
            // (on réserve ~1 ligne de title3)
            Text("H")
                .font(.title3)
                .foregroundStyle(.clear)

            if let text, !text.isEmpty {
                // Si c'est une "heure/durée courte" -> monospaced
                // Si c'est un "draft long" -> on laisse wrap/scale propre
                ViewThatFits(in: .horizontal) {

                    // 1) version monospace (pour 00:00:00 / 12 Hours 3 Minutes etc.)
                    Text(text)
                        .font(.title3.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)

                    // 2) version “longue” (draft type "1967 Years 3 Months 29 Days")
                    Text(text)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                }
                .transition(.opacity)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
