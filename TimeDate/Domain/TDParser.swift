//
//  TDParser.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

//
//  TDParser.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//
//  PRO / Premium - strict & robust
//

import Foundation

struct TDParser {

    let options: TDOptions

    func parse(_ input: String) throws -> TDValue {

        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ParseError.invalidNumber }

        if trimmed.contains("/") {
            return try parseDate(trimmed)
        }

        if trimmed.contains(":") {
            return try parseTimeAsDuration(trimmed)
        }

        // ✅ Decimal parsing (point) : "12.34"
        // (on garde en_US pour le point, ton UI n’impose pas la virgule)
        guard let decimal = Decimal(string: trimmed, locale: Locale(identifier: "en_US")) else {
            throw ParseError.invalidNumber
        }

        return .number(decimal)
    }

    // MARK: - Date parsing
    // Supporte :
    // - yyyy/MM/dd (ex: 1967/03/29)
    // - dd/MM/yyyy (ex: 29/03/1967) si le premier bloc n'a pas 4 chiffres
    private func parseDate(_ s: String) throws -> TDValue {
        let p = s.split(separator: "/").map { String($0) }
        guard p.count == 3 else { throw ParseError.invalidDate }

        let a = p[0], b = p[1], c = p[2]

        let y: Int
        let m: Int
        let d: Int

        if a.count == 4 {
            // yyyy/MM/dd
            guard let yy = Int(a), let mm = Int(b), let dd = Int(c) else { throw ParseError.invalidDate }
            y = yy; m = mm; d = dd
        } else {
            // dd/MM/yyyy
            guard let dd = Int(a), let mm = Int(b), let yy = Int(c) else { throw ParseError.invalidDate }
            y = yy; m = mm; d = dd
        }

        var comps = DateComponents()
        comps.calendar = options.calendar
        comps.timeZone = options.calendar.timeZone
        comps.year = y
        comps.month = m
        comps.day = d

        guard let date = options.calendar.date(from: comps) else {
            throw ParseError.invalidDate
        }

        return .date(date)
    }

    // MARK: - Time parsing -> Duration (hh:mm[:ss])
    // Interprété comme une durée en secondes (pas une "date")
    private func parseTimeAsDuration(_ s: String) throws -> TDValue {
        let p = s.split(separator: ":").map { String($0) }
        guard p.count == 2 || p.count == 3 else { throw ParseError.invalidTime }

        guard
            let h = Int(p[0]),
            let m = Int(p[1])
        else { throw ParseError.invalidTime }

        let sec = (p.count == 3) ? (Int(p[2]) ?? -1) : 0
        guard sec >= 0 else { throw ParseError.invalidTime }

        // (optionnel) garde-fous simples
        guard (0...59).contains(m), (0...59).contains(sec) else { throw ParseError.invalidTime }

        let total = (h * 3600) + (m * 60) + sec
        return .duration(TDDuration(seconds: total))
    }
}

// MARK: - Parse Errors
enum ParseError: Error {
    case invalidNumber
    case invalidDate
    case invalidTime
}
