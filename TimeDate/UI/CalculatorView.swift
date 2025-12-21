//
//  CalculatorView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import SwiftUI

struct CalculatorView: View {

    @StateObject private var vm = CalculatorViewModel()

    var body: some View {
        GeometryReader { geo in
            let layout = TDLayout(geo: geo)

            VStack(spacing: layout.vSpacing) {

                // Header
                HStack(spacing: 14) {
                    Button { vm.toggleMode() } label: {
                        Text(vm.mode == .calc ? "CALC" : "TIME-DATE")
                            .frame(width: 140, height: 44)
                    }
                    .buttonStyle(TDKeyButtonStyle(kind: .op))
                    .background(Color.clear)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Différence inclusive")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Toggle("", isOn: Binding(
                            get: { vm.inclusiveDiff },
                            set: { vm.setInclusiveDiff($0) }
                        ))
                        .labelsHidden()
                    }
                }

                TDDisplayCard(
                    mode: vm.mode,
                    expression: vm.expression,
                    result: vm.displayResult,
                    didJustEvaluate: vm.didJustEvaluate,
                    fixedHeight: layout.displayHeight   // 👈 on va ajouter ce param
                )
                .overlay(alignment: .topLeading) {
                    WeekdayDigitalENView(activeWeekday: vm.weekday)
                        .padding(.top, 14)
                        .padding(.leading, 20)
                        .allowsHitTesting(false)   // 🔑 OBLIGATOIRE
                }

                // ✅ FR seulement sur écrans OK
                if layout.showWeekdayBarFR {
                    WeekdayBarView(active: vm.weekday)
                }

                KeypadView(vm: vm, layout: layout)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            // .padding(.bottom, 18) Pro Max
            .padding(.top, layout.topPadding)
            .padding(.bottom, layout.bottomPadding) // Variation SE Pro Max
            .background(
                Color(.systemGroupedBackground).ignoresSafeArea()
            )
        }
    }

}

#Preview {
    CalculatorView()
}
