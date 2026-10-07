//
//  SampleData.swift
//  Pasahero
//
//  Demo records for screenshots, testing and SwiftUI previews.
//

import Foundation
import SwiftData

enum SampleData {

    /// Inserts sample routes, trips and (optionally) a budget into the context.
    static func insert(into context: ModelContext, includeBudget: Bool = true) {
        let calendar = Calendar.current
        let now = Date.now

        // MARK: Saved routes
        let homeToSchool = SavedRoute(
            name: "Home to School",
            origin: "Lucena Grand Terminal",
            destination: "Enverga University",
            defaultFare: 13,
            vehicleType: .jeepney,
            isFavorite: true
        )
        let mallRun = SavedRoute(
            name: "Mall Run",
            origin: "Enverga University",
            destination: "SM City Lucena",
            defaultFare: 15,
            vehicleType: .jeepney,
            isFavorite: true
        )
        let terminalTrike = SavedRoute(
            name: "Terminal Tricycle",
            origin: "Diversion Road",
            destination: "Lucena Grand Terminal",
            defaultFare: 20,
            vehicleType: .tricycle,
            isFavorite: true
        )
        let weekendTrip = SavedRoute(
            name: "Weekend to Tayabas",
            origin: "Lucena Grand Terminal",
            destination: "Tayabas City",
            defaultFare: 35,
            vehicleType: .uvExpress
        )

        let routes = [homeToSchool, mallRun, terminalTrike, weekendTrip]
        routes.forEach { context.insert($0) }

        // MARK: Trips
        func at(_ day: Date, _ hour: Int, _ minute: Int = 0) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }

        func addTrip(
            _ origin: String, _ destination: String, fare: Double, date: Date,
            vehicle: VehicleType, passengers: Int = 1, notes: String = "",
            route: SavedRoute? = nil
        ) {
            guard date <= now else { return }   // never create future trips
            let trip = Trip(
                origin: origin, destination: destination, fare: fare, date: date,
                vehicleType: vehicle, passengers: passengers, notes: notes
            )
            context.insert(trip)
            trip.route = route   // set relationships after inserting
        }

        for offset in 0..<20 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: now) else { continue }
            let weekday = calendar.component(.weekday, from: day)
            let isWeekend = (weekday == 1 || weekday == 7)

            if isWeekend {
                if offset % 2 == 0 {
                    addTrip(weekendTrip.origin, weekendTrip.destination, fare: 35,
                            date: at(day, 9, 30), vehicle: .uvExpress,
                            notes: "Visit family", route: weekendTrip)
                } else {
                    addTrip(mallRun.origin, mallRun.destination, fare: 15,
                            date: at(day, 14, 10), vehicle: .jeepney, passengers: 2,
                            notes: "With a friend", route: mallRun)
                }
            } else {
                if offset % 3 == 0 {
                    addTrip(terminalTrike.origin, terminalTrike.destination, fare: 20,
                            date: at(day, 6, 35), vehicle: .tricycle, route: terminalTrike)
                }
                addTrip(homeToSchool.origin, homeToSchool.destination, fare: 13,
                        date: at(day, 7, 5), vehicle: .jeepney,
                        notes: offset % 4 == 0 ? "Student discount" : "", route: homeToSchool)
                addTrip("Enverga University", "Lucena Grand Terminal", fare: 13,
                        date: at(day, 17, 20), vehicle: .jeepney,
                        notes: offset % 5 == 0 ? "Heavy traffic at Quezon Ave." : "")
                if offset % 6 == 1 {
                    addTrip("Lucena Grand Terminal", "Pagbilao", fare: 28,
                            date: at(day, 18, 45), vehicle: .bus)
                }
            }
        }

        // MARK: Budget
        if includeBudget {
            context.insert(Budget(label: "Commute Budget", monthlyLimit: 1500, warningThreshold: 0.8))
        }

        try? context.save()
    }
}

/// In-memory container used only by SwiftUI previews.
@MainActor
enum PreviewData {
    static let container: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: Trip.self, SavedRoute.self, Budget.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            SampleData.insert(into: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
}
