//
//  TDGregorianRules.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 19/12/2025.
//

import Foundation

enum TDGregorianRules {
    static let startDate: Date = {
        var c = DateComponents()
        c.year = 1582
        c.month = 10
        c.day = 15
        return Calendar(identifier: .gregorian).date(from: c)!
    }()
}
