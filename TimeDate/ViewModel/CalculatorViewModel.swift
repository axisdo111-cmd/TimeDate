//
//  CalculatorViewModel.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//
//  PRO / Premium - Stable & clean
//

//
//  CalculatorViewModel.swift
//  TimeDate
//
//  PRO / Premium - Clean, deterministic, Date-safe
//

import SwiftUI

@MainActor
final class CalculatorViewModel: ObservableObject {

    // MARK: - Published (UI)
    @Published var mode: TDMode = .calc
    @Published var inclusiveDiff: Bool = false
    @Published var expression: String = ""
    @Published var weekday: Int? = nil              // 0..6 (Dim..Sam)
    @Published var didJustEvaluate: Bool = false
    @Published var displayResult: TDDisplayResult = TDDisplayResult(main: "0", secondary: nil)

    // MARK: - Core state
    private var buffer: String = ""                 // saisie brute (nombres / dates au clavier)
    private var lhs: TDValue? = nil
    private var rhs: TDValue? = nil
    private var op: TDOperator? = nil

    // MARK: - Date composing by units (JJ / MM / AAAA)
    private var composingDate = DateComponents()    // day/month/year
    private var isComposingDate = false             // on affiche l’intermédiaire (ex: "14 Days 12 Months")

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

    // MARK: - Digits / separators
    func tapDigit(_ d: String) {
        if didJustEvaluate { clear(keepMode: true, keepInclusive: true) }
        buffer.append(d)
        updateDisplayFromState()
    }

    func tapDot() {
        if didJustEvaluate { clear(keepMode: true, keepInclusive: true) }
        guard !buffer.contains(".") else { return }
        buffer = buffer.isEmpty ? "0." : (buffer + ".")
        updateDisplayFromState()
    }

    func tapSeparatorSlash() {
        if didJustEvaluate { clear(keepMode: true, keepInclusive: true) }
        buffer.append("/")
        updateDisplayFromState()
    }

    func tapSeparatorColon() {
        if didJustEvaluate { clear(keepMode: true, keepInclusive: true) }
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

        if isComposingDate {
            composingDate = DateComponents()
            isComposingDate = false
            weekday = nil
            updateDisplayFromState()
        }
    }

    // MARK: - Units
    func tapUnit(_ unit: UnitKind) {
        mode = .dateTime
        didJustEvaluate = false

        let value = Int(buffer) ?? 0
        buffer = ""

        // 1) Si on est dans une expression Date ? (lhs=date et op=+/-)
        let lhsIsDate: Bool = {
            if let lhs, case .date = lhs { return true }
            return false
        }()

        let opIsPlusMinus: Bool = (op == .add || op == .sub)

        // 2) Si on a déjà une RHS en "durée days" mais que l’utilisateur enchaine avec Months/Years
        //    => on bascule automatiquement en "seconde date" (14 Days + 12 Months + 2025 Years)
        if lhsIsDate, opIsPlusMinus, rhs != nil, isComposingDate == false {
            if case .duration(let d) = rhs, unit == .months || unit == .years {
                // migration: seulement si la durée est un nombre entier de jours
                let days = d.seconds / 86_400
                if days * 86_400 == d.seconds, (1...31).contains(days) {
                    rhs = nil
                    composingDate = DateComponents()
                    composingDate.day = days
                    isComposingDate = true
                }
            }
        }

        // 3) Cas Date ± (Days/Weeks/Months/Years)  => RHS = duration
        if lhsIsDate, opIsPlusMinus, rhs == nil, isComposingDate == false {
            switch unit {
            case .days:
                rhs = .duration(TDDuration(seconds: signedSeconds(days: value)))
                displayResult = formatter.displayResult(rhs!)
                weekday = nil
                return

            case .weeks:
                rhs = .duration(TDDuration(seconds: signedSeconds(days: value * 7)))
                displayResult = formatter.displayResult(rhs!)
                weekday = nil
                return

            case .months, .years:
                // Ici on ne passe PAS par des secondes (mois/années variables).
                // On encode months/years en "duration" via TDDuration init calendar-based
                // mais seulement pour Date ± Duration -> TDCalcEngine doit gérer via Calendar.
                let cal = options.calendar
                let ref = Date() // reference neutre (TDDuration stocke des secondes, mais on n’en dépend pas ici)
                let dur: TDDuration
                if unit == .months {
                    dur = TDDuration(months: value * (op == .sub ? -1 : 1), reference: ref, calendar: cal)
                } else {
                    dur = TDDuration(years: value * (op == .sub ? -1 : 1), reference: ref, calendar: cal)
                }
                rhs = .duration(dur)
                displayResult = formatter.displayResult(rhs!)
                weekday = nil
                return

            default:
                break
            }
        }

        // 4) Cas saisie d’une date par unités (lhs ou rhs) : JJ/MM/AAAA
        if unit == .days || unit == .months || unit == .years {

            isComposingDate = true

            switch unit {
            case .days:
                composingDate.day = value
            case .months:
                composingDate.month = value
            case .years:
                composingDate.year = value
            default:
                break
            }

            // Affichage intermédiaire tant que la date n’est pas complète
            guard
                composingDate.day != nil,
                composingDate.month != nil,
                composingDate.year != nil
            else {
                displayResult = TDDisplayResult(
                    main: [
                        composingDate.day.map { "\($0) Days" },
                        composingDate.month.map { "\($0) Months" },
                        composingDate.year.map { "\($0) Years" }
                    ]
                    .compactMap { $0 }
                    .joined(separator: " "),
                    secondary: nil
                )
                weekday = nil
                return
            }

            // Date complète -> construire à minuit (aucune heure visible)
            var comps = composingDate
            comps.hour = 0
            comps.minute = 0
            comps.second = 0
            comps.calendar = options.calendar
            comps.timeZone = options.calendar.timeZone

            guard let date = options.calendar.date(from: comps) else {
                displayResult = TDDisplayResult(main: "Date invalide", secondary: nil)
                weekday = nil
                return
            }

            let v: TDValue = .date(date)

            // Affectation déterministe
            if lhs == nil {
                lhs = v
            } else if op != nil {
                rhs = v
            } else {
                lhs = v
            }

            composingDate = DateComponents()
            isComposingDate = false

            displayResult = formatter.displayResult(v)
            setWeekdayIfDate(v)
            return
        }

        // 5) Durées pures (heures/min/sec) => duration
        switch unit {
        case .hours:
            commitDuration(seconds: value * 3_600)
        case .minutes:
            commitDuration(seconds: value * 60)
        case .seconds:
            commitDuration(seconds: value)
        case .weeks:
            commitDuration(seconds: value * 7 * 86_400)
        default:
            // rien
            break
        }
    }

