//
//  SavedRoute.swift
//  Pasahero
//
//  SwiftData model for a frequently used route that can be reused
//  to log trips quickly (e.g. "Home to School").
//

import Foundation
import SwiftData

@Model
final class SavedRoute {
    /// Friendly name of the route, e.g. "Home to School".
    var name: String

    /// Starting point of the route.
    var origin: String

    /// End point of the route.
    var destination: String

    /// Usual fare for this route, used to pre-fill new trips.
    var defaultFare: Double

    /// Raw value of `VehicleType` usually taken on this route.
    var vehicleTypeRaw: String

    /// Pinned routes appear on the Home dashboard for quick logging.
    var isFavorite: Bool

    /// When the route was created.
    var createdAt: Date

    /// All trips logged from this route.
    /// Deleting a route keeps its trips but clears their link (nullify).
    @Relationship(deleteRule: .nullify, inverse: \Trip.route)
    var trips: [Trip]

    init(
        name: String,
        origin: String,
        destination: String,
        defaultFare: Double,
        vehicleType: VehicleType = .jeepney,
        isFavorite: Bool = false
    ) {
        self.name = name
        self.origin = origin
        self.destination = destination
        self.defaultFare = defaultFare
        self.vehicleTypeRaw = vehicleType.rawValue
        self.isFavorite = isFavorite
        self.createdAt = .now
        self.trips = []
    }

    // MARK: - Computed (not persisted)

    var vehicleType: VehicleType {
        get { VehicleType(rawValue: vehicleTypeRaw) ?? .jeepney }
        set { vehicleTypeRaw = newValue.rawValue }
    }

    /// Total amount spent on all trips logged from this route.
    var totalSpent: Double {
        trips.reduce(0) { $0 + $1.totalFare }
    }
}
