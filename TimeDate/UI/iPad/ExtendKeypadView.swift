//
//  ExtendKeypadView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 26/12/2025.
//

import SwiftUI

// MARK: - Extend mode

enum ExtendMode: String, CaseIterable, Identifiable {
    case scientific = "Scientific"
    case civil      = "Civil"
    case work       = "Work"

    var id: String { rawValue }
}

// MARK: - Extend keys

enum ExtendKey: Hashable {

    // Scientific
    case sin, cos, tan, pi
    case ln, log, sqrt, pow2

    // Civil
    case date, time, diff, iso
    case week, workday, leap, timezone

    // Work
    case memo, set, call, run
    case undo, redo, copy, paste
}

// MARK: - View

struct ExtendKeypadView: View {

    let mode: ExtendMode
    let keypadLayout: TDKeypadLayout
    let onKeyPress: (ExtendKey) -> Void

    private let radius: CGFloat = 18

    // MARK: - Layout helpers

    private var keySize: CGFloat { keypadLayout.keySize }
    private var spacing: CGFloat { keypadLayout.spacing }

    private var grid4: [GridItem] {
        Array(
            repeating: GridItem(.fixed(keySize), spacing: spacing),
            count: 4
        )
    }

    // MARK: - Init

    init(
        mode: ExtendMode = .scientific,
        keypadLayout: TDKeypadLayout,
        onKeyPress: @escaping (ExtendKey) -> Void = { _ in }
    ) {
        self.mode = mode
        self.keypadLayout = keypadLayout
        self.onKeyPress = onKeyPress
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: spacing) {

            // Mode selector (visuel premium, désactivé pour l’instant)
            Picker("", selection: .constant(mode)) {
                ForEach(ExtendMode.allCases) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .disabled(true)
            .opacity(0.55)

            // Grille de touches
            LazyVGrid(columns: grid4, spacing: spacing) {
                ForEach(keysForMode(mode), id: \.self) { key in
                    keyButton(key)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 10)
        .background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.001))
        )
    }

    // MARK: - Keys

    private func keyButton(_ key: ExtendKey) -> some View {
        Button {
            onKeyPress(key)
        } label: {
            Text(title(for: key))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(width: keySize, height: keySize)
        }
        .buttonStyle(TDKeyButtonStyle(kind: .number))
    }

    private func keysForMode(_ mode: ExtendMode) -> [ExtendKey] {
        switch mode {
        case .scientific:
            return [.sin, .cos, .tan, .pi,
                    .ln, .log, .sqrt, .pow2]
        case .civil:
            return [.date, .time, .diff, .iso,
                    .week, .workday, .leap, .timezone]
        case .work:
            return [.memo, .set, .call, .run,
                    .undo, .redo, .copy, .paste]
        }
    }

    private func title(for key: ExtendKey) -> String {
        switch key {
        case .sin: return "sin"
        case .cos: return "cos"
        case .tan: return "tan"
        case .pi: return "π"

        case .ln: return "ln"
        case .log: return "log"
        case .sqrt: return "√"
        case .pow2: return "x²"

        case .date: return "Date"
        case .time: return "Time"
        case .diff: return "Diff"
        case .iso: return "ISO"

        case .week: return "Week"
        case .workday: return "Work"
        case .leap: return "Leap"
        case .timezone: return "TZ"

        case .memo: return "Memo"
        case .set: return "Set"
        case .call: return "Call"
        case .run: return "Run"

        case .undo: return "Undo"
        case .redo: return "Redo"
        case .copy: return "Copy"
        case .paste: return "Paste"
        }
    }
}
