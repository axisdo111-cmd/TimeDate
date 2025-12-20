//
//  TDInputAccumulator.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 16/12/2025.
//

import Foundation

struct TDInputAccumulator {
    var number: Decimal = 0 {
        didSet {
            if number < 0 {
                number = abs(number)
            }
        }
    }
    var units: [UnitKind: Int] = [:]
    var hasToday = false
    var hasAbsoluteDate = false
    
    mutating func resetForTime() {
        number = 0          // 🔒 jamais négatif
        units.removeAll()
        hasToday = false
        hasAbsoluteDate = false
    }

}

