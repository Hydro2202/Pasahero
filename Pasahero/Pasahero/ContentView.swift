//
//  ContentView.swift
//  Pasahero
//
//  Root tab-based navigation of the app.
//

import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case home, trips, routes, budget
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(AppTab.home)

            TripListView()
                .tabItem { Label("Trips", systemImage: "list.bullet.rectangle.portrait.fill") }
                .tag(AppTab.trips)

            RouteListView()
                .tabItem { Label("Routes", systemImage: "point.topleft.down.curvedto.point.bottomright.up.fill") }
                .tag(AppTab.routes)

            BudgetView()
                .tabItem { Label("Budget", systemImage: "wallet.pass.fill") }
                .tag(AppTab.budget)
        }
        .tint(Theme.brand)
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
