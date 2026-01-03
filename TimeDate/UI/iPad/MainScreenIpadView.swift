//
//  MainScreenIpadView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 27/12/2025.
//
//  Écran principal iPad (haut)
//  Expression + Résultat + Mode
//

import SwiftUI

struct MainScreenIpadView: View {

    @ObservedObject var vm: CalculatorViewModel

    var body: some View {
        VStack(spacing: 12) {

            // ─────────── Mode + Action ───────────
            HStack {
                Button {
                    vm.toggleMode()
                } label: {
                    Text(vm.mode == .calc ? "CALC" : "TIME-DATE")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .frame(width: 120, height: 40)
                }
                .buttonStyle(TDKeyButtonStyle(kind: .op))

                Spacer()
            }

            // ─────────── CARTE LCD PRINCIPALE ───────────
            TDDisplayCard(
                mode: vm.mode,
                expression: vm.expression,
                result: vm.displayResult,
                didJustEvaluate: vm.didJustEvaluate,
                fixedHeight: nil    // 👈 iPad = hauteur libre
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
