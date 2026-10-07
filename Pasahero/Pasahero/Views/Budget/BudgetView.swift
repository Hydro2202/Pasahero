//
//  BudgetView.swift
//  Pasahero
//
//  Budget tab: CRUD for the Budget model plus data-management tools.
//

import SwiftUI
import SwiftData

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Budget.createdAt) private var budgets: [Budget]
    @Query private var trips: [Trip]
    @Query private var routes: [SavedRoute]

    @State private var showingEditor = false
    @State private var confirmingDeleteBudget = false
    @State private var confirmingDeleteTrips = false
    @State private var showingSampleLoaded = false

    private var budget: Budget? { budgets.first }

    private var spentThisMonth: Double {
        trips.filter { $0.date.isInCurrentMonth }
            .reduce(0) { $0 + $1.totalFare }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let budget {
                        BudgetSummaryCard(budget: budget, spent: spentThisMonth)
                    } else {
                        ContentUnavailableView {
                            Label("No budget yet", systemImage: "wallet.pass")
                        } description: {
                            Text("Set a monthly fare limit to see how much you can still spend.")
                        } actions: {
                            Button("Set Monthly Budget") { showingEditor = true }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }

                if budget != nil {
                    Section("Manage Budget") {
                        Button {
                            showingEditor = true
                        } label: {
                            Label("Edit Budget", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            confirmingDeleteBudget = true
                        } label: {
                            Label("Delete Budget", systemImage: "trash")
                                .foregroundStyle(Theme.danger)
                        }
                    }
                }

                Section {
                    LabeledContent {
                        Text("\(trips.count)").monospacedDigit()
                    } label: {
                        Label("Trips", systemImage: "list.bullet.rectangle.portrait")
                    }
                    LabeledContent {
                        Text("\(routes.count)").monospacedDigit()
                    } label: {
                        Label("Saved routes", systemImage: "bookmark")
                    }
                    LabeledContent {
                        Text("SwiftData")
                    } label: {
                        Label("Storage", systemImage: "internaldrive")
                    }
                } header: {
                    Text("Your Data")
                } footer: {
                    Text("All records are stored privately on this device and stay saved after you close the app.")
                }

                Section("Tools") {
                    Button {
                        SampleData.insert(into: modelContext, includeBudget: budget == nil)
                        showingSampleLoaded = true
                    } label: {
                        Label("Load Sample Data", systemImage: "wand.and.stars")
                    }

                    Button(role: .destructive) {
                        confirmingDeleteTrips = true
                    } label: {
                        Label("Delete All Trips", systemImage: "trash.slash")
                            .foregroundStyle(Theme.danger)
                    }
                    .disabled(trips.isEmpty)
                }

                Section {
                    VStack(spacing: 6) {
                        Text("Pasahero")
                            .font(.headline)
                        Text("Commute Fare Log · Version 1.0")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Budget")
            .sheet(isPresented: $showingEditor) {
                BudgetFormView(budget: budget)
            }
            .confirmationDialog("Delete your budget?", isPresented: $confirmingDeleteBudget, titleVisibility: .visible) {
                Button("Delete Budget", role: .destructive) { deleteBudget() }
            } message: {
                Text("Your trips will not be affected.")
            }
            .confirmationDialog("Delete all trips?", isPresented: $confirmingDeleteTrips, titleVisibility: .visible) {
                Button("Delete \(trips.count) Trips", role: .destructive) { deleteAllTrips() }
            } message: {
                Text("This permanently removes every trip record. Saved routes and your budget are kept.")
            }
            .alert("Sample data added", isPresented: $showingSampleLoaded) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Demo routes and trips were added so you can explore the app.")
            }
        }
    }

    // MARK: - Actions

    /// DELETE — remove the budget record.
    private func deleteBudget() {
        guard let budget else { return }
        withAnimation {
            modelContext.delete(budget)
            try? modelContext.save()
        }
    }

    /// DELETE (batch) — remove every Trip record.
    private func deleteAllTrips() {
        withAnimation {
            do {
                for trip in trips {
                    modelContext.delete(trip)
                }
                try modelContext.save()
            } catch {
                print("Failed to delete trips: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    BudgetView()
        .modelContainer(PreviewData.container)
}
