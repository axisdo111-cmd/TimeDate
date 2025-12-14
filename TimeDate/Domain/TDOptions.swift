//
//  TDOptions.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import Foundation

struct TDOptions {
    var inclusiveDiff: Bool = false

    var locale: Locale = Locale(identifier: "fr_FR")
    var timeZone: TimeZone = .current

    /// Calendar stable (pas recréé à chaque accès)
    var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = locale
        cal.timeZone = timeZone
        return cal
    }
}