    // MARK: - Operators
    func tapOp(_ newOp: TDOperator) {
        // 🔒 Dates: seulement + et -
        if (newOp == .mul || newOp == .div), containsAnyDate() {
            displayResult = TDDisplayResult(main: "Error", secondary: nil)
            return
        }

        do {
            // Finaliser ce qui est au buffer (si date au clavier, ou nombre)
            if !buffer.isEmpty {
                try commitCurrentEntryIfNeeded(defaultIfEmpty: false)
            }

            // Si rhs déjà présent, exécution immédiate "CASIO"
            if let lhs, let op, let rhs {
                let result = try engine.compute(lhs, op, rhs)
                self.lhs = result
                self.rhs = nil
                displayResult = formatter.displayResult(result)
                setWeekdayIfDate(result)
            }

            self.op = newOp
            if let lhs {
                expression = formatter.displayResult(lhs).main + " \(newOp.rawValue)"
            } else {
                expression = ""
            }

        } catch {
            displayResult = TDDisplayResult(main: "Error", secondary: nil)
            weekday = nil
        }
    }

    // MARK: - Equals (FINAL, SIMPLE, RELIABLE)
    func tapEquals() {
        do {
            // Si l’utilisateur a tapé une date au clavier pour la RHS (14/12/2025)
            if rhs == nil, !buffer.isEmpty {
                try commitCurrentEntryIfNeeded(defaultIfEmpty: false)
            }

            guard let lhs, let rhs, let op else {
                displayResult = TDDisplayResult(main: "Error", secondary: nil)
                return
            }

            let result = try engine.compute(lhs, op, rhs)

            displayResult = formatter.displayResult(result)
            self.lhs = result
            self.rhs = nil
            self.op  = nil

            buffer = ""
            expression = ""
            didJustEvaluate = true
            setWeekdayIfDate(result)

        } catch {
            displayResult = TDDisplayResult(main: "Error", secondary: nil)
            weekday = nil
        }
    }

    // MARK: - Today
    func tapToday() {
        mode = .dateTime
        let date = options.calendar.startOfDay(for: Date())
        let v: TDValue = .date(date)

        lhs = v
        rhs = nil
        op  = nil

        buffer = ""
        composingDate = DateComponents()
        isComposingDate = false

        displayResult = formatter.displayResult(v)
        setWeekdayIfDate(v)

        expression = ""
        didJustEvaluate = true
    }

    // MARK: - Clear
    func clear() { clear(keepMode: true, keepInclusive: true) }

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
        isComposingDate = false

        expression = ""
        weekday = nil
        displayResult = TDDisplayResult(main: "0", secondary: nil)
        didJustEvaluate = false
    }

    // MARK: - Commit
    private func commitCurrentEntryIfNeeded(defaultIfEmpty: Bool) throws {
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
            }
            throw CalcError.invalidOperation
        }

        let v = try parser.parse(trimmed)

        if lhs == nil { lhs = v }
        else if op != nil { rhs = v }
        else { lhs = v }

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
        if isComposingDate {
            // déjà géré dans tapUnit
            return
        }
        if let lhs {
            displayResult = formatter.displayResult(lhs)
        } else {
            displayResult = TDDisplayResult(main: "0", secondary: nil)
        }
    }

    // MARK: - Helpers
    private func commitDuration(seconds raw: Int) {
        let v: TDValue = .duration(TDDuration(seconds: max(0, raw)))
        if lhs == nil { lhs = v }
        else if op != nil { rhs = v }
        else { lhs = v }

        displayResult = formatter.displayResult(v)
        weekday = nil
    }

    private func signedSeconds(days: Int) -> Int {
        let sign = (op == .sub) ? -1 : 1
        return sign * days * 86_400
    }

    private func containsAnyDate() -> Bool {
        if let lhs, case .date = lhs { return true }
        if let rhs, case .date = rhs { return true }
        // buffer date au clavier
        if buffer.contains("/") { return true }
        return false
    }

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
