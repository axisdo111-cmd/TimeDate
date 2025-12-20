//
//  WeekdayDigitalENView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 19/12/2025.
//

import SwiftUI

struct WeekdayDigitalENView: View {

    let activeWeekday: Int?   // nil = passif

    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 8) {
            ForEach(days.indices, id: \.self) { index in
                Text(days[index])
                    .font(
                        .system(
                            size: 13,
                            weight: fontWeight(for: index),
                            design: .monospaced
                        )
                    )
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .foregroundColor(textColor(for: index))
                    .background(cartouche(for: index))
                    .cornerRadius(6)
            }
        }
    }

    // MARK: - Styles
    private var passiveTextColor: Color {
        scheme == .light
            ? Color.blue.opacity(0.55)     // bleu outre-mer clair
            : Color.lcdCrystal.opacity(0.55)
    }

    private var activeCartoucheColor: Color {
        scheme == .light
            ? Color.blue.opacity(0.35)     // 👈 même famille, plus clair
            : Color.lcdCrystal.opacity(0.40)
    }

    private var activeTextColor: Color {
        Color.lcdCrystal   // 👈 vert LCD clair (comme la date)
    }

    private func cartouche(for index: Int) -> some View {
        Group {
            if index == activeWeekday {
                activeCartoucheColor
            } else {
                Color.clear
            }
        }
    }

    private func textColor(for index: Int) -> Color {
        if index == activeWeekday {
            return activeTextColor          // vert LCD
        } else {
            return passiveTextColor         // bleu clair
        }
    }

    private func fontWeight(for index: Int) -> Font.Weight {
        index == activeWeekday ? .bold : .medium
    }

}
