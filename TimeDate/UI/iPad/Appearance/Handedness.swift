//
//  Handedness.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 27/12/2025.
//

import Foundation

enum Handedness: String, CaseIterable, Identifiable {
    case right = "Droitier"
    case left  = "Gaucher"

    var id: String { rawValue }
}
