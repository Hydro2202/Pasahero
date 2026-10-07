//
//  PasaheroApp.swift
//  Pasahero — Commute Fare Log
//
//  App entry point. Creates the SwiftData ModelContainer and injects it
//  into the SwiftUI environment so every view can access the ModelContext.
//

import SwiftUI
import SwiftData

@main
struct PasaheroApp: App {

    /// The ModelContainer manages the on-device persistent store (SQLite)
    /// for all three SwiftData models used by the app.
    let modelContainer: ModelContainer = {
        let schema = Schema([
            Trip.self,
            SavedRoute.self,
            Budget.self
        ])

        let configuration = ModelConfiguration(
            "Pasahero",
            schema: schema,
            isStoredInMemoryOnly: false   // persist data to disk
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Injects the container and its main ModelContext into the environment.
        .modelContainer(modelContainer)
    }
}
