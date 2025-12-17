//
//  TDCalcEngine.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

// TDCalcEngine.swift
// PRO / Premium – Simplified & Safe

import Foundation

struct TDCalcEngine {

    let options: TDOptions

    func compute(_ a: TDValue, _ op: TDOperator, _ b: TDValue) throws -> TDValue {

        switch (a, op, b) {

        // MARK: - Numbers
        case let (.number(x), .add, .number(y)): return .number(x + y)
        case let (.number(x), .sub, .number(y)): return .number(x - y)
        case let (.number(x), .mul, .number(y)): return .number(x * y)
        case let (.number(x), .div, .number(y)):
            guard y != 0 else { throw CalcError.invalidOperation }
            return .number(x / y)

        // MARK: - Date − Calendar
        // Date ± Calendar Quantity
        case let (.date(date), .add, .calendar(q)):
            return .date(apply(q, to: date))

        case let (.date(date), .sub, .calendar(q)):
            return .date(apply(q.negated(), to: date))
            
        // MARK: - Date − Date
        case let (.date(d1), .sub, .date(d2)):
            let cal = options.calendar
            let start = cal.startOfDay(for: min(d1, d2))
            let end   = cal.startOfDay(for: max(d1, d2))

            var days = cal.dateComponents([.day], from: start, to: end).day ?? 0
            if options.inclusiveDiff { days += 1 }

            return .duration(TDDuration(seconds: days * 86_400))

        // MARK: - Date ± Duration
        case let (.date(date), .add, .duration(dur)):
            return .date(
                options.calendar.date(byAdding: .second, value: dur.seconds, to: date)!
            )

        case let (.date(date), .sub, .duration(dur)):
            return .date(
                options.calendar.date(byAdding: .second, value: -dur.seconds, to: date)!
            )

        // MARK: - Duration + Duration
        case let (.duration(a), .add, .duration(b)):
            return .duration(TDDuration(seconds: a.seconds + b.seconds))

        case let (.duration(a), .sub, .duration(b)):
            return .duration(TDDuration(seconds: abs(a.seconds - b.seconds)))

        default:
            throw CalcError.invalidOperation
        }
    }
    
    private func apply(_ q: TDCalendarQuantity, to date: Date) -> Date {
        let cal = options.calendar
        var result = date

        if q.years != 0 {
            result = cal.date(byAdding: .year, value: q.years, to: result)!
        }
        if q.months != 0 {
            result = cal.date(byAdding: .month, value: q.months, to: result)!
        }
        if q.weeks != 0 {
            result = cal.date(byAdding: .day, value: q.weeks * 7, to: result)!
        }
        if q.days != 0 {
            result = cal.date(byAdding: .day, value: q.days, to: result)!
        }

        return result
    }

}

