//
//  KeypadView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import SwiftUI

struct KeypadView: View {
    @ObservedObject var vm: CalculatorViewModel

    // MARK: - Layout
    private let spacing: CGFloat = 14
    private let keySize: CGFloat = 74     // iPhone 15 Pro Max friendly
    private let radius: CGFloat = 18

    private var grid4: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: 4)
    }

    var body: some View {
        VStack(spacing: 16) {

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

                Button("Today") { vm.tapToday() }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
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
                squareKey("C", style: .danger) { vm.clear() }
                squareKey("/", style: .secondary) { vm.tapSeparatorSlash() }
                squareKey(":", style: .secondary) { vm.tapSeparatorColon() }
                squareKey("÷", style: .op) { vm.tapOp(.div) }

                // Row 2
                digit("7"); digit("8"); digit("9")
                squareKey("×", style: .op) { vm.tapOp(.mul) }

                // Row 3
                digit("4"); digit("5"); digit("6")
                squareKey("−", style: .op) { vm.tapOp(.sub) }

                // Row 4
                digit("1"); digit("2"); digit("3")
                squareKey("+", style: .op) { vm.tapOp(.add) }

                // Row 5 (IMPORTANT: ⌫ entre . et =)
                digit("0")
                squareKey(".", style: .secondary) { vm.tapDot() }
                squareKey("⌫", style: .secondary) { vm.tapBackspace() }
                squareKey("=", style: .equals) { vm.tapEquals() }
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 10)
    }

    // MARK: - Unit keys (rectangles)
    private func unitKey(_ u: UnitKind) -> some View {
        Button(u.title) { vm.tapUnit(u) }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color(.secondarySystemBackground))
            .foregroundColor(.blue)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
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
                .frame(width: keySize, height: keySize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(background(style))
        .foregroundColor(foreground(style))
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

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
}
