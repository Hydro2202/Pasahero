//
//  BudgetSummaryCard.swift
//  Pasahero
//
//  Shows how much of the monthly budget has been used.
//

import SwiftUI

struct BudgetSummaryCard: View {
    let budget: Budget
    let spent: Double

    private var status: BudgetStatus { budget.status(for: spent) }
    private var progress: Double { budget.progress(for: spent) }
    private var remaining: Double { budget.monthlyLimit - spent }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(budget.label)
                        .font(.headline)
                    Text(Date.now, format: .dateTime.month(.wide).year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Label(status.title, systemImage: status.symbol)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(status.color.opacity(0.15), in: Capsule())
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(spent.peso)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("of \(budget.monthlyLimit.peso)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            CapsuleProgressBar(progress: progress, tint: status.color, height: 12)

            HStack {
                Text(remaining >= 0 ? "\(remaining.peso) left" : "\((-remaining).peso) over")
                    .fontWeight(.semibold)
                    .foregroundStyle(remaining >= 0 ? Color.primary : Theme.danger)
                Spacer()
                Text("\(Int((progress * 100).rounded()))% used")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .monospacedDigit()

            HStack(spacing: 6) {
                Image(systemName: "bell.badge")
                Text("Warning at \(Int(budget.warningThreshold * 100))% of the limit")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}
