//
//  TDCalendarQuantity.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 16/12/2025.
//

import Foundation

/// Calendar quantity (not time)
/// Used only with Date arithmetic
struct TDCalendarQuantity: Equatable {

    let years: Int
    let months: Int
    let weeks: Int
    let days: Int

    var isZero: Bool {
        years == 0 && months == 0 && weeks == 0 && days == 0
    }
}

extension TDCalendarQuantity {

    func negated() -> TDCalendarQuantity {
        TDCalendarQuantity(
            years: -years,
            months: -months,
            weeks: -weeks,
            days: -days
        )
    }
}
