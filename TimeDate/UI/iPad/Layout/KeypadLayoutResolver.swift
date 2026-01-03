//
//  KeypadLayoutResolver.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 27/12/2025.
//

import UIKit

struct KeypadLayoutResolver {

    static func sizeClass(
        idiom: UIUserInterfaceIdiom,
        isLandscape: Bool
    ) -> KeypadSizeClass {

        if idiom == .pad && !isLandscape {
            return .expanded
        } else {
            return .compact
        }
    }
}
