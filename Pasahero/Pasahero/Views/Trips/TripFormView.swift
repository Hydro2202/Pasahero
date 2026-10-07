//
//  TripFormView.swift
//  Pasahero
//
//  CREATE + UPDATE: One form used both to add a new trip and to edit
//  an existing one. Changes are written through the ModelContext.
//

import SwiftUI
import SwiftData

struct TripFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Saved routes the user can pick from to pre-fill the form.
    @Query(sort: \SavedRoute.name) private var routes: [SavedRoute]

    /// The trip being edited, or `nil` when creating a new one.
    private let trip: Trip?

    @State private var origin: String
    @State private var destination: String
    @State private var fareText: String
    @State private var date: Date
    @State private var vehicleType: VehicleType
    @State private var passengers: Int
    @State private var notes: String
    @State private var selectedRoute: SavedRoute?

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case origin, destination, fare, notes
    }

    // MARK: - Init

    /// - Parameters:
    ///   - trip: Pass an existing trip to edit it; leave `nil` to create one.
    ///   - prefillRoute: Optional saved route used to pre-fill a new trip.
    init(trip: Trip? = nil, prefillRoute: SavedRoute? = nil) {
        self.trip = trip
        _origin       = State(initialValue: trip?.origin ?? prefillRoute?.origin ?? "")
        _destination  = State(initialValue: trip?.destination ?? prefillRoute?.destination ?? "")
        _fareText     = State(initialValue: (trip?.fare ?? prefillRoute?.defaultFare)?.editableString ?? "")
        _date         = State(initialValue: trip?.date ?? .now)
        _vehicleType  = State(initialValue: trip?.vehicleType ?? prefillRoute?.vehicleType ?? .jeepney)
        _passengers   = State(initialValue: trip?.passengers ?? 1)
        _notes        = State(initialValue: trip?.notes ?? "")
        _selectedRoute = State(initialValue: trip?.route ?? prefillRoute)
    }

    // MARK: - Validation

    private var isEditing: Bool { trip != nil }
    private var fare: Double? { fareText.moneyValue }
    private var total: Double { (fare ?? 0) * Double(passengers) }

    private var isValid: Bool {
        !origin.trimmed.isEmpty
            && !destination.trimmed.isEmpty
            && (fare ?? 0) > 0
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VehiclePicker(selection: $vehicleType)
                        .listRowInsets(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                } header: {
                    Text("Vehicle")
                }

                Section {
                    if !routes.isEmpty {
                        savedRouteMenu
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "circle.circle.fill")
                            .foregroundStyle(Theme.brand)
                        TextField("Origin (e.g. Grand Terminal)", text: $origin)
                            .textInputAutocapitalization(.words)
                            .focused($focusedField, equals: .origin)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .destination }
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Theme.danger)
                        TextField("Destination", text: $destination)
                            .textInputAutocapitalization(.words)
                            .focused($focusedField, equals: .destination)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .fare }
                        Button {
                            withAnimation {
                                let previousOrigin = origin
                                origin = destination
                                destination = previousOrigin
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Theme.brand)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Swap origin and destination")
                    }
                } header: {
                    Text("Route")
                }

                Section {
                    HStack(spacing: 8) {
                        Text("₱")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $fareText)
                            .keyboardType(.decimalPad)
                            .font(.title3.weight(.semibold))
                            .monospacedDigit()
                            .focused($focusedField, equals: .fare)
                        Text("per person")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Stepper(value: $passengers, in: 1...20) {
                        Label("\(passengers) passenger\(passengers == 1 ? "" : "s")",
                              systemImage: "person.2.fill")
                    }

                    HStack {
                        Text("Total")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(total.peso)
                            .font(.headline)
                            .monospacedDigit()
                            .foregroundStyle(Theme.brand)
                            .contentTransition(.numericText())
                            .animation(.snappy, value: total)
                    }
                } header: {
                    Text("Fare")
                } footer: {
                    if !fareText.isEmpty && fare == nil {
                        Text("Enter a valid amount, e.g. 13 or 12.50")
                            .foregroundStyle(Theme.danger)
                    }
                }

                Section {
                    DatePicker("Date & Time", selection: $date, in: ...Date.now.addingTimeInterval(86_400 * 365))
                } header: {
                    Text("When")
                }

                Section {
                    TextField("Optional (e.g. student discount, traffic)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .notes)
                } header: {
                    Text("Notes")
                }

                if isEditing {
                    Section {
                        LabeledContent("Created", value: trip?.createdAt.formatted(date: .abbreviated, time: .shortened) ?? "")
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Trip" : "New Trip")
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
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var savedRouteMenu: some View {
        Menu {
            ForEach(routes) { route in
                Button {
                    apply(route)
                } label: {
                    Label("\(route.name) · \(route.defaultFare.pesoCompact)",
                          systemImage: route.vehicleType.symbol)
                }
            }
            if selectedRoute != nil {
                Divider()
                Button("Don't link to a route", role: .destructive) {
                    selectedRoute = nil
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(Theme.accent)
                Text(selectedRoute?.name ?? "Use a saved route")
                    .foregroundStyle(selectedRoute == nil ? Color.secondary : Color.primary)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Actions

    private func apply(_ route: SavedRoute) {
        withAnimation {
            selectedRoute = route
            origin = route.origin
            destination = route.destination
            fareText = route.defaultFare.editableString
            vehicleType = route.vehicleType
        }
    }

    /// CREATE or UPDATE the trip, then persist with `modelContext.save()`.
    private func save() {
        guard let fare, isValid else { return }

        if let trip {
            // UPDATE — modify the existing managed object's properties.
            trip.origin = origin.trimmed
            trip.destination = destination.trimmed
            trip.fare = fare
            trip.date = date
            trip.vehicleType = vehicleType
            trip.passengers = passengers
            trip.notes = notes.trimmed
            trip.route = selectedRoute
        } else {
            // CREATE — make a new Trip and insert it into the context.
            let newTrip = Trip(
                origin: origin.trimmed,
                destination: destination.trimmed,
                fare: fare,
                date: date,
                vehicleType: vehicleType,
                passengers: passengers,
                notes: notes.trimmed
            )
            modelContext.insert(newTrip)
            newTrip.route = selectedRoute
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save trip: \(error.localizedDescription)")
        }
        dismiss()
    }
}

#Preview("New Trip") {
    TripFormView()
        .modelContainer(PreviewData.container)
}
