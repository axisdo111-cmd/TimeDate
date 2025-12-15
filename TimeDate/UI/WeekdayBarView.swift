//
//  WeekdayBarView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import SwiftUI

struct WeekdayBarView: View {
    /// Index UI : 0 = Dim ... 6 = Sam
    let active: Int?

    private let days = ["Dim","Lun","Mar","Mer","Jeu","Ven","Sam"]

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
                                active == i
                                ? Color.accentColor.opacity(0.25)
                                : Color(.tertiarySystemFill)
                            )
                    )
            }
        }
    }
}
