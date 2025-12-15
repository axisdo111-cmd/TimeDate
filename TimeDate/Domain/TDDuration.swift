//
//  TDDuration.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//
//  PRO / Premium – Calendar-exact & stable
//

import Foundation

struct TDDuration: Equatable {

    /// Stockage canonique : secondes (>= 0)
    let seconds: Int

    // MARK: - Initialisation simple (secondes)
    init(seconds: Int = 0) {
        self.seconds = max(0, seconds)
    }

    // MARK: - Initialisation calendaire exacte (PRO Premium)
    init(
        years: Int = 0,
        months: Int = 0,
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0,
        reference: Date,
        calendar: Calendar
    ) {
        var date = reference

        date = calendar.date(byAdding: .year,   value: years,   to: date) ?? date
        date = calendar.date(byAdding: .month,  value: months,  to: date) ?? date
        date = calendar.date(byAdding: .day,    value: days,    to: date) ?? date
        date = calendar.date(byAdding: .hour,   value: hours,   to: date) ?? date
        date = calendar.date(byAdding: .minute, value: minutes, to: date) ?? date
        date = calendar.date(byAdding: .second, value: seconds, to: date) ?? date

        self.seconds = max(0, Int(date.timeIntervalSince(reference)))
    }

    // MARK: - Décomposition simple (affichage bas niveau)
    func components() -> DateComponents {
        var remaining = seconds

        let days = remaining / 86_400
        remaining %= 86_400

        let hours = remaining / 3_600
        remaining %= 3_600

        let minutes = remaining / 60
        let seconds = remaining % 60

        var comps = DateComponents()
        comps.day = days
        comps.hour = hours
        comps.minute = minutes
        comps.second = seconds
        return comps
    }
}
