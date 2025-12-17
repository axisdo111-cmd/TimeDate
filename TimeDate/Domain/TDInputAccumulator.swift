//
//  TDInputAccumulator.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 16/12/2025.
//

import Foundation

struct TDInputAccumulator {
    var number: Decimal = 0
    var units: [UnitKind: Int] = [:]
    var hasToday = false
    var hasAbsoluteDate = false
}
