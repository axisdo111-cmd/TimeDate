//
//  TDFormatter.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

//
//  TDFormatter.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import Foundation

struct TDFormatter {

    let options: TDOptions

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    
    // MARK: - Public API

    func displayResult(_ value: TDValue) -> TDDisplayResult {
        switch value {

        case .number(let n):
            return TDDisplayResult(main: formatDecimal(n), secondary: nil)

        case .duration(let d):
            return TDDisplayResult(main: formatDuration(d), secondary: nil)

        case .date(let date):
             let cal = options.calendar
             let comps = cal.dateComponents([.hour, .minute, .second], from: date)

             let hasTime =
                 (comps.minute ?? 0) != 0 ||
                 (comps.second ?? 0) != 0

             let main = Self.dateFormatter.string(from: date)
             let secondary = hasTime
                 ? Self.timeFormatter.string(from: date)
                 : nil

             return TDDisplayResult(
                 main: main,
                 secondary: secondary
             )
        }
    }

    /// Représentation "inline" pour l'expression (ex: "2.3 + 6", "2025/12/14 - 2020/01/01", "5 Days + 2 Hours")
    func string(_ value: TDValue) -> String {
        switch value {
        case .number(let n):
            return formatDecimal(n)
        case .duration(let d):
            return formatDuration(d)
        case .date(let date):
            // format entrée YYYY/MM/DD (plus lisible pour une calculatrice)
            let f = DateFormatter()
            f.locale = Locale(identifier: "fr_FR")
            f.calendar = options.calendar
            f.timeZone = options.calendar.timeZone
            f.dateFormat = "yyyy/MM/dd"
            return f.string(from: date)
        }
    }

    // MARK: - Decimal formatting (PRO)

    private func formatDecimal(_ n: Decimal) -> String {
        let ns = NSDecimalNumber(decimal: n)

        // Entier => pas de décimales
        if ns == ns.rounding(accordingToBehavior: nil) {
            return "\(ns.intValue)"
        }

        // Décimal => affichage propre, stable, sans bruit flottant
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "fr_FR")
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 12
        nf.usesGroupingSeparator = false

        return nf.string(from: ns) ?? ns.stringValue
    }

    // MARK: - Duration formatting (PRO Premium)

    private func formatDuration(_ d: TDDuration) -> String {
        let comps = d.components()

        let totalDays = comps.day ?? 0

        // Décomposition lisible (affichage uniquement)
        let years  = totalDays / 365
        let rem1   = totalDays % 365

        let months = rem1 / 30
        let days   = rem1 % 30

        let hours   = comps.hour   ?? 0
        let minutes = comps.minute ?? 0
        let seconds = comps.second ?? 0

        var parts: [String] = []

        if years   > 0 { parts.append("\(years) Year\(years > 1 ? "s" : "")") }
        if months  > 0 { parts.append("\(months) Month\(months > 1 ? "s" : "")") }
        if days    > 0 { parts.append("\(days) Day\(days > 1 ? "s" : "")") }

        if hours   > 0 { parts.append("\(hours) Hour\(hours > 1 ? "s" : "")") }
        if minutes > 0 { parts.append("\(minutes) Minute\(minutes > 1 ? "s" : "")") }
        if seconds > 0 { parts.append("\(seconds) Second\(seconds > 1 ? "s" : "")") }

        return parts.isEmpty ? "0 Days" : parts.joined(separator: " ")
    }

    // MARK: - Weekday helper (pour surbrillance)

    func weekday(_ date: Date) -> Int {
        // iOS: 1 = Dimanche ... 7 = Samedi
        options.calendar.component(.weekday, from: date) - 1  // 0..6
    }
}
