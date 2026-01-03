//
//  KeypadView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 12/12/2025.
//

import SwiftUI

struct KeypadView: View {

    @ObservedObject var vm: CalculatorViewModel

    // iPhone + iPad portrait
    let layout: TDLayout?

    // iPad paysage (compact type iPhone)
    let keypadLayout: TDKeypadLayout?

    // MARK: - Constantes UI (inchangées)
    private let hPadding: CGFloat = 18
    private let bottomPadding: CGFloat = 10

    // MARK: - Helpers device/orientation (sans casser ton flow)
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var isLandscapePadMode: Bool { isPad && keypadLayout != nil } // ton mode iPad paysage existant

    // MARK: - Spacings (compat existant)
    private var vSpacing: CGFloat { layout?.vSpacing ?? 14 }

    private var keySpacing: CGFloat {
        // iPad paysage : vient de TDKeypadLayout
        if let keypadLayout { return keypadLayout.spacing }

        // iPhone / iPad portrait : spacing stable (et un peu réduit sur SE si tu veux)
        if layout?.isSmallPhone == true { return 12 }
        return 14
    }

    // MARK: - Hauteurs (carré pour touches principales)
    private var keyHeight: CGFloat {
        // iPad paysage : taille fixe TDKeypadLayout
        if let keypadLayout { return keypadLayout.keySize }

        // iPhone/iPad portrait : SE légèrement plus compact
        return (layout?.isSmallPhone == true) ? 64 : 74
    }

    private var unitKeyHeight: CGFloat { keyHeight * 0.5 }

    // MARK: - Grille
    private func grid4(keyWidth: CGFloat) -> [GridItem] {
        if isLandscapePadMode {
            // iPad paysage : compact (4 colonnes fixes)
            return Array(repeating: GridItem(.fixed(keyWidth), spacing: keySpacing), count: 4)
        } else {
            // iPhone + iPad portrait : 4 colonnes flexibles (les frames vont donner la largeur réelle)
            return Array(repeating: GridItem(.flexible(), spacing: keySpacing), count: 4)
        }
    }

    // MARK: - Calcul de largeur (LE point clé)
    private func resolvedKeyWidth(containerWidth: CGFloat) -> CGFloat {
        // Largeur dispo réelle dans KeypadView après padding horizontal
        let available = max(0, containerWidth - (hPadding * 2))

        // largeur par colonne si on remplit l’espace
        let perColumn = (available - (keySpacing * 3)) / 4

        if let keypadLayout {
            // iPad paysage : largeur fixe (compact)
            return keypadLayout.keySize
        }

        // iPhone + iPad portrait
        if isPad {
            // iPad portrait : on veut GRAND + COHÉRENT, sans être absurde
            // -> remplit l’espace, mais clamp dans une plage premium
            return min(max(perColumn, 110), 170)
        } else {
            // iPhone : remplit l’espace, clamp léger (SE inclus)
            return min(max(perColumn, 60), 96)
        }
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            let keyWidth = resolvedKeyWidth(containerWidth: geo.size.width)
            let columns = grid4(keyWidth: keyWidth)

            VStack(spacing: vSpacing) {

                // ─────────── Unités + Today ───────────
                LazyVGrid(columns: columns, spacing: keySpacing) {
                    unitKey(.years, keyWidth: keyWidth)
                    unitKey(.months, keyWidth: keyWidth)
                    unitKey(.weeks, keyWidth: keyWidth)
                    unitKey(.days, keyWidth: keyWidth)

                    unitKey(.hours, keyWidth: keyWidth)
                    unitKey(.minutes, keyWidth: keyWidth)
                    unitKey(.seconds, keyWidth: keyWidth)

                    Button { vm.tapToday() } label: {
                        Text("Today")
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .frame(width: keyWidth, height: unitKeyHeight)
                    }
                    .buttonStyle(TDKeyButtonStyle(kind: .op))
                }

                // ─────────── Clavier principal ───────────
                LazyVGrid(columns: columns, spacing: keySpacing) {

                    acBackspaceKey(keyWidth: keyWidth)

                    squareKey("/", style: .secondary, keyWidth: keyWidth) { vm.tapSeparatorSlash() }
                    squareKey(":", style: .secondary, keyWidth: keyWidth) { vm.tapSeparatorColon() }

                    squareKey("÷", style: .op, keyWidth: keyWidth) { vm.tapOp(.div) }
                        .disabled(!vm.isOperatorEnabled(.div))
                        .opacity(vm.isOperatorEnabled(.div) ? 1 : 0.35)

                    digit("7", keyWidth: keyWidth); digit("8", keyWidth: keyWidth); digit("9", keyWidth: keyWidth)

                    squareKey("×", style: .op, keyWidth: keyWidth) { vm.tapOp(.mul) }
                        .disabled(!vm.isOperatorEnabled(.mul))
                        .opacity(vm.isOperatorEnabled(.mul) ? 1 : 0.35)

                    digit("4", keyWidth: keyWidth); digit("5", keyWidth: keyWidth); digit("6", keyWidth: keyWidth)
                    squareKey("−", style: .op, keyWidth: keyWidth) { vm.tapOp(.sub) }

                    digit("1", keyWidth: keyWidth); digit("2", keyWidth: keyWidth); digit("3", keyWidth: keyWidth)
                    squareKey("+", style: .op, keyWidth: keyWidth) { vm.tapOp(.add) }

                    digit("0", keyWidth: keyWidth)
                    squareKey(".", style: .secondary, keyWidth: keyWidth) { vm.tapDot() }
                    squareKey("%", style: .secondary, keyWidth: keyWidth) { vm.tapPercent() }
                    squareKey("=", style: .equals, keyWidth: keyWidth) { vm.tapEquals() }
                }

                Spacer(minLength: 0) // ✅ la “dernière ligne” qui manque souvent sur SE (stabilité vertical)
            }
            .padding(.horizontal, hPadding)
            .padding(.bottom, bottomPadding)
        }
        // Important: donne une hauteur minimum au GeometryReader pour éviter l’écrasement en SE
        .frame(minHeight: 10)
    }

    // MARK: - Keys
    private func unitKey(_ u: UnitKind, keyWidth: CGFloat) -> some View {
        Button { vm.tapUnit(u) } label: {
            Text(u.title)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(width: keyWidth, height: unitKeyHeight)
        }
        .buttonStyle(TDKeyButtonStyle(kind: .unit))
    }

    private func acBackspaceKey(keyWidth: CGFloat) -> some View {
        Button { vm.tapACorBack() } label: {
            Text(vm.acKeyLabel == "←" ? "⌫" : "AC")
                .font(.system(size: vm.acKeyLabel == "←" ? 28 : 18, weight: .semibold))
                .frame(width: keyWidth, height: keyHeight)
        }
        .buttonStyle(TDKeyButtonStyle(kind: .danger))
    }

    private enum SquareStyle { case secondary, op, equals }

    private func digit(_ d: String, keyWidth: CGFloat) -> some View {
        squareKey(d, style: .secondary, keyWidth: keyWidth) { vm.tapDigit(d) }
    }

    private func squareKey(
        _ title: String,
        style: SquareStyle,
        keyWidth: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .frame(width: keyWidth, height: keyHeight)
        }
        .buttonStyle(buttonStyle(style))
    }

    private func buttonStyle(_ style: SquareStyle) -> TDKeyButtonStyle {
        switch style {
        case .secondary: return TDKeyButtonStyle(kind: .number)
        case .op:        return TDKeyButtonStyle(kind: .op)
        case .equals:    return TDKeyButtonStyle(kind: .equals)
        }
    }
}
