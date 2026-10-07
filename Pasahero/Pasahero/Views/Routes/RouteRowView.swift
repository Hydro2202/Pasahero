//
//  RouteRowView.swift
//  Pasahero
//
//  Card-style row for a saved route.
//

import SwiftUI

struct RouteRowView: View {
    let route: SavedRoute
    var onLogTrip: () -> Void
    var onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VehicleIcon(type: route.vehicleType, size: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text(route.name)
                        .font(.headline)
                    HStack(spacing: 6) {
                        Text(route.origin).lineLimit(1)
                        Image(systemName: "arrow.right")
                            .font(.caption2.weight(.bold))
                        Text(route.destination).lineLimit(1)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 4)

                Button(action: onToggleFavorite) {
                    Image(systemName: route.isFavorite ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(route.isFavorite ? Theme.accent : Color.secondary)
                        .symbolEffect(.bounce, value: route.isFavorite)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(route.isFavorite ? "Remove from favorites" : "Add to favorites")
            }

            HStack(spacing: 14) {
                Label(route.defaultFare.pesoCompact, systemImage: "banknote")
                Label("\(route.trips.count) trips", systemImage: "clock.arrow.circlepath")
                Spacer(minLength: 4)
                Button(action: onLogTrip) {
                    Label("Log Trip", systemImage: "plus")
                        .font(.caption.weight(.bold))
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.small)
                .tint(route.vehicleType.color)
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}
