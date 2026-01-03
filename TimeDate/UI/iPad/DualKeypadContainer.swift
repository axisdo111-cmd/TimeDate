//
//  DualKeypadContainer.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 26/12/2025.
//
//  Conteneur bas pour 2 claviers (Keypad + ExtendKeypad)
//  Gère uniquement l'inversion Droitier / Gaucher
//

//
//  DualKeypadContainer.swift
//  TimeDate
//
//  Conteneur bas pour 2 claviers (Keypad + ExtendKeypad)
//  Gère uniquement l'inversion Droitier / Gaucher
//

import SwiftUI

// MARK: - DualKeypadContainer

struct DualKeypadContainer<
    PrimaryKeypad: View,
    SecondaryKeypad: View
>: View {

    let handedness: Handedness
    let primaryKeypad: PrimaryKeypad
    let secondaryKeypad: SecondaryKeypad

    private let keypadWidth: CGFloat = 380

    init(
        handedness: Handedness = .right,
        @ViewBuilder primaryKeypad: () -> PrimaryKeypad,
        @ViewBuilder secondaryKeypad: () -> SecondaryKeypad
    ) {
        self.handedness = handedness
        self.primaryKeypad = primaryKeypad()
        self.secondaryKeypad = secondaryKeypad()
    }

    var body: some View {
        HStack(alignment: .bottom) {

            if handedness == .right {
                secondaryKeypadView
                Spacer(minLength: 40)
                primaryKeypadView
            } else {
                primaryKeypadView
                Spacer(minLength: 40)
                secondaryKeypadView
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Private views

    private var primaryKeypadView: some View {
        primaryKeypad
            .frame(width: keypadWidth)
            .fixedSize(horizontal: true, vertical: false)
    }

    private var secondaryKeypadView: some View {
        secondaryKeypad
            .frame(width: keypadWidth)
            .fixedSize(horizontal: true, vertical: false)
    }
}
