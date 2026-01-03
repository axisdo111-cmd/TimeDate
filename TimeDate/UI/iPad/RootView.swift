//
//  LandscapeMainView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 26/12/2025.
//

import SwiftUI

struct RootView: View {
    
    @StateObject private var vm = CalculatorViewModel()
    
    var body: some View {
        GeometryReader { geo in
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let isLandscape = geo.size.width > geo.size.height
            
            let sizeClass: KeypadSizeClass =
            (isPad && !isLandscape) ? .expanded : .compact
            
            let keypadLayout = TDKeypadLayout(sizeClass: sizeClass)
            
            if isPad && isLandscape {
                CalculatorIpadLandscapeView(
                    mainScreen: {
                        MainScreenIpadView(vm: vm)
                    },
                    centerScreen: {
                        CentralDisplayView(vm: vm)
                    },
                    primaryKeypad: {
                        KeypadView(
                            vm: vm,
                            layout: nil,                 // 👈 IMPORTANT
                            keypadLayout: keypadLayout   // 👈 iPad paysage
                        )
                    },
                    secondaryKeypad: {
                        ExtendKeypadView(
                            mode: .scientific,
                            keypadLayout: keypadLayout
                        ) { key in
                            // vm.tapExtendKey(key)
                        }
                    },
                    fallback: {
                        CalculatorView()
                    }
                )
            } else {
                CalculatorView()
            }
        }
    }
}
