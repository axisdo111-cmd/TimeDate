//
//  CalculatorViewModel.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//
//  PRO / Premium - Stable & clean
//

import SwiftUI

@MainActor
final class CalculatorViewModel: ObservableObject {

    // MARK: - Published (UI)
    @Published var mode: TDMode = .calc
    @Published var inclusiveDiff: Bool = false
    @Published var expression: String = ""
    @Published var weekday: Int? = nil              // 0..6 for WeekdayBarView (Dim..Sam)
    @Published var didJustEvaluate: Bool = false

    @Published var displayResult: TDDisplayResult =
        TDDisplayResult(main: "0", secondary: nil)

    // MARK: - Internal State
    private var buffer: String = ""                 // raw typing for numbers or manual date/time
    private var lhs: TDValue? = nil
    private var rhs: TDValue? = nil
    private var op: TDOperator? = nil

    // DATE-TIME composing (Calendar-based)
    private var composingDate = DateComponents()    // year/month/day
    private var composingTime = DateComponents()    // hour/minute/second
    private var isComposingDateTime = false

    // Options / helpers
    private var options = TDOptions()
    private var parser: TDParser { TDParser(options: options) }
    private var engine: TDCalcEngine { TDCalcEngine(options: options) }
    private var formatter: TDFormatter { TDFormatter(options: options) }

    // MARK: - Mode
    func toggleMode() {
        mode = (mode == .calc) ? .dateTime : .calc
        clear(keepMode: true, keepInclusive: true)
    }

    func setInclusiveDiff(_ on: Bool) {
        inclusiveDiff = on
        options.inclusiveDiff = on
    }

    // MARK: - Digits
    func tapDigit(_ d: String) {
        if didJustEvaluate {
            clear(keepMode: true, keepInclusive: true)
        }
        buffer.append(d)
        updateDisplayFromState()
    }

    func tapDot() {
        if didJustEvaluate {
            clear(keepMode: true, keepInclusive: true)
        }
        guard !buffer.contains(".") else { return }
        buffer = buffer.isEmpty ? "0." : (buffer + ".")
        updateDisplayFromState()
    }

    func tapSeparatorSlash() {
        if didJustEvaluate {
            clear(keepMode: true, keepInclusive: true)
        }
        buffer.append("/")
        updateDisplayFromState()
    }

    func tapSeparatorColon() {
        if didJustEvaluate {
            clear(keepMode: true, keepInclusive: true)
        }
        buffer.append(":")
        updateDisplayFromState()
    }

    func tapBackspace() {
        if didJustEvaluate {
            clear(keepMode: true, keepInclusive: true)
            return
        }

        if !buffer.isEmpty {
            buffer.removeLast()
            updateDisplayFromState()
            return
        }

        // Si on composait une date/heure via unités : reset composition
        if isComposingDateTime {
            composingDate = DateComponents()
            composingTime = DateComponents()
            isComposingDateTime = false
            weekday = nil
            updateDisplayFromState()
        }
    }

    // MARK: - Units (DATE-TIME composing) ✅ Calendar-based
    func tapUnit(_ unit: UnitKind) {
        mode = .dateTime
        didJustEvaluate = false
        isComposingDateTime = true

        let value = Int(buffer) ?? 0
        buffer = ""

        switch unit {

        // MARK: - DATE
        case .years:
            composingDate.year = value

        case .months:
            composingDate.month = value

        case .days:
            composingDate.day = value

        // MARK: - TIME
        case .hours:
            composingTime.hour = value

        case .minutes:
            composingTime.minute = value

        case .seconds:
            composingTime.second = value

        // MARK: - Weeks = duration pure (pas une date)
        case .weeks:
            let dur = TDDuration(seconds: value * 7 * 86_400)
            let v: TDValue = .duration(dur)

            if op == nil { lhs = v } else { rhs = v }
            displayResult = formatter.displayResult(v)
            weekday = nil
            return
        }

        // MARK: - Construire une Date fiable (DST-safe)
        var comps = composingDate
        comps.hour   = composingTime.hour   ?? 12   // ✅ 12h évite certains soucis DST historiques
        comps.minute = composingTime.minute ?? 0
        comps.second = composingTime.second ?? 0

        // Base = aujourd’hui si année/mois/jour non fournis
        if comps.year == nil || comps.month == nil || comps.day == nil {
            let base = options.calendar.dateComponents([.year, .month, .day], from: Date())
            comps.year  = comps.year  ?? base.year
            comps.month = comps.month ?? base.month
            comps.day   = comps.day   ?? base.day
        }

        guard let date = options.calendar.date(from: comps) else {
            displayResult = TDDisplayResult(main: "Date invalide", secondary: nil)
            weekday = nil
            return
        }

        let v: TDValue = .date(date)
        if op == nil { lhs = v } else { rhs = v }

        displayResult = formatter.displayResult(v)
        setWeekdayIfDate(v)
    }

