//
//  TDDuration.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//
//  PRO / Premium — Canonical & Stable
//

import Foundation

/// Canonical duration type.
/// - Internal storage: seconds only
/// - No Calendar
/// - No UI logic
/// - No approximation
struct TDDuration: Equatable {

    /// Canonical storage (>= 0)
    let seconds: Int

    // MARK: - Init

    init(seconds: Int = 0) {
        self.seconds = max(0, seconds)
    }

    // MARK: - Decomposition (low-level, math only)

    /// Decompose seconds into days / hours / minutes / seconds
    /// (Used by formatter)
    func components() -> DateComponents {
        var remaining = seconds

        let days = remaining / 86_400
        remaining %= 86_400

        let hours = remaining / 3_600
        remaining %= 3_600

        let minutes = remaining / 60
        let seconds = remaining % 60

        var comps = DateComponents()
        comps.day = days
        comps.hour = hours
        comps.minute = minutes
        comps.second = seconds
        return comps
    }
}
