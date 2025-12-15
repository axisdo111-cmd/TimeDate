//
//  TDOptions.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import Foundation

struct TDOptions {
    var inclusiveDiff: Bool = false

    /// Locale uniquement pour l’affichage
    var locale: Locale = Locale(identifier: "fr_FR")

    /// TimeZone FIXE pour une calculatrice (pas de DST, pas de surprises)
    private let fixedTimeZone = TimeZone(secondsFromGMT: 0)!

    /// Calendar stable, neutre, déterministe
    var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = locale
        cal.timeZone = fixedTimeZone
        return cal
    }
}
