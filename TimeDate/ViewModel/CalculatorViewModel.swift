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
    
    // MARK: - CASIO repeat support
    private var lastOp: TDOperator? = nil
    private var lastRhs: TDValue? = nil

    // DATE-TIME composing (Calendar-based)
    private var composingDate = DateComponents()    // year/month/day
    private var composingTime = DateComponents()    // hour/minute/second
    private var isComposingDateTime = false
    private var isComposingRHSDate = false
    private var isEnteringSecondDate = false

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
        // isComposingDateTime sera défini selon le type d'input (date vs durée)

        let value = Int(buffer) ?? 0
        buffer = ""
        
        // ✅ Début de saisie RHS par unités (DATE)
        if op != nil, rhs == nil, !isComposingRHSDate {
            isComposingRHSDate = true
            isComposingDateTime = true
            composingDate = DateComponents()
            composingTime = DateComponents()
        }
        
        switch unit {

        // MARK: - DATE
        case .years:
            composingDate.year = value

        case .months:
            composingDate.month = value

        case .days:
            // 🟢 Si on compose une date RHS → jour du mois
            if isComposingDateTime {
                composingDate.day = value
                break
            }

            // 🔵 Sinon → durée (Date ± Days)
            if let lhs, op != nil, case .date = lhs {
                let v: TDValue = .duration(TDDuration(seconds: value * 86_400))
                rhs = v
                displayResult = formatter.displayResult(v)
                weekday = nil
                return
            }

            // Sinon → composition de date
            composingDate.day = value

        // MARK: - TIME
        case .hours:
            if let lhs, op != nil, case .date = lhs {
                let dur = TDDuration(seconds: value * 3_600)
                let v: TDValue = .duration(dur)
                rhs = v
                displayResult = formatter.displayResult(v)
                weekday = nil
                return
            }
            composingTime.hour = value

        case .minutes:
            if let lhs, op != nil, case .date = lhs {
                let dur = TDDuration(seconds: value * 60)
                let v: TDValue = .duration(dur)
                rhs = v
                displayResult = formatter.displayResult(v)
                weekday = nil
                return
            }
            composingTime.minute = value

        case .seconds:
            if let lhs, op != nil, case .date = lhs {
                let dur = TDDuration(seconds: value)
                let v: TDValue = .duration(dur)
                rhs = v
                displayResult = formatter.displayResult(v)
                weekday = nil
                return
            }
            composingTime.second = value


        // MARK: - Weeks = duration pure (pas une date)
        case .weeks:
            if let lhs, op != nil, case .date = lhs {
                let signed = (op == .sub ? -value : value)
                let dur = TDDuration(seconds: signed * 7 * 86_400)
                let v: TDValue = .duration(dur)

                rhs = v
                displayResult = formatter.displayResult(v)
                weekday = nil
                return
            }

            // sinon : durée pure (pas une date)
            let dur = TDDuration(seconds: value * 7 * 86_400)
            let v: TDValue = .duration(dur)
            lhs = v
            displayResult = formatter.displayResult(v)
            weekday = nil
            return

        }

        // MARK: - Construire une Date seulement si Y/M/D sont présents
        guard
            composingDate.year != nil,
            composingDate.month != nil,
            composingDate.day != nil
        else {
            // Affichage intermédiaire lisible (sans calcul)
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

        // 🔒 Date complète → construction
        var comps = composingDate
        comps.hour = 0
        comps.minute = 0
        comps.second = 0

        guard let date = options.calendar.date(from: comps) else {
            displayResult = TDDisplayResult(main: "Date invalide", secondary: nil)
            weekday = nil
            return
        }

        let v: TDValue = .date(date)

        // ✅ AFFECTATION UNIQUE (CRITIQUE)
        if isEnteringSecondDate {
            rhs = v
        } else {
            lhs = v
        }

        // 🔒 Reset composition (sinon chevauchement)
        composingDate = DateComponents()
        composingTime = DateComponents()
        isComposingDateTime = false
        isComposingRHSDate = false

        displayResult = formatter.displayResult(v)
        setWeekdayIfDate(v)

    }

    
    // MARK: - Operators
    func tapOp(_ newOp: TDOperator) {
        do {

            // 🔥 CASIO : opérateur après "=" ou "=="
            if didJustEvaluate {
                didJustEvaluate = false
                self.op = newOp

                isEnteringSecondDate = true
                isComposingRHSDate = false

                expression = formatter.displayResult(lhs!).main + " \(newOp.rawValue)"
                updateDisplayFromState()
                self.rhs = nil
                buffer = ""
                
                lastOp = nil
                lastRhs = nil
                
                return
            }

            // Commit ce que l'utilisateur a tapé
            let trimmed = buffer.trimmingCharacters(in: .whitespacesAndNewlines)

            // ⚠️ NE PAS COMMIT si lhs existe déjà et buffer vide
            if !(trimmed.isEmpty && lhs != nil) {
                try commitCurrentEntryIfNeeded(defaultIfEmpty: op != nil)
            }


            // CASIO immediate execution
            if let lhs, let op, let rhs {
                let result = try engine.compute(lhs, op, rhs)

                self.lhs = result
                self.rhs = nil

                displayResult = formatter.displayResult(result)
                setWeekdayIfDate(result)
            }

            self.op = newOp
            expression = formatter.displayResult(lhs!).main + " \(newOp.rawValue)"
            updateDisplayFromState()

        } catch {
            displayResult = TDDisplayResult(main: "Error", secondary: nil)
        }
    }

    // MARK: - Equals ✅ PRO Premium
    func tapEquals() {
        
        // ✅ Validation finale RHS (date composée par unités)
        if rhs == nil,
           op != nil,
           composingDate.year != nil,
           composingDate.month != nil,
           composingDate.day != nil {

            var comps = composingDate
            comps.hour = 0
            comps.minute = 0
            comps.second = 0

            if let date = options.calendar.date(from: comps) {
                rhs = .date(date)
            }

            composingDate = DateComponents()
            composingTime = DateComponents()
            isComposingDateTime = false
        }

        do {

            // 🔁 CASIO repeat "="
            if rhs == nil, let lastOp, let lastRhs, let lhs {
                let result = try engine.compute(lhs, lastOp, lastRhs)

                displayResult = formatter.displayResult(result)
                self.lhs = result
                didJustEvaluate = true
                setWeekdayIfDate(result)
                return
            }

            // Commit RHS uniquement si l'utilisateur a réellement tapé quelque chose
            if rhs == nil && !buffer.isEmpty {
                try commitCurrentEntryIfNeeded(defaultIfEmpty: false)
            }

            guard let lhs, let rhs, let op else { return }

            let result = try engine.compute(lhs, op, rhs)
            displayResult = formatter.displayResult(result)

            // ✅ CASIO memory
            self.lastOp = op
            self.lastRhs = rhs

            // Chaînage
            self.lhs = result
            self.rhs = nil
            self.op  = nil

            buffer = ""
            expression = ""
            didJustEvaluate = true

            // 🔒 FIN DE SAISIE DE LA SECONDE DATE
            isEnteringSecondDate = false
            
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

        // 🔥 RESET CASIO MEMORY
        lastOp = nil
        lastRhs = nil

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
            // ✅ si l'utilisateur a tapé une date complète au clavier, on la valide
            if buffer.contains("/") {
                let v = try parser.parse(buffer)
                if lhs == nil { lhs = v }
                else if op != nil { rhs = v }
                else { lhs = v }

                buffer = ""
                isComposingDateTime = false
                setWeekdayIfDate(v)
                updateDisplayFromState()
                return
            }

            // sinon : vraie composition par unités → on ne commit pas encore
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
