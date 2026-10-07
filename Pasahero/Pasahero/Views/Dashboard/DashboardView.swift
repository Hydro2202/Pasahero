//
//  DashboardView.swift
//  Pasahero
//
//  Home screen: monthly spending overview, budget progress, quick-log
//  favorite routes, vehicle breakdown chart and recent trips.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Binding var selectedTab: AppTab

    @Query(sort: \Trip.date, order: .reverse) private var trips: [Trip]
    @Query(sort: \SavedRoute.name) private var routes: [SavedRoute]
    @Query(sort: \Budget.createdAt) private var budgets: [Budget]

    @State private var showingAddTrip = false
    @State private var routeToLog: SavedRoute?

    // MARK: - Derived data

    private var budget: Budget? { budgets.first }
    private var monthTrips: [Trip] { trips.filter { $0.date.isInCurrentMonth } }
    private var monthSpent: Double { monthTrips.reduce(0) { $0 + $1.totalFare } }

    private var weekSpent: Double {
        trips.filter { $0.date.isInCurrentWeek }.reduce(0) { $0 + $1.totalFare }
    }

    private var averageFare: Double {
        guard !monthTrips.isEmpty else { return 0 }
        return monthSpent / Double(monthTrips.count)
    }

    private var favoriteRoutes: [SavedRoute] { routes.filter(\.isFavorite) }

    private var vehicleBreakdown: [VehicleSpend] {
        VehicleType.allCases.compactMap { type in
            let matching = monthTrips.filter { $0.vehicleType == type }
            guard !matching.isEmpty else { return nil }
            return VehicleSpend(
                type: type,
                amount: matching.reduce(0) { $0 + $1.totalFare },
                count: matching.count
            )
        }
        .sorted { $0.amount > $1.amount }
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12:  return "Magandang umaga! ☀️"
        case 12..<18: return "Magandang hapon! 🌤️"
        default:      return "Magandang gabi! 🌙"
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    heroCard
                    statsRow

                    if !favoriteRoutes.isEmpty {
                        quickLogSection
                    }

                    if !vehicleBreakdown.isEmpty {
                        breakdownCard
                    }

                    recentTripsCard
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Pasahero")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTrip = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("Log a Trip")
                }
            }
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
            }
            .sheet(isPresented: $showingAddTrip) {
                TripFormView()
            }
            .sheet(item: $routeToLog) { route in
                TripFormView(prefillRoute: route)
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(greeting)
                .font(.title3.weight(.semibold))
            Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Spent this \(Date.now.formatted(.dateTime.month(.wide)))")
                    .font(.subheadline.weight(.medium))
                    .opacity(0.85)
                Spacer()
                Image(systemName: "bus.fill")
                    .font(.title3)
                    .opacity(0.9)
            }

            Text(monthSpent.peso)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.snappy, value: monthSpent)

            if let budget {
                let progress = budget.progress(for: monthSpent)
                let status = budget.status(for: monthSpent)
                let remaining = budget.monthlyLimit - monthSpent

                CapsuleProgressBar(
                    progress: progress,
                    tint: status == .onTrack ? .white : status.color,
                    track: .white.opacity(0.25)
                )

                HStack {
                    Text(remaining >= 0
                         ? "\(remaining.peso) left of \(budget.monthlyLimit.pesoCompact)"
                         : "\((-remaining).peso) over budget")
                    Spacer()
                    Label(status.title, systemImage: status.symbol)
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2), in: Capsule())
                }
                .font(.footnote.weight(.medium))
            } else {
                Button {
                    selectedTab = .budget
                } label: {
                    Label("Set a monthly budget", systemImage: "plus.circle")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.2), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.heroGradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 140, height: 140)
                .offset(x: 40, y: -50)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.brand.opacity(0.35), radius: 16, y: 8)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatTile(title: "This week", value: weekSpent.pesoCompact,
                     symbol: "calendar", tint: Theme.brand)
            StatTile(title: "Trips this month", value: "\(monthTrips.count)",
                     symbol: "figure.walk", tint: Color(hex: 0x16A34A))
            StatTile(title: "Avg. per trip", value: averageFare.pesoCompact,
                     symbol: "chart.bar.fill", tint: Theme.accent)
        }
    }

    private var quickLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Quick Log", actionTitle: "Routes") {
                selectedTab = .routes
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(favoriteRoutes) { route in
                        Button {
                            routeToLog = route
                        } label: {
                            QuickRouteCard(route: route)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Spending by Vehicle")

            HStack(spacing: 20) {
                Chart(vehicleBreakdown) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.62),
                        angularInset: 2
                    )
                    .cornerRadius(5)
                    .foregroundStyle(item.type.color)
                }
                .frame(width: 140, height: 140)
                .overlay {
                    VStack(spacing: 0) {
                        Text("Total")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(monthSpent.pesoCompact)
                            .font(.subheadline.weight(.bold))
                            .monospacedDigit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }
                    .frame(width: 80)
                }

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(vehicleBreakdown) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.type.color)
                                .frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(item.type.rawValue)
                                    .font(.caption.weight(.semibold))
                                Text("\(item.count) trip\(item.count == 1 ? "" : "s")")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 4)
                            Text(item.amount.pesoCompact)
                                .font(.caption.weight(.semibold))
                                .monospacedDigit()
                        }
                    }
                }
            }
            .card()
        }
    }

    private var recentTripsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recent Trips", actionTitle: trips.isEmpty ? nil : "See All") {
                selectedTab = .trips
            }

            if trips.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bus")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.brand)
                    Text("No trips logged yet")
                        .font(.headline)
                    Text("Tap the button below to record your first fare.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button {
                        showingAddTrip = true
                    } label: {
                        Label("Log a Trip", systemImage: "plus")
                            .padding(.horizontal, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.brand)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .card()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(trips.prefix(5))) { trip in
                        NavigationLink(value: trip) {
                            TripRowView(trip: trip, showsDate: true)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)

                        if trip.id != trips.prefix(5).last?.id {
                            Divider().padding(.leading, 72)
                        }
                    }
                }
                .padding(.vertical, 6)
                .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                )
            }
        }
    }
}

// MARK: - Supporting views & types

struct VehicleSpend: Identifiable {
    let type: VehicleType
    let amount: Double
    let count: Int
    var id: VehicleType { type }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: () -> Void = {}

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.bold))
            Spacer()
            if let actionTitle {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

struct QuickRouteCard: View {
    let route: SavedRoute

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VehicleIcon(type: route.vehicleType, size: 36)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(route.vehicleType.color)
            }
            Text(route.name)
                .font(.subheadline.weight(.bold))
                .lineLimit(1)
            Text("\(route.origin) → \(route.destination)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2, reservesSpace: true)
            Text(route.defaultFare.peso)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(route.vehicleType.color)
        }
        .frame(width: 160, alignment: .leading)
        .card(padding: 14)
    }
}

#Preview {
    DashboardView(selectedTab: .constant(.home))
        .modelContainer(PreviewData.container)
}
