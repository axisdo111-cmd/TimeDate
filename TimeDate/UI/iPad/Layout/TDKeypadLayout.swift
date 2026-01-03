//
//  TDKeypadLayout.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 27/12/2025.
//

import SwiftUI

struct TDKeypadLayout {

    let keySize: CGFloat
    let spacing: CGFloat
    let columns: [GridItem]

    init(sizeClass: KeypadSizeClass) {

        switch sizeClass {

        case .compact:
            keySize = 68
            spacing = 12

        case .expanded:
            keySize = 84
            spacing = 16
        }

        columns = Array(
            repeating: GridItem(.fixed(keySize), spacing: spacing),
            count: 4
        )
    }
}

