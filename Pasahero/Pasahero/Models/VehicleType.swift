//
//  VehicleType.swift
//  Pasahero
//
//  The kinds of public transport a commuter can ride.
//  Stored in SwiftData as its String raw value.
//

import Foundation

enum VehicleType: String, CaseIterable, Identifiable, Codable {
    case jeepney   = "Jeepney"
    case tricycle  = "Tricycle"
    case bus       = "Bus"
    case uvExpress = "UV Express"
    case ferry     = "Ferry"

    var id: String { rawValue }

    /// SF Symbol used to represent the vehicle in the UI.
    var symbol: String {
        switch self {
        case .jeepney:   return "bus.fill"
        case .tricycle:  return "scooter"
        case .bus:       return "bus.doubledecker.fill"
        case .uvExpress: return "car.side.fill"
        case .ferry:     return "ferry.fill"
        }
    }
}
