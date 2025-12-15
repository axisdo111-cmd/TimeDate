//
//  TDCalcEngine.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import Foundation

struct TDCalcEngine {

    let options: TDOptions

    func compute(_ a: TDValue, _ op: TDOperator, _ b: TDValue) throws -> TDValue {

        switch (a, op, b) {

        // MARK: - Numbers (Decimal)
        case let (.number(x), .add, .number(y)):
            return .number(x + y)

        case let (.number(x), .sub, .number(y)):
            return .number(x - y)

        case let (.number(x), .mul, .number(y)):
            return .number(x * y)

        case let (.number(x), .div, .number(y)):
            guard y != 0 else { throw CalcError.invalidOperation }
            return .number(x / y)

            // MARK: - Date − Date (PRO Premium, human exact)
            case let (.date(d1), .sub, .date(d2)):
                let cal = options.calendar

                // 🔒 Normalisation stricte à minuit
                let start = cal.startOfDay(for: min(d1, d2))
                let end   = cal.startOfDay(for: max(d1, d2))

                // 📐 Différence calendaire exacte
                let comps = cal.dateComponents(
                    [.year, .month, .day],
                    from: start,
                    to: end
                )

                let years  = comps.year  ?? 0
                let months = comps.month ?? 0
                var days   = comps.day   ?? 0

                // 🔥 Inclusive / Exclusive
                if options.inclusiveDiff {
                    days += 1
                }

                // 🧮 Construction canonique via Calendar (AUCUNE approximation)
                return .duration(
                    TDDuration(
                        years: years,
                        months: months,
                        days: days,
                        reference: start,
                        calendar: cal
                    )
                )


        // MARK: - Date ± Duration
        case let (.date(date), .add, .duration(dur)):
            let newDate = options.calendar.date(
                byAdding: .second,
                value: dur.seconds,
                to: date
            ) ?? date
            return .date(newDate)

        case let (.date(date), .sub, .duration(dur)):
            let newDate = options.calendar.date(
                byAdding: .second,
                value: -dur.seconds,
                to: date
            ) ?? date
            return .date(newDate)

        // MARK: - Duration + Duration
        case let (.duration(a), .add, .duration(b)):
            return .duration(TDDuration(seconds: a.seconds + b.seconds))

        case let (.duration(a), .sub, .duration(b)):
            return .duration(TDDuration(seconds: abs(a.seconds - b.seconds)))

        // MARK: - Duration × Number
        case let (.duration(d), .mul, .number(n)):
            return .duration(
                TDDuration(seconds: multiplySeconds(d.seconds, by: n))
            )

        case let (.duration(d), .div, .number(n)):
            guard n != 0 else { throw CalcError.invalidOperation }
            return .duration(
                TDDuration(seconds: divideSeconds(d.seconds, by: n))
            )

        default:
            throw CalcError.invalidOperation
        }
    }

    // MARK: - Helpers

    private func multiplySeconds(_ seconds: Int, by factor: Decimal) -> Int {
        let s = Decimal(seconds)
        let result = s * factor
        return max(0, NSDecimalNumber(decimal: result).intValue)
    }

    private func divideSeconds(_ seconds: Int, by factor: Decimal) -> Int {
        let s = Decimal(seconds)
        let result = s / factor
        return max(0, NSDecimalNumber(decimal: result).intValue)
    }
    
    // Correctif calcul jour de la semaine
    private func weekdayIndex(from date: Date) -> Int {
        // Calendar: Sunday=1 ... Saturday=7  ->  View: Dim=0 ... Sam=6
        options.calendar.component(.weekday, from: date) - 1
    }

}
