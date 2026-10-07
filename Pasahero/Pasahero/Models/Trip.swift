//
//  Trip.swift
//  Pasahero
//
//  SwiftData model for a single commute (one fare paid).
//

import Foundation
import SwiftData

@Model
final class Trip {
    /// Where the ride started (e.g. "Lucena Grand Terminal").
    var origin: String

    /// Where the ride ended (e.g. "Enverga University").
    var destination: String

    /// Fare paid per passenger, in Philippine pesos.
    var fare: Double

    /// Date and time of the ride.
    var date: Date

    /// Raw value of `VehicleType`, stored as a String so it can be
    /// sorted and filtered reliably by SwiftData.
    var vehicleTypeRaw: String

    /// Number of passengers paid for (default is 1).
    var passengers: Int

    /// Optional notes such as "student discount" or "heavy traffic".
    var notes: String

    /// When the record was first saved.
    var createdAt: Date

    /// Optional link to the saved route this trip was logged from.
    /// The inverse is `SavedRoute.trips`.
    var route: SavedRoute?

    init(
        origin: String,
        destination: String,
        fare: Double,
        date: Date = .now,
        vehicleType: VehicleType = .jeepney,
        passengers: Int = 1,
        notes: String = ""
    ) {
        self.origin = origin
        self.destination = destination
        self.fare = fare
        self.date = date
        self.vehicleTypeRaw = vehicleType.rawValue
        self.passengers = passengers
        self.notes = notes
        self.createdAt = .now
    }

    // MARK: - Computed (not persisted)

    /// Type-safe access to the stored vehicle type.
    var vehicleType: VehicleType {
        get { VehicleType(rawValue: vehicleTypeRaw) ?? .jeepney }
        set { vehicleTypeRaw = newValue.rawValue }
    }

    /// Total amount paid for this trip (fare × passengers).
    var totalFare: Double {
        fare * Double(passengers)
    }
}
