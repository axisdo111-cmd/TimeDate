//
//  TDOptionsStore.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 19/12/2025.
//

import Foundation

@MainActor
final class TDOptionsStore: ObservableObject {
    @Published var inclusiveDiff: Bool = false
}
