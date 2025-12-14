//
//  TDValue.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import Foundation

enum TDValue: Equatable {
    case number(Decimal)
    case duration(TDDuration)
    case date(Date)
}
