//
//  TDDuration.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import Foundation

struct TDDuration: Equatable {

    /// Stockage canonique : secondes
    var seconds: Int

    init(seconds: Int = 0) {
        self.seconds = max(0, seconds)
    }

    // MARK: - Construction à partir de composants humains
    init(
        years: Int = 0,
        months: Int = 0,
        weeks: Int = 0,
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0,
        reference: Date = Date(),
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) {
        var date = reference

        date = calendar.date(byAdding: .year, value: years, to: date) ?? date
        date = calendar.date(byAdding: .month, value: months, to: date) ?? date
        date = calendar.date(byAdding: .weekOfYear, value: weeks, to: date) ?? date
        date = calendar.date(byAdding: .day, value: days, to: date) ?? date
        date = calendar.date(byAdding: .hour, value: hours, to: date) ?? date
        date = calendar.date(byAdding: .minute, value: minutes, to: date) ?? date
        date = calendar.date(byAdding: .second, value: seconds, to: date) ?? date

        self.seconds = max(
            0,
            Int(date.timeIntervalSince(reference))
        )
    }

    // MARK: - Décomposition lisible (affichage)
    func components(calendar: Calendar = Calendar(identifier: .gregorian)) -> DateComponents {
        let ref = Date(timeIntervalSince1970: 0)
        let target = Date(timeIntervalSince1970: TimeInterval(seconds))

        return calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: ref,
            to: target
        )
    }
}
