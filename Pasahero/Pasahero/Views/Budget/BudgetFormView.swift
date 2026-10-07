//
//  BudgetFormView.swift
//  Pasahero
//
//  CREATE + UPDATE form for the monthly Budget.
//

import SwiftUI
import SwiftData

struct BudgetFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let budget: Budget?

    @State private var label: String
    @State private var limitText: String
    @State private var warningThreshold: Double

    init(budget: Budget? = nil) {
        self.budget = budget
        _label = State(initialValue: budget?.label ?? "Commute Budget")
        _limitText = State(initialValue: budget?.monthlyLimit.editableString ?? "")
        _warningThreshold = State(initialValue: budget?.warningThreshold ?? 0.8)
    }

    private var isEditing: Bool { budget != nil }
    private var limit: Double? { limitText.moneyValue }
    private var isValid: Bool { !label.trimmed.isEmpty && (limit ?? 0) > 0 }

    private let presets: [Double] = [500, 1000, 1500, 2000, 3000]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Budget name", text: $label)
                }

                Section {
                    HStack(spacing: 8) {
                        Text("₱")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $limitText)
                            .keyboardType(.decimalPad)
                            .font(.title2.weight(.bold))
                            .monospacedDigit()
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(presets, id: \.self) { preset in
                                Button(preset.pesoCompact) {
                                    limitText = preset.editableString
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                .tint(limit == preset ? Theme.brand : .gray)
                            }
                        }
                    }
                } header: {
                    Text("Monthly Limit")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Warn me at")
                            Spacer()
                            Text("\(Int(warningThreshold * 100))%")
                                .fontWeight(.semibold)
                                .monospacedDigit()
                                .foregroundStyle(Theme.warning)
                        }
                        Slider(value: $warningThreshold, in: 0.5...1.0, step: 0.05)
                            .tint(Theme.warning)
                    }
                } header: {
                    Text("Alert")
                } footer: {
                    if let limit, limit > 0 {
                        Text("The status changes to “Near limit” once you spend \((limit * warningThreshold).peso).")
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Budget" : "Set Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    /// CREATE or UPDATE the budget.
    private func save() {
        guard let limit, isValid else { return }

        if let budget {
            budget.label = label.trimmed
            budget.monthlyLimit = limit
            budget.warningThreshold = warningThreshold
            budget.updatedAt = .now
        } else {
            let newBudget = Budget(label: label.trimmed, monthlyLimit: limit, warningThreshold: warningThreshold)
            modelContext.insert(newBudget)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save budget: \(error.localizedDescription)")
        }
        dismiss()
    }
}

#Preview {
    BudgetFormView()
        .modelContainer(PreviewData.container)
}
