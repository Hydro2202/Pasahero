//
//  RouteListView.swift
//  Pasahero
//
//  Full CRUD for SavedRoute records: list (Read), add (Create),
//  edit / favorite toggle (Update) and swipe-to-delete (Delete).
//

import SwiftUI
import SwiftData

struct RouteListView: View {
    @Environment(\.modelContext) private var modelContext

    /// READ — all saved routes, alphabetically.
    @Query(sort: \SavedRoute.name) private var routes: [SavedRoute]

    @State private var showingAddRoute = false
    @State private var routeToEdit: SavedRoute?
    @State private var routeToLog: SavedRoute?
    @State private var routeToDelete: SavedRoute?

    private var favorites: [SavedRoute] { routes.filter(\.isFavorite) }
    private var others: [SavedRoute] { routes.filter { !$0.isFavorite } }

    var body: some View {
        NavigationStack {
            Group {
                if routes.isEmpty {
                    ContentUnavailableView {
                        Label("No saved routes", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                    } description: {
                        Text("Save the routes you ride often so you can log a trip in one tap.")
                    } actions: {
                        Button {
                            showingAddRoute = true
                        } label: {
                            Label("Add Route", systemImage: "plus")
                                .padding(.horizontal, 8)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        if !favorites.isEmpty {
                            Section("Favorites") {
                                ForEach(favorites) { route in
                                    row(for: route)
                                }
                            }
                        }
                        if !others.isEmpty {
                            Section(favorites.isEmpty ? "All Routes" : "Other Routes") {
                                ForEach(others) { route in
                                    row(for: route)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .animation(.default, value: favorites.count)
                }
            }
            .navigationTitle("Saved Routes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddRoute = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("Add Route")
                }
            }
            .sheet(isPresented: $showingAddRoute) {
                RouteFormView()
            }
            .sheet(item: $routeToEdit) { route in
                RouteFormView(route: route)
            }
            .sheet(item: $routeToLog) { route in
                TripFormView(prefillRoute: route)
            }
            .confirmationDialog(
                "Delete this route?",
                isPresented: Binding(
                    get: { routeToDelete != nil },
                    set: { if !$0 { routeToDelete = nil } }
                ),
                titleVisibility: .visible,
                presenting: routeToDelete
            ) { route in
                Button("Delete Route", role: .destructive) {
                    delete(route)
                }
            } message: { route in
                Text("\"\(route.name)\" will be removed. Its \(route.trips.count) logged trip(s) will be kept.")
            }
        }
    }

    private func row(for route: SavedRoute) -> some View {
        RouteRowView(
            route: route,
            onLogTrip: { routeToLog = route },
            onToggleFavorite: { toggleFavorite(route) }
        )
        .contentShape(Rectangle())
        .onTapGesture { routeToEdit = route }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                routeToDelete = route
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                routeToEdit = route
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(Theme.brand)
        }
        .swipeActions(edge: .leading) {
            Button {
                toggleFavorite(route)
            } label: {
                Label(route.isFavorite ? "Unfavorite" : "Favorite",
                      systemImage: route.isFavorite ? "star.slash" : "star.fill")
            }
            .tint(Theme.accent)
        }
    }

    // MARK: - Actions

    /// UPDATE — flip a single attribute and save.
    private func toggleFavorite(_ route: SavedRoute) {
        withAnimation {
            route.isFavorite.toggle()
            try? modelContext.save()
        }
    }

    /// DELETE — remove the route; related trips are kept (nullify rule).
    private func delete(_ route: SavedRoute) {
        withAnimation {
            modelContext.delete(route)
            try? modelContext.save()
        }
        routeToDelete = nil
    }
}

#Preview {
    RouteListView()
        .modelContainer(PreviewData.container)
}
