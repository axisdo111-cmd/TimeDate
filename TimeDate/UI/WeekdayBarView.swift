//
//  WeekdayBarView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import SwiftUI

struct WeekdayBarView: View {
    /// weekday Calendar : 1 = Dimanche ... 7 = Samedi
    let active: Int?

    private let days = ["Dim","Lun","Mar","Mer","Jeu","Ven","Sam"]

    private var activeIndex: Int? {
        guard let active else { return nil }
        return active - 1   // ✅ conversion Calendar → index tableau
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(days.indices, id: \.self) { i in
                Text(days[i])
                    .font(.footnote.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(
                                activeIndex == i
                                ? Color.accentColor.opacity(0.25)
                                : Color(.tertiarySystemFill)
                            )
                    )
            }
        }
    }
}

