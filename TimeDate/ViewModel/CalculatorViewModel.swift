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

    // MARK: - Published
    @Published var mode: TDMode = .calc
    @Published var inclusiveDiff: Bool = false
    @Published var expression: String = ""
    @Published var weekday: Int? = nil
    @Published var didJustEvaluate: Bool = false

    @Published var displayResult: TDDisplayResult =
        TDDisplayResult(main: "0", secondary: nil)

    // MARK: - Core state
    private var buffer: String = ""
    private var lhs: TDValue? = nil
    private var rhs: TDValue? = nil
    private var op: TDOperator? = nil

    // CASIO repeat (numbers only)
    private var lastOp: TDOperator? = nil
    private var lastRhs: TDValue? = nil

    // MARK: - Date/Duration drafts (the key)
    private enum RHSIntent { case unknown, date, duration }
    private var rhsIntent: RHSIntent = .unknown

    private var lhsDateDraft = DateComponents()   // year/month/day only
    private var rhsDateDraft = DateComponents()   // year/month/day only

    private struct DurationDraft {
        var years = 0
        var months = 0
        var weeks = 0
        var days = 0
        var hours = 0
        var minutes = 0
        var seconds = 0

        var isEmpty: Bool {
            years == 0 && months == 0 && weeks == 0 && days == 0 &&
            hours == 0 && minutes == 0 && seconds == 0
        }

        mutating func reset() { self = DurationDraft() }
    }

    private var rhsDurationDraft = DurationDraft()
    private var lhsDurationDraft = DurationDraft()

    // Helpers
    private var options = TDOptions()
    private var parser: TDParser { TDParser(options: options) }
    private var engine: TDCalcEngine { TDCalcEngine(options: options) }
    private var formatter: TDFormatter { TDFormatter(options: options) }

    // MARK: - Mode / options
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
        if didJustEvaluate { clear(keepMode: true, keepInclusive: true) }
        buffer.append(d)
        updateDisplayFromState()
    }

    func tapDot() {
        if didJustEvaluate { clear(keepMode: true, keepInclusive: true) }
        guard !buffer.contains(".") else { return }
        buffer = buffer.isEmpty ? "0." : buffer + "."
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
        // backspace = reset drafts if nothing in buffer
        lhsDateDraft = DateComponents()
        rhsDateDraft = DateComponents()
        rhsIntent = .unknown
        rhsDurationDraft.reset()
        lhsDurationDraft.reset()
        weekday = nil
        updateDisplayFromState()
    }

    
    // MARK: - Units (EXPERT)
    func tapUnit(_ unit: UnitKind) {
        // 🔒 Neutralisation CASIO
        if op != nil, firstValueKind == .date {
            // RHS après une date : interdit de créer une date absolue
            if unit == .years || unit == .months || unit == .days {
                // Autorisé → quantité
                // OK
            }
        }
        mode = .dateTime
        didJustEvaluate = false
        
        let v = Int(buffer) ?? 0
        buffer = ""
        
        let enteringRHS = (op != nil && lhs != nil)
        
        if enteringRHS {
            applyUnitToRHS(unit, v)
            
            // ✅ Si la RHS est une vraie date complète -> commit immédiat + weekday
            if let d = makeDate(from: rhsDateDraft) {
                let v: TDValue = .date(d)
                assign(v, toRHS: true)
                setWeekdayIfDate(v)
                rhsDateDraft = DateComponents()
                return
            }
            
            // Sinon affichage intermédiaire
            updateDateTimeDraftDisplay(isRHS: true)
            
        } else {
            applyUnitToLHS(unit, v)
            
            // ✅ Si la LHS est une vraie date complète -> commit immédiat + weekday
            if let d = makeDate(from: lhsDateDraft) {
                let v: TDValue = .date(d)
                assign(v, toRHS: false)
                setWeekdayIfDate(v)
                lhsDateDraft = DateComponents()
                return
            }
            
            // Sinon affichage intermédiaire
            updateDateTimeDraftDisplay(isRHS: false)
        }
    }

    // MARK: - Operators
    func tapOp(_ newOp: TDOperator) {
        // =================================================
        // 🔒 0) NEUTRALISATION DES TOUCHES (AVANT TOUT)
        // =================================================
        if firstValueKind == .date {

            // Date × ou ÷ interdit
            if newOp == .mul || newOp == .div {
                displayResult = TDDisplayResult(main: "Error", secondary: nil)
                return
            }
        }

        // =================================================
        // 1) Logique normale
        // =================================================
        do {
            // DATE-TIME: only + and -
            if mode == .dateTime, (newOp == .mul || newOp == .div) {
                displayResult = TDDisplayResult(main: "Error", secondary: nil)
                return
            }

            // ✅ Si on avait tapé "=" juste avant : on continue à partir du résultat
            if didJustEvaluate {
                didJustEvaluate = false
                self.op = newOp
                rhs = nil
                rhsIntent = .unknown
                rhsDateDraft = DateComponents()
                rhsDurationDraft.reset()
                buffer = ""
                expression = formatter.displayResult(lhs ?? .number(0)).main + " \(newOp.rawValue)"
                return
            }

            // ✅ CASIO: quand on appuie sur un opérateur,
            // si op est déjà présent -> on commit dans RHS
            // sinon -> on commit dans LHS
            if !buffer.isEmpty || lhs == nil || rhsDateDraft.year != nil || rhsDateDraft.month != nil || rhsDateDraft.day != nil {
                try commitEntryIfNeeded(targetIsRHS: (op != nil))
            }

            // ✅ Exécution immédiate CASIO si on a lhs op rhs
            if let lhs, let op, let rhs {
                let result = try engine.compute(lhs, op, rhs)
                self.lhs = result
                self.rhs = nil
                displayResult = formatter.displayResult(result)
                setWeekdayIfDate(result)
            }

            // ✅ On pose le nouvel opérateur
            self.op = newOp

            // ✅ Reset RHS drafts pour la saisie suivante
            rhs = nil
            rhsIntent = .unknown
            rhsDateDraft = DateComponents()
            rhsDurationDraft.reset()
            buffer = ""

            expression = formatter.displayResult(lhs ?? .number(0)).main + " \(newOp.rawValue)"
            updateDisplayFromState()

        } catch {
            displayResult = TDDisplayResult(main: "Error", secondary: nil)
            weekday = nil
        }
    }

    
    // MARK: - Equals ✅ PRO Premium (CASIO + Date safe)
    func tapEquals() {
        do {
            // -------------------------------------------------
            // 0) CASIO repeat "=" : uniquement si on a une mémoire
            // -------------------------------------------------
            if buffer.isEmpty, rhs == nil, let lhs, let lastOp, let lastRhs, didJustEvaluate {
                let result = try engine.compute(lhs, lastOp, lastRhs)
                self.lhs = result
                displayResult = formatter.displayResult(result)
                setWeekdayIfDate(result)
                didJustEvaluate = true
                return
            }

            // -------------------------------------------------
            // 1) Si pas d'opérateur : juste valider/afficher
            // -------------------------------------------------
            if op == nil {
                if !buffer.isEmpty {
                    try commitEntryIfNeeded(targetIsRHS: false)
                }
                displayResult = formatter.displayResult(lhs ?? .number(0))
                setWeekdayIfDate(lhs)
                didJustEvaluate = true
                return
            }

            // -------------------------------------------------
            // 2) Finaliser RHS si nécessaire (buffer / drafts)
            //    ⚠️ On commit RHS seulement s'il manque encore.
            // -------------------------------------------------
            if rhs == nil {
                try commitEntryIfNeeded(targetIsRHS: true)
            }

            // -------------------------------------------------
            // 3) Garde finale
            // -------------------------------------------------
            guard let lhs, let rhs, let op else {
                throw CalcError.invalidOperation
            }

            // -------------------------------------------------
            // 4) Calcul
            // -------------------------------------------------
            let result = try engine.compute(lhs, op, rhs)
            displayResult = formatter.displayResult(result)
            setWeekdayIfDate(result)

            // -------------------------------------------------
            // 5) Mémoire CASIO (uniquement pour nombres)
            // -------------------------------------------------
            if case .number = lhs, case .number = rhs {
                self.lastOp = op
                self.lastRhs = rhs
            } else {
                // protège Date-Date, Date-Duration etc.
                self.lastOp = nil
                self.lastRhs = nil
            }

            // -------------------------------------------------
            // 6) Chaînage
            // -------------------------------------------------
            self.lhs = result
            self.rhs = nil
            self.op  = nil
            buffer = ""
            expression = ""
            didJustEvaluate = true

            // Reset drafts RHS (sécurité)
            rhsIntent = .unknown
            rhsDateDraft = DateComponents()
            rhsDurationDraft.reset()

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
        op = nil
        buffer = ""
        expression = ""
        didJustEvaluate = true

        lhsDateDraft = DateComponents()
        rhsDateDraft = DateComponents()
        rhsIntent = .unknown
        rhsDurationDraft.reset()
        lhsDurationDraft.reset()

        displayResult = formatter.displayResult(v)
        weekday = weekdayIndex(from: date)
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

        lastOp = nil
        lastRhs = nil

        lhsDateDraft = DateComponents()
        rhsDateDraft = DateComponents()
        rhsIntent = .unknown
        rhsDurationDraft.reset()
        lhsDurationDraft.reset()

        expression = ""
        weekday = nil
        displayResult = TDDisplayResult(main: "0", secondary: nil)
        didJustEvaluate = false
    }

    // MARK: - Draft application rules

    private func applyUnitToLHS(_ unit: UnitKind, _ value: Int) {
        switch unit {
        case .years:   lhsDateDraft.year = value
        case .months:  lhsDateDraft.month = value
        case .days:    lhsDateDraft.day = value

        case .weeks:   lhsDurationDraft.weeks = value
        case .hours:   lhsDurationDraft.hours = value
        case .minutes: lhsDurationDraft.minutes = value
        case .seconds: lhsDurationDraft.seconds = value
        }
    }

    private func applyUnitToRHS(_ unit: UnitKind, _ value: Int) {

        let lhsIsDate: Bool = {
            guard let lhs else { return false }
            if case .date = lhs { return true }
            return false
        }()

        // =================================================
        // 🔒 Verrou PREMIUM : Date + Date interdit
        // MAIS Date - Date doit rester possible
        // =================================================
        if lhsIsDate, op == .add {
            // RHS = quantité/durée uniquement
            switch unit {
            case .years:   rhsDurationDraft.years = value
            case .months:  rhsDurationDraft.months = value
            case .weeks:   rhsDurationDraft.weeks = value
            case .days:    rhsDurationDraft.days = value
            case .hours:   rhsDurationDraft.hours = value
            case .minutes: rhsDurationDraft.minutes = value
            case .seconds: rhsDurationDraft.seconds = value
            }

            rhsIntent = .duration
            return
        }

        // =================================================
        // 🟢 Cas normal
        // - si op == .sub avec LHS date : on autorise date2
        // - sinon comportement standard
        // =================================================
        switch unit {

        // Ces 3 là peuvent être :
        // - une date absolue (si Y/M/D complets)
        // - une quantité calendaire (si partiel)
        case .years:
            rhsDateDraft.year = value
            rhsDurationDraft.years = value

        case .months:
            rhsDateDraft.month = value
            rhsDurationDraft.months = value

        case .days:
            rhsDateDraft.day = value
            rhsDurationDraft.days = value

        // Durées uniquement
        case .weeks:
            rhsDurationDraft.weeks = value

        case .hours:
            rhsDurationDraft.hours = value

        case .minutes:
            rhsDurationDraft.minutes = value

        case .seconds:
            rhsDurationDraft.seconds = value
        }

        // Intent (utile pour UI / debug / RN)
        if rhsDateDraft.year != nil || rhsDateDraft.month != nil || rhsDateDraft.day != nil {
            rhsIntent = .date
        } else {
            rhsIntent = .duration
        }
    }



    // MARK: - Commit entry (buffer OR drafts) -> lhs/rhs
    private func commitEntryIfNeeded(targetIsRHS: Bool) throws {

        // -------------------------------------------------
        // 1️⃣ Buffer texte (nombre, date dd/mm/yyyy, heure)
        // -------------------------------------------------
        if !buffer.isEmpty {
            let v = try parser.parse(buffer)
            assign(v, toRHS: targetIsRHS)
            buffer = ""
            return
        }

        // -------------------------------------------------
        // 2️⃣ Date composée (Y/M/D explicite)
        // -------------------------------------------------
        let dateDraft = targetIsRHS ? rhsDateDraft : lhsDateDraft
        if let d = makeDate(from: dateDraft) {

            // =================================================
            // 🔒 RÈGLES PRO PREMIUM
            // =================================================

            // ❌ Interdit : Date + Date
            if targetIsRHS,
               let lhs,
               case .date = lhs,
               op == .add {
                throw CalcError.invalidOperation
            }

            // ✅ Cas clé : Date1 - Date2
            // RHS est une vraie date UNIQUEMENT si elle est
            // >= début du calendrier grégorien
            if targetIsRHS,
               let lhs,
               case .date = lhs,
               op == .sub {

                if isValidGregorianDate(d) {
                    // Date1 - Date2 → quantité (engine s’en charge)
                    let v: TDValue = .date(d)
                    assign(v, toRHS: true)
                    resetDrafts(isRHS: true)
                    return
                } else {
                    // ❌ Date trop ancienne → on BASCULE en quantité
                    // on ne commit PAS la date
                }
            } else {
                // Cas normal (LHS ou autre)
                let v: TDValue = .date(d)
                assign(v, toRHS: targetIsRHS)
                resetDrafts(isRHS: targetIsRHS)
                return
            }
        }



        // -------------------------------------------------
        // 3️⃣ Quantité / Durée (unités)
        // -------------------------------------------------
        let durDraft = targetIsRHS ? rhsDurationDraft : lhsDurationDraft

        // 🔑 CAS CLÉ : RHS + LHS = Date → Calendar Quantity
        if targetIsRHS,
           let lhs,
           case .date = lhs,
           let cal = calendarQuantityFromDraft(durDraft) {

            let v: TDValue = .calendar(cal)
            assign(v, toRHS: true)
            resetDrafts(isRHS: true)
            return
        }

        // 🔹 SINON → Durée horaire
        if let dur = durationFromDraft(durDraft) {
            let v: TDValue = .duration(dur)
            assign(v, toRHS: targetIsRHS)
            resetDrafts(isRHS: targetIsRHS)
            return
        }

        // -------------------------------------------------
        // 4️⃣ Rien à commit → Error
        // -------------------------------------------------
        throw CalcError.invalidOperation
    }

    // ==================================================
    // MARK: - Duration helpers (EXPERT)
    // =================================================

    // Convert a duration draft into a canonical duration (seconds-based)
    private func durationFromDraft(_ d: DurationDraft) -> TDDuration? {
        if d.isEmpty { return nil }

        let totalSeconds =
            (d.years  * 365 * 86_400) +
            (d.months * 30  * 86_400) +
            (d.weeks  * 7   * 86_400) +
            (d.days        * 86_400) +
            (d.hours       * 3_600) +
            (d.minutes     * 60) +
            d.seconds

        return TDDuration(seconds: totalSeconds)
    }

    private func calendarQuantityFromDraft(_ d: DurationDraft) -> TDCalendarQuantity? {
        if d.years == 0 && d.months == 0 && d.weeks == 0 && d.days == 0 {
            return nil
        }
        return TDCalendarQuantity(
            years: d.years,
            months: d.months,
            weeks: d.weeks,
            days: d.days
        )
    }
    
    // Reset drafts after commit
    private func resetDrafts(isRHS: Bool) {
        if isRHS {
            rhsDateDraft = DateComponents()
            rhsDurationDraft.reset()
            rhsIntent = .unknown
        } else {
            lhsDateDraft = DateComponents()
            lhsDurationDraft.reset()
        }
    }


    // Affichage WeekDayBarView
    private func assign(_ v: TDValue, toRHS: Bool) {
        if toRHS {
            rhs = v
        } else {
            lhs = v
        }

        displayResult = formatter.displayResult(v)

        // ✅ PATCH CRITIQUE : synchro du jour de la semaine
        setWeekdayIfDate(v)
    }


    private func makeDate(from comps: DateComponents) -> Date? {
        guard let y = comps.year, let m = comps.month, let d = comps.day else { return nil }
        var c = DateComponents()
        c.year = y
        c.month = m
        c.day = d
        c.hour = 0
        c.minute = 0
        c.second = 0
        return options.calendar.date(from: c).map { options.calendar.startOfDay(for: $0) }
    }

    // MARK: - Gregorian helpers (PRO)
    private func isValidGregorianDate(_ date: Date) -> Bool {
        date >= options.gregorianStart
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

    private func updateDateTimeDraftDisplay(isRHS: Bool) {
        let dc = isRHS ? rhsDateDraft : lhsDateDraft

        // 1) Draft date (Y/M/D seulement)
        var dateParts: [String] = []
        if let d = dc.day   { dateParts.append("\(d) Days") }
        if let m = dc.month { dateParts.append("\(m) Months") }
        if let y = dc.year  { dateParts.append("\(y) Years") }

        if !dateParts.isEmpty {
            displayResult = TDDisplayResult(main: dateParts.joined(separator: " "), secondary: nil)
            weekday = nil
            return
        }

        // 2) Draft duration / calendar quantity
        let dur = isRHS ? rhsDurationDraft : lhsDurationDraft
        if !dur.isEmpty {
            var p: [String] = []
            if dur.years != 0    { p.append("\(dur.years) Years") }
            if dur.months != 0   { p.append("\(dur.months) Months") }
            if dur.weeks != 0    { p.append("\(dur.weeks) Weeks") }
            if dur.days != 0     { p.append("\(dur.days) Days") }
            if dur.hours != 0    { p.append("\(dur.hours) Hours") }
            if dur.minutes != 0  { p.append("\(dur.minutes) Minutes") }
            if dur.seconds != 0  { p.append("\(dur.seconds) Seconds") }

            displayResult = TDDisplayResult(main: p.joined(separator: " "), secondary: nil)

            // Ne change pas le weekday si une Date est déjà commit ailleurs
            if let current = isRHS ? rhs : lhs {
                setWeekdayIfDate(current)
            } else {
                weekday = nil
            }
            return
        }

        // 3) Rien
        displayResult = TDDisplayResult(main: "0", secondary: nil)
        weekday = nil
    }


    // MARK: - Weekday helpers
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
    
    private enum FirstValueKind {
        case none
        case number
        case date
        case duration
    }

    private var firstValueKind: FirstValueKind {
        guard let lhs else { return .none }
        switch lhs {
        case .number: return .number
        case .date: return .date
        case .duration, .calendar: return .duration
        }
    }

    
}
