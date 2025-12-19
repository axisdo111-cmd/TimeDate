//
//  TDLayout.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 19/12/2025.
//

import SwiftUI

struct TDLayout {
    let isSmallPhone: Bool

    let vSpacing: CGFloat
    let displayHeight: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let showWeekdayBarFR: Bool
 
    init(geo: GeometryProxy) {
        let h = geo.size.height

        // iPhone SE (2e/3e gen) ~ 667pt, SE 1st gen ~ 568pt
        self.isSmallPhone = h <= 700

        self.vSpacing = isSmallPhone ? 12 : 18
        self.displayHeight = isSmallPhone ? 115 : 135
        self.topPadding = isSmallPhone ? 6 : 10
        // Réduction du bas automatiquement selon SE ou Pro Max
        self.bottomPadding = isSmallPhone ? 8 : 18


        // ✅ on retire la WeekdayBarView sur petits écrans
        self.showWeekdayBarFR = !isSmallPhone
    }
}
