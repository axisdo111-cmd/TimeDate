//
//  LCDColors.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 19/12/2025.
//

import SwiftUI

extension Color {

    /// Couleur des cristaux LCD (texte normal)
    static let lcdCrystal = Color(
        red: 0.70,
        green: 0.86,
        blue: 0.72
    )

    /// Couleur utilisée pour le texte inversé
    /// (doit se fondre dans le LCDBackground)
    static let lcdBackgroundInk = Color(
        red: 0.18,
        green: 0.24,
        blue: 0.18
    )
}
