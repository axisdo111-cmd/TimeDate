//
//  KeypadView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import SwiftUI

struct KeypadView: View {
    @ObservedObject var vm: CalculatorViewModel
    let layout: TDLayout

    // MARK: - Layout
    private let spacing: CGFloat = 14
    private let keySize: CGFloat = 74     // iPhone 15 Pro Max friendly
    // iPad
    private var keyWidth: CGFloat {
        74 * layout.keyWidthMultiplier
    }
    private let keyHeight: CGFloat = 74

    private let radius: CGFloat = 18

    // Taille des boutons temporels
    private let unitKeyHeight: CGFloat = 38  // ≈ 1/2 hauteur


    private var grid4: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4)
    }

    var body: some View {
        VStack(spacing: layout.vSpacing) {

            // ─────────────────────────────
            // Unités + Today (4 colonnes)
            // ─────────────────────────────
            LazyVGrid(columns: grid4, spacing: spacing) {
                unitKey(.years)
                unitKey(.months)
                unitKey(.weeks)
                unitKey(.days)

                unitKey(.hours)
                unitKey(.minutes)
                unitKey(.seconds)

                Button {
                    vm.tapToday()
                } label: {
                    Text("Today")
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: keyWidth, height: unitKeyHeight)
                }
                .buttonStyle(TDKeyButtonStyle(kind: .op))

            }

            // ─────────────────────────────
            // Grille Calculatrice (carrés)
            // C  /  :  ÷
            // 7  8  9  ×
            // 4  5  6  −
            // 1  2  3  +
            // 0  .  ⌫  =
            // ─────────────────────────────
            LazyVGrid(columns: grid4, spacing: spacing) {

                // Row 1
                acBackspaceKey()
                squareKey("/", style: .secondary) { vm.tapSeparatorSlash() }
                squareKey(":", style: .secondary) { vm.tapSeparatorColon() }
                //squareKey("÷", style: .op) { vm.tapOp(.div) }
                squareKey("÷", style: .op) { vm.tapOp(.div) }
                    .disabled(!vm.isOperatorEnabled(.div))
                    .opacity(vm.isOperatorEnabled(.div) ? 1 : 0.35)
                
                // Row 2
                digit("7"); digit("8"); digit("9")
                //squareKey("×", style: .op) { vm.tapOp(.mul) }
                squareKey("×", style: .op) { vm.tapOp(.mul) }
                    .disabled(!vm.isOperatorEnabled(.mul))
                    .opacity(vm.isOperatorEnabled(.mul) ? 1 : 0.35)

                // Row 3
                digit("4"); digit("5"); digit("6")
                squareKey("−", style: .op) { vm.tapOp(.sub) }

                // Row 4
                digit("1"); digit("2"); digit("3")
                squareKey("+", style: .op) { vm.tapOp(.add) }

                // Row 5 (IMPORTANT: ⌫ entre . et =)
                digit("0")
                squareKey(".", style: .secondary) { vm.tapDot() }
                squareKey("%", style: .secondary) { vm.tapPercent() }
                squareKey("=", style: .equals) { vm.tapEquals() }
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 10)
    }

    // MARK: - Unit keys (rectangles)
    private func unitKey(_ u: UnitKind) -> some View {
        Button {
            vm.tapUnit(u)
        } label: {
            Text(u.title)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: keyWidth, height: unitKeyHeight)
        }
        .buttonStyle(TDKeyButtonStyle(kind: .unit))
    }

    // MARK: - AC / Backspace key
    private func acBackspaceKey() -> some View {
        Button {
            vm.tapACorBack()
        } label: {
            ZStack {
                if vm.acKeyLabel == "←" {
                    Text("⌫")
                        .font(.system(size: 28, weight: .semibold))
                } else {
                    Text("AC")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .frame(width: keyWidth, height: keyHeight)
        }
        .buttonStyle(TDKeyButtonStyle(kind: .danger))
    }


    // MARK: - Square calculator keys
    private enum SquareStyle { case secondary, op, equals, danger }

    private func digit(_ d: String) -> some View {
        squareKey(d, style: .secondary) { vm.tapDigit(d) }
    }

    private func squareKey(_ title: String, style: SquareStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .frame(width: keyWidth, height: keyHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(buttonStyle(style))

    }

    // ==============================
    // HELPER
    // ==============================
    
    private func background(_ style: SquareStyle) -> Color {
        switch style {
        case .secondary: return Color(.secondarySystemBackground)
        case .op:        return Color.blue
        case .equals:    return Color.orange
        case .danger:    return Color.red
        }
    }

    private func foreground(_ style: SquareStyle) -> Color {
        switch style {
        case .secondary: return Color.blue
        case .op, .equals, .danger: return .white
        }
    }
    
    private func buttonStyle(_ style: SquareStyle) -> TDKeyButtonStyle {
        switch style {
        case .secondary: return TDKeyButtonStyle(kind: .number)
        case .op:        return TDKeyButtonStyle(kind: .op)
        case .equals:    return TDKeyButtonStyle(kind: .equals)
        case .danger:    return TDKeyButtonStyle(kind: .danger)
        }
    }

}
