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
    // Ipad
    let keyWidthMultiplier: CGFloat
         
    init(geo: GeometryProxy) {
        let w = geo.size.width
        let h = geo.size.height

        // Classes d'appareils
        let isSE = h <= 700
        let isIPad = w >= 700   // 👈 clé du problème

        self.isSmallPhone = isSE

        // 🎹 Largeur des touches
        self.keyWidthMultiplier = isIPad ? 2.0 : 1.0

        // Spacing & display
        self.vSpacing = isSE ? 12 : 18
        self.displayHeight = isSE ? 115 : 135
        self.topPadding = isSE ? 6 : 10
        self.bottomPadding = isSE ? 8 : 18

        // Weekday FR uniquement sur écrans confortables
        self.showWeekdayBarFR = !isSE
    }
}
