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

    // MARK: - Public API

    func displayResult(_ value: TDValue) -> TDDisplayResult {
        switch value {

        case .number(let n):
            return TDDisplayResult(main: formatDecimal(n), secondary: nil)

        case .duration(let d):
            return TDDisplayResult(main: formatDuration(d), secondary: nil)

        case .date(let date):
            // Date en principal, heure en secondaire si elle n'est pas 00:00:00
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "fr_FR")
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none

            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "fr_FR")
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short

            let main = dateFormatter.string(from: date)

            let cal = options.calendar
            let comps = cal.dateComponents([.hour, .minute, .second], from: date)
            let hasTime = (comps.hour ?? 0) != 0 || (comps.minute ?? 0) != 0 || (comps.second ?? 0) != 0

            return TDDisplayResult(
                main: main,
                secondary: hasTime ? timeFormatter.string(from: date) : nil
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

    // MARK: - Duration formatting (Years/Months/Weeks/Days/Hours/Minutes/Seconds)

    private func formatDuration(_ d: TDDuration) -> String {
        let s = max(0, d.seconds)

        // On décompose via Calendar (gregorien) pour avoir un rendu "humain"
        // (NB: months/years dépendent du calendrier, c'est voulu ici)
        let comps = TDDuration(seconds: s).components(calendar: options.calendar)

        let years = comps.year ?? 0
        let months = comps.month ?? 0

        // day = nombre total de jours "calendaires" dans l'intervalle,
        // on le transforme en weeks + days pour coller à ton UI
        let totalDays = comps.day ?? 0
        let weeks = totalDays / 7
        let days = totalDays % 7

        let hours = comps.hour ?? 0
        let minutes = comps.minute ?? 0
        let seconds = comps.second ?? 0

        var parts: [String] = []
        append(&parts, years, "Year")
        append(&parts, months, "Month")
        append(&parts, weeks, "Week")
        append(&parts, days, "Day")
        append(&parts, hours, "Hour")
        append(&parts, minutes, "Minute")
        append(&parts, seconds, "Second")

        // Si tout est à 0 (durée nulle), on affiche "0 Seconds"
        if parts.isEmpty { return "0 Seconds" }
        return parts.joined(separator: " ")
    }

    private func append(_ parts: inout [String], _ value: Int, _ unit: String) {
        guard value != 0 else { return }
        if value == 1 {
            parts.append("1 \(unit)")
        } else {
            parts.append("\(value) \(unit)s")
        }
    }

    // MARK: - Weekday helper (pour surbrillance)

    func weekday(_ date: Date) -> Int {
        // iOS: 1 = Dimanche ... 7 = Samedi
        options.calendar.component(.weekday, from: date)
    }
}
