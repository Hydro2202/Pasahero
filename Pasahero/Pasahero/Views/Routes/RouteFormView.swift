//
//  RouteFormView.swift
//  Pasahero
//
//  CREATE + UPDATE form for SavedRoute.
//

import SwiftUI
import SwiftData

struct RouteFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let route: SavedRoute?

    @State private var name: String
    @State private var origin: String
    @State private var destination: String
    @State private var fareText: String
    @State private var vehicleType: VehicleType
    @State private var isFavorite: Bool

    init(route: SavedRoute? = nil) {
        self.route = route
        _name        = State(initialValue: route?.name ?? "")
        _origin      = State(initialValue: route?.origin ?? "")
        _destination = State(initialValue: route?.destination ?? "")
        _fareText    = State(initialValue: route?.defaultFare.editableString ?? "")
        _vehicleType = State(initialValue: route?.vehicleType ?? .jeepney)
        _isFavorite  = State(initialValue: route?.isFavorite ?? true)
    }

    private var isEditing: Bool { route != nil }
    private var fare: Double? { fareText.moneyValue }

    private var isValid: Bool {
        !name.trimmed.isEmpty
            && !origin.trimmed.isEmpty
            && !destination.trimmed.isEmpty
            && (fare ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Route name (e.g. Home to School)", text: $name)
                        .textInputAutocapitalization(.words)
                    Toggle(isOn: $isFavorite) {
                        Label("Show on Home", systemImage: "star.fill")
                    }
                    .tint(Theme.accent)
                } header: {
                    Text("Details")
                } footer: {
                    Text("Favorite routes appear on the Home screen for quick logging.")
                }

                Section("Vehicle") {
                    VehiclePicker(selection: $vehicleType)
                        .listRowInsets(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                }

                Section("Route") {
                    HStack(spacing: 12) {
                        Image(systemName: "circle.circle.fill")
                            .foregroundStyle(Theme.brand)
                        TextField("Origin", text: $origin)
                            .textInputAutocapitalization(.words)
                    }
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Theme.danger)
                        TextField("Destination", text: $destination)
                            .textInputAutocapitalization(.words)
                    }
                }

                Section("Usual Fare") {
                    HStack(spacing: 8) {
                        Text("₱")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $fareText)
                            .keyboardType(.decimalPad)
                            .font(.title3.weight(.semibold))
                            .monospacedDigit()
                    }
                }

                if let route, !route.trips.isEmpty {
                    Section("Usage") {
                        LabeledContent("Trips logged", value: "\(route.trips.count)")
                        LabeledContent("Total spent", value: route.totalSpent.peso)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Route" : "New Route")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    /// CREATE or UPDATE the route.
    private func save() {
        guard let fare, isValid else { return }

        if let route {
            route.name = name.trimmed
            route.origin = origin.trimmed
            route.destination = destination.trimmed
            route.defaultFare = fare
            route.vehicleType = vehicleType
            route.isFavorite = isFavorite
        } else {
            let newRoute = SavedRoute(
                name: name.trimmed,
                origin: origin.trimmed,
                destination: destination.trimmed,
                defaultFare: fare,
                vehicleType: vehicleType,
                isFavorite: isFavorite
            )
            modelContext.insert(newRoute)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save route: \(error.localizedDescription)")
        }
        dismiss()
    }
}

#Preview {
    RouteFormView()
        .modelContainer(PreviewData.container)
}
