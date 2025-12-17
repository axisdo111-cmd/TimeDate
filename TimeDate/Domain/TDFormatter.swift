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
            return TDDisplayResult(
                main: formatHumanDuration(seconds: d.seconds),
                secondary: nil
            )

        case .date(let date):
            return TDDisplayResult(
                main: formatDate(date),
                secondary: nil
            )
            
        case .calendar(let q):   // ✅ NOUVEAU
                return TDDisplayResult(
                    main: formatCalendarQuantity(q),
                    secondary: nil
                )
        }
    }

    // MARK: - Date

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = options.locale
        f.calendar = options.calendar
        f.timeZone = .current
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: date)
    }

    // MARK: - Decimal

    private func formatDecimal(_ n: Decimal) -> String {
        let ns = NSDecimalNumber(decimal: n)

        if ns == ns.rounding(accordingToBehavior: nil) {
            return "\(ns.intValue)"
        }

        let nf = NumberFormatter()
        nf.locale = options.locale
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 12
        nf.usesGroupingSeparator = false

        return nf.string(from: ns) ?? ns.stringValue
    }

    // MARK: - Duration (⭐ PRO core)

    private func formatHumanDuration(seconds: Int) -> String {
        guard seconds > 0 else { return "0 Days" }

        var remaining = seconds

        let daysTotal = remaining / 86_400
        remaining %= 86_400

        let hours = remaining / 3_600
        remaining %= 3_600

        let minutes = remaining / 60
        let secs = remaining % 60

        // 📆 Décomposition calendaire (years / months / days)
        let cal = options.calendar
        let ref = Date(timeIntervalSince1970: 0)
        let target = cal.date(byAdding: .day, value: daysTotal, to: ref)!

        let comps = cal.dateComponents([.year, .month, .day], from: ref, to: target)

        var parts: [String] = []

        if let y = comps.year, y != 0 { parts.append("\(y) Years") }
        if let m = comps.month, m != 0 { parts.append("\(m) Months") }
        if let d = comps.day, d != 0 { parts.append("\(d) Days") }

        let timePart = String(format: "%02d:%02d:%02d", hours, minutes, secs)

        if timePart != "00:00:00" {
            parts.append("- \(timePart)")
        }

        return parts.joined(separator: " ")
    }
    
    // Quantité Calendar
    private func formatCalendarQuantity(_ q: TDCalendarQuantity) -> String {
        var parts: [String] = []

        if q.years != 0 {
            parts.append("\(q.years) \(q.years == 1 ? "Year" : "Years")")
        }
        if q.months != 0 {
            parts.append("\(q.months) \(q.months == 1 ? "Month" : "Months")")
        }
        if q.weeks != 0 {
            parts.append("\(q.weeks) \(q.weeks == 1 ? "Week" : "Weeks")")
        }
        if q.days != 0 {
            parts.append("\(q.days) \(q.days == 1 ? "Day" : "Days")")
        }

        return parts.isEmpty ? "0 Days" : parts.joined(separator: " ")
    }

}
