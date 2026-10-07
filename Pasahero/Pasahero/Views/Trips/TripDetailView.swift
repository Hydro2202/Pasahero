//
//  TripDetailView.swift
//  Pasahero
//
//  READ (single record) with entry points to UPDATE and DELETE.
//

import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let trip: Trip

    @State private var showingEdit = false
    @State private var confirmingDelete = false
    @State private var isDeleting = false

    var body: some View {
        ScrollView {
            if !isDeleting {
                VStack(spacing: 16) {
                    heroCard
                    detailsCard
                    if !trip.notes.trimmed.isEmpty {
                        notesCard
                    }
                    actionButtons
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showingEdit = true }
                    .disabled(isDeleting)
            }
        }
        .sheet(isPresented: $showingEdit) {
            TripFormView(trip: trip)
        }
        .confirmationDialog("Delete this trip?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete Trip", role: .destructive) { deleteTrip() }
        } message: {
            Text("This record will be permanently removed from your fare log.")
        }
    }

    // MARK: - Sections

    private var heroCard: some View {
        let color = trip.vehicleType.color
        return VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label(trip.vehicleType.rawValue, systemImage: trip.vehicleType.symbol)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.2), in: Capsule())
                Spacer()
                Text(trip.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.subheadline.weight(.medium))
                    .opacity(0.9)
            }

            RouteTimeline(origin: trip.origin, destination: trip.destination,
                          tint: .white, foreground: .white)

            Divider().overlay(.white.opacity(0.4))

            HStack(alignment: .firstTextBaseline) {
                Text("Total fare")
                    .font(.subheadline.weight(.medium))
                    .opacity(0.9)
                Spacer()
                Text(trip.totalFare.peso)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .background(
            LinearGradient(colors: [color, color.opacity(0.75)],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(color: color.opacity(0.3), radius: 14, y: 8)
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            DetailRow(icon: "calendar", title: "Date",
                      value: trip.date.formatted(date: .complete, time: .omitted))
            Divider().padding(.leading, 44)
            DetailRow(icon: "clock", title: "Time",
                      value: trip.date.formatted(date: .omitted, time: .shortened))
            Divider().padding(.leading, 44)
            DetailRow(icon: "banknote", title: "Fare per passenger", value: trip.fare.peso)
            Divider().padding(.leading, 44)
            DetailRow(icon: "person.2", title: "Passengers", value: "\(trip.passengers)")
            Divider().padding(.leading, 44)
            DetailRow(icon: "bookmark", title: "Saved route", value: trip.route?.name ?? "None")
            Divider().padding(.leading, 44)
            DetailRow(icon: "square.and.pencil", title: "Logged",
                      value: trip.createdAt.formatted(date: .abbreviated, time: .shortened))
        }
        .card(padding: 4)
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Notes", systemImage: "note.text")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(trip.notes)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showingEdit = true
            } label: {
                Label("Edit Trip", systemImage: "pencil")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.brand)

            Button(role: .destructive) {
                confirmingDelete = true
            } label: {
                Label("Delete Trip", systemImage: "trash")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.bordered)
            .tint(Theme.danger)
        }
        .controlSize(.large)
        .padding(.top, 4)
    }

    // MARK: - Actions

    /// DELETE — hide the content, leave the screen, then remove the record.
    private func deleteTrip() {
        isDeleting = true
        let context = modelContext
        let record = trip
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            context.delete(record)
            try? context.save()
        }
    }
}

/// Icon + title + value row for detail screens.
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Theme.brand)
                .frame(width: 28)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 13)
    }
}

#Preview {
    NavigationStack {
        TripDetailView(trip: Trip(origin: "Lucena Grand Terminal", destination: "Enverga University",
                                  fare: 13, notes: "Student discount applied"))
    }
    .modelContainer(PreviewData.container)
}
