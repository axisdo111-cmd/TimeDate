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
        VStack(spacing: 18) {

            // Header
            HStack(spacing: 14) {

                Button { vm.toggleMode() } label: {
                    Text(vm.mode == .calc ? "CALC" : "DATE-TIME")
                        .frame(maxWidth: 140)
                }
                .buttonStyle(TDButtonStyle(primary: true))

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
                didJustEvaluate: vm.didJustEvaluate
            )

            WeekdayBarView(active: vm.weekday)

            KeypadView(vm: vm)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
        .padding(.top, 10) // descend sous l’îlot
        .background(
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    CalculatorView()
}
