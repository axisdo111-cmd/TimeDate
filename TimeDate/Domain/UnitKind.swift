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
}