    // MARK: - Operators
    func tapOp(_ newOp: TDOperator) {
        do {
            try commitCurrentEntryIfNeeded(defaultIfEmpty: true)
            guard let lhs else { return }

            op = newOp
            rhs = nil
            didJustEvaluate = false

            expression = formatter.displayResult(lhs).main + " \(newOp.rawValue)"
            updateDisplayFromState()
        } catch {
            displayResult = TDDisplayResult(main: "Error", secondary: nil)
        }
    }

    // MARK: - Equals ✅ PRO Premium
    func tapEquals() {
        do {
            // Commit RHS si l'utilisateur a tapé au clavier (buffer)
            // ou s'il n'a rien tapé mais qu'on veut forcer la validation selon le mode.
            if rhs == nil {
                try commitCurrentEntryIfNeeded(defaultIfEmpty: false)
            }

            guard let lhs, let rhs, let op else { return }

            let result = try engine.compute(lhs, op, rhs)
            displayResult = formatter.displayResult(result)

            // Chaînage PRO : résultat devient lhs
            self.lhs = result
            self.rhs = nil
            self.op  = nil

            buffer = ""
            expression = ""
            didJustEvaluate = true

            // Jour toujours cohérent après "="
            setWeekdayIfDate(result)

        } catch {
            displayResult = TDDisplayResult(main: "Error", secondary: nil)
            weekday = nil
        }
    }

    // MARK: - Today
    func tapToday() {
        mode = .dateTime

        let date = Date()
        let v: TDValue = .date(date)

        lhs = v
        rhs = nil
        op = nil

        buffer = ""
        composingDate = DateComponents()
        composingTime = DateComponents()
        isComposingDateTime = false

        displayResult = formatter.displayResult(v)
        weekday = weekdayIndex(from: date)

        expression = ""
        didJustEvaluate = true
    }

    // MARK: - Clear
    func clear() {
        clear(keepMode: true, keepInclusive: true)
    }

    private func clear(keepMode: Bool, keepInclusive: Bool) {
        if !keepMode { mode = .calc }
        if !keepInclusive {
            inclusiveDiff = false
            options.inclusiveDiff = false
        }

        buffer = ""
        lhs = nil
        rhs = nil
        op = nil

        composingDate = DateComponents()
        composingTime = DateComponents()
        isComposingDateTime = false

        expression = ""
        weekday = nil
        displayResult = TDDisplayResult(main: "0", secondary: nil)
        didJustEvaluate = false
    }

    // MARK: - Commit logic
    private func commitCurrentEntryIfNeeded(defaultIfEmpty: Bool) throws {

        // Si l'utilisateur compose via unités, lhs/rhs a déjà été alimenté par tapUnit()
        // Donc on ne force rien ici.
        if isComposingDateTime {
            return
        }

        let trimmed = buffer.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            if defaultIfEmpty {
                let v: TDValue = .number(0)
                if lhs == nil { lhs = v }
                else if op != nil { rhs = v }
                else { lhs = v }
                buffer = ""
                updateDisplayFromState()
                return
            } else {
                throw CalcError.invalidOperation
            }
        }

        let v = try parser.parse(trimmed)

        if lhs == nil {
            lhs = v
        } else if op != nil {
            rhs = v
        } else {
            lhs = v
        }

        buffer = ""
        setWeekdayIfDate(v)
        updateDisplayFromState()
    }

    // MARK: - Display
    private func updateDisplayFromState() {
        if !buffer.isEmpty {
            displayResult = TDDisplayResult(main: buffer, secondary: nil)
            return
        }

        if let lhs {
            displayResult = formatter.displayResult(lhs)
        } else {
            displayResult = TDDisplayResult(main: "0", secondary: nil)
        }
    }

    // MARK: - Weekday helpers (Dim..Sam)
    private func weekdayIndex(from date: Date) -> Int {
        options.calendar.component(.weekday, from: date) - 1
    }

    private func setWeekdayIfDate(_ value: TDValue?) {
        guard let value else { weekday = nil; return }
        if case let .date(d) = value {
            weekday = weekdayIndex(from: d)
        } else {
            weekday = nil
        }
    }
}
