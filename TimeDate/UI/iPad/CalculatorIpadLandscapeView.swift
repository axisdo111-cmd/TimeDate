//
//  CalculatorIpadLandscapeView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 26/12/2025.
//

import SwiftUI
import UIKit

struct CalculatorIpadLandscapeView<
    MainScreen: View,
    CenterScreen: View,
    PrimaryKeypad: View,
    SecondaryKeypad: View,
    Fallback: View
>: View {

    // UI State (local iPad only)
    @State private var handedness: Handedness = .right

    // Injected views
    private let mainScreen: MainScreen
    private let centerScreen: CenterScreen
    private let primaryKeypad: PrimaryKeypad
    private let secondaryKeypad: SecondaryKeypad
    private let fallback: Fallback

    init(
        @ViewBuilder mainScreen: () -> MainScreen,
        @ViewBuilder centerScreen: () -> CenterScreen,
        @ViewBuilder primaryKeypad: () -> PrimaryKeypad,
        @ViewBuilder secondaryKeypad: () -> SecondaryKeypad,
        @ViewBuilder fallback: () -> Fallback
    ) {
        self.mainScreen = mainScreen()
        self.centerScreen = centerScreen()
        self.primaryKeypad = primaryKeypad()
        self.secondaryKeypad = secondaryKeypad()
        self.fallback = fallback()
    }

    var body: some View {
        GeometryReader { geo in
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let isLandscape = geo.size.width > geo.size.height

            if isPad && isLandscape {
                DeviceFrameView {
                    VStack(spacing: 14) {

                        // Top main screen (90% width)
                        mainScreen
                            .frame(maxWidth: geo.size.width * 0.90)
                            .frame(maxWidth: .infinity)

                        // Center display (max height)
                        centerScreen
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)

                        // Handedness selector
                        Picker("", selection: $handedness) {
                            ForEach(Handedness.allCases) { h in
                                Text(h.rawValue).tag(h)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 260)

                        // Bottom dual keypad
                        DualKeypadContainer(handedness: handedness) {
                            primaryKeypad
                        } secondaryKeypad: {
                            secondaryKeypad
                        }
                    }
                }
            } else {
                fallback
            }
        }
    }
}
