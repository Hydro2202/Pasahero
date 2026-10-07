//
//  TripRowView.swift
//  Pasahero
//
//  A single trip row used in lists.
//

import SwiftUI

struct TripRowView: View {
    let trip: Trip
    var showsDate = false

    var body: some View {
        HStack(spacing: 14) {
            VehicleIcon(type: trip.vehicleType)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(trip.origin)
                        .lineLimit(1)
                    Image(systemName: "arrow.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(trip.destination)
                        .lineLimit(1)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Text(trip.vehicleType.rawValue)
                    Text("•")
                    if showsDate {
                        Text(trip.date, format: .dateTime.month(.abbreviated).day())
                        Text("•")
                    }
                    Text(trip.date, format: .dateTime.hour().minute())
                    if trip.passengers > 1 {
                        Text("•")
                        Image(systemName: "person.2.fill")
                        Text("\(trip.passengers)")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text(trip.totalFare.peso)
                .font(.callout.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    List {
        TripRowView(trip: Trip(origin: "Lucena Grand Terminal", destination: "Enverga University", fare: 13))
        TripRowView(trip: Trip(origin: "Diversion Road", destination: "SM City Lucena", fare: 20,
                               vehicleType: .tricycle, passengers: 2), showsDate: true)
    }
    .modelContainer(PreviewData.container)
}
