//
//  CentralDisplayView.swift
//  TimeDate
//
//  Created by Daniel PHAM-LE-THANH on 26/12/2025.
//
//  Zone centrale iPad (paysage)
//  Résultats intermédiaires / messages / historique
//

import SwiftUI

struct CentralDisplayView: View {

    @ObservedObject var vm: CalculatorViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // ─────────── Section Résultat intermédiaire ───────────
                section(title: "Résultat") {
                    Text(intermediateResultText)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // ─────────── Section Détails ───────────
                if let detail = detailText {
                    section(title: "Détails") {
                        Text(detail)
                            .font(.system(size: 15, weight: .regular, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }

                // ─────────── Section Contexte / Messages ───────────
                if let context = contextText {
                    section(title: "Contexte") {
                        Text(context)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemGroupedBackground))
        )
    }

    // MARK: - Computed display texts (UI only)

    private var intermediateResultText: String {
        // UI-safe placeholder
        if vm.displayResult.main.isEmpty {
            return "—"
        }
        return vm.displayResult.main
    }

    private var detailText: String? {
        // Exemple : afficher la ligne secondaire si présente
        vm.displayResult.secondary
    }

    private var contextText: String? {
        switch vm.mode {
        case .calc:
            return "Mode calcul"
        case .dateTime:
            return vm.inclusiveDiff
                ? "Différence inclusive activée"
                : "Différence inclusive désactivée"
        }
    }

    // MARK: - Section helper

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            content()
        }
    }
}
