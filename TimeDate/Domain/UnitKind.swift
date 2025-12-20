//
//  UnitKind.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import Foundation

enum UnitKind: CaseIterable {
    case years
    case months
    case weeks
    case days
    case hours
    case minutes
    case seconds

    var title: String {
        switch self {
        case .years: return "Years"
        case .months: return "Months"
        case .weeks: return "Weeks"
        case .days: return "Days"
        case .hours: return "Hours"
        case .minutes: return "Minutes"
        case .seconds: return "Seconds"
        }
    }

    /// Unité dépendante du calendrier
     var isCalendarBased: Bool {
         switch self {
         case .years, .months:
             return true
         default:
             return false
         }
     }
    
    enum UnitCategory {
        case calendar    // années, mois
        case dayBased    // semaines, jours
        case time        // h, m, s
    }
    
    var category: UnitCategory {
        switch self {
        case .years, .months:
            return .calendar
        case .weeks, .days:
            return .dayBased
        case .hours, .minutes, .seconds:
            return .time
        }
    }
    
    /// Always calendar-dependent
    var isStrictCalendarUnit: Bool {
        category == .calendar || category == .dayBased
    }
    
    /// Calendar-dependent depending on context (Date vs Duration)
    var isCalendarUnit: Bool {
        category == .calendar || category == .dayBased
    }

    var isTimeUnit: Bool {
        category == .time
    }

    
}
