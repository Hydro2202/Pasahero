//
//  TripListView.swift
//  Pasahero
//
//  READ + DELETE: Lists all saved trips (via @Query), grouped by day,
//  with search, vehicle filter, swipe-to-edit and swipe-to-delete.
//

import SwiftUI
import SwiftData

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext

    /// READ — SwiftData fetches every Trip, newest first, and keeps
    /// the list automatically updated when records change.
    @Query(sort: \Trip.date, order: .reverse) private var trips: [Trip]

    @State private var searchText = ""
    @State private var vehicleFilter: VehicleType?
    @State private var showingAddTrip = false
    @State private var tripToEdit: Trip?
    @State private var tripToDelete: Trip?

    // MARK: - Derived data

    private var filteredTrips: [Trip] {
        trips.filter { trip in
            let matchesVehicle = vehicleFilter == nil || trip.vehicleType == vehicleFilter
            let matchesSearch = searchText.trimmed.isEmpty
                || trip.origin.localizedCaseInsensitiveContains(searchText)
                || trip.destination.localizedCaseInsensitiveContains(searchText)
                || trip.notes.localizedCaseInsensitiveContains(searchText)
            return matchesVehicle && matchesSearch
        }
    }

    private var daySections: [DaySection] {
        let grouped = Dictionary(grouping: filteredTrips) { trip in
            Calendar.current.startOfDay(for: trip.date)
        }
        return grouped.keys
            .sorted(by: >)
            .map { DaySection(day: $0, trips: grouped[$0] ?? []) }
    }

    private var filteredTotal: Double {
        filteredTrips.reduce(0) { $0 + $1.totalFare }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if trips.isEmpty {
                    emptyState
                } else {
                    tripList
                }
            }
            .navigationTitle("Trips")
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingAddTrip) {
                TripFormView()
            }
            .sheet(item: $tripToEdit) { trip in
                TripFormView(trip: trip)
            }
            .confirmationDialog(
                "Delete this trip?",
                isPresented: Binding(
                    get: { tripToDelete != nil },
                    set: { if !$0 { tripToDelete = nil } }
                ),
                titleVisibility: .visible,
                presenting: tripToDelete
            ) { trip in
                Button("Delete Trip", role: .destructive) {
                    delete(trip)
                }
            } message: { trip in
                Text("\(trip.origin) → \(trip.destination) (\(trip.totalFare.peso)) will be permanently removed.")
            }
        }
    }

    // MARK: - Subviews

    private var tripList: some View {
        List {
            Section {
                summaryHeader
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            if daySections.isEmpty {
                ContentUnavailableView.search(text: searchText)
                    .listRowBackground(Color.clear)
            }

            ForEach(daySections) { section in
                Section {
                    ForEach(section.trips) { trip in
                        NavigationLink(value: trip) {
                            TripRowView(trip: trip)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                tripToDelete = trip
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                tripToEdit = trip
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(Theme.brand)
                        }
                        .contextMenu {
                            Button {
                                tripToEdit = trip
                            } label: {
                                Label("Edit Trip", systemImage: "pencil")
                            }
                            Button {
                                duplicate(trip)
                            } label: {
                                Label("Log Again Now", systemImage: "arrow.clockwise")
                            }
                            Divider()
                            Button(role: .destructive) {
                                tripToDelete = trip
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text(section.day.relativeDayTitle)
                        Spacer()
                        Text(section.total.peso)
                            .monospacedDigit()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Search places or notes")
        .animation(.default, value: filteredTrips.count)
    }

    private var summaryHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vehicleFilter == nil ? "All trips" : "\(vehicleFilter!.rawValue) trips")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(filteredTotal.peso)
                    .font(.title2.weight(.bold))
                    .monospacedDigit()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Records")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(filteredTrips.count)")
                    .font(.title2.weight(.bold))
                    .monospacedDigit()
            }
        }
        .card()
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No trips yet", systemImage: "bus")
        } description: {
            Text("Log your first commute to start tracking your fare expenses.")
        } actions: {
            Button {
                showingAddTrip = true
            } label: {
                Label("Log a Trip", systemImage: "plus")
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Picker("Vehicle", selection: $vehicleFilter) {
                    Label("All Vehicles", systemImage: "square.grid.2x2")
                        .tag(VehicleType?.none)
                    ForEach(VehicleType.allCases) { type in
                        Label(type.rawValue, systemImage: type.symbol)
                            .tag(VehicleType?.some(type))
                    }
                }
            } label: {
                Image(systemName: vehicleFilter == nil
                      ? "line.3.horizontal.decrease.circle"
                      : "line.3.horizontal.decrease.circle.fill")
            }
            .disabled(trips.isEmpty)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingAddTrip = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }
            .accessibilityLabel("Add Trip")
        }
    }

    // MARK: - Actions

    /// DELETE — removes the trip from the ModelContext and saves.
    private func delete(_ trip: Trip) {
        withAnimation {
            modelContext.delete(trip)
            try? modelContext.save()
        }
        tripToDelete = nil
    }

    /// CREATE — inserts a copy of an existing trip dated now.
    private func duplicate(_ trip: Trip) {
        let copy = Trip(
            origin: trip.origin,
            destination: trip.destination,
            fare: trip.fare,
            date: .now,
            vehicleType: trip.vehicleType,
            passengers: trip.passengers,
            notes: trip.notes
        )
        modelContext.insert(copy)
        copy.route = trip.route
        try? modelContext.save()
    }
}

/// Trips that happened on the same calendar day.
struct DaySection: Identifiable {
    let day: Date
    let trips: [Trip]

    var id: Date { day }
    var total: Double { trips.reduce(0) { $0 + $1.totalFare } }
}

#Preview {
    TripListView()
        .modelContainer(PreviewData.container)
}
