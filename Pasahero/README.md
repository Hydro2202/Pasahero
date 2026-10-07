# Pasahero — Commute Fare Log

An iOS app built with **SwiftUI** and **SwiftData** that helps Filipino commuters
record and track what they spend on jeepney, tricycle, bus, UV Express and ferry rides.

## Requirements
- Xcode 15 or newer (Xcode 16+ recommended)
- iOS 17.0+ simulator or device (SwiftData requires iOS 17)

## How to run
1. Unzip and open `Pasahero.xcodeproj`.
2. Select the **Pasahero** target → *Signing & Capabilities* → choose your Team
   (only needed for a real iPhone; the Simulator works without it).
3. Pick an iPhone simulator (e.g. iPhone 15/16) and press **⌘R**.
4. Optional: go to **Budget → Tools → Load Sample Data** to fill the app with demo records.

## SwiftData models
| Model | Attributes | Purpose |
|---|---|---|
| `Trip` | origin, destination, fare, date, vehicleTypeRaw, passengers, notes, createdAt, route | One commute / fare paid |
| `SavedRoute` | name, origin, destination, defaultFare, vehicleTypeRaw, isFavorite, createdAt, trips | Reusable route for quick logging |
| `Budget` | label, monthlyLimit, warningThreshold, createdAt, updatedAt | Monthly fare budget |

`SavedRoute.trips` ↔ `Trip.route` is a one-to-many relationship (delete rule: `.nullify`).

## SwiftData components
| Component | Where |
|---|---|
| `@Model` | `Models/Trip.swift`, `Models/SavedRoute.swift`, `Models/Budget.swift` |
| `ModelContainer` | `PasaheroApp.swift` (`.modelContainer(...)`) |
| `ModelContext` | `@Environment(\.modelContext)` in the list and form views |
| `@Query` | `TripListView`, `RouteListView`, `DashboardView`, `BudgetView`, `TripFormView` |

## Where each CRUD operation happens
| Operation | Trip | SavedRoute | Budget |
|---|---|---|---|
| **Create** | `TripFormView.save()` → `modelContext.insert` | `RouteFormView.save()` | `BudgetFormView.save()` |
| **Read** | `TripListView` / `TripDetailView` (`@Query`) | `RouteListView` | `BudgetView` |
| **Update** | `TripFormView.save()` (edit mode) | `RouteFormView`, star toggle | `BudgetFormView` (edit mode) |
| **Delete** | Swipe left / Detail → Delete | Swipe left → Delete | Budget → Delete Budget |

## Screenshot checklist for the documentation
1. Home dashboard (with sample data)
2. **Create** — "New Trip" form filled in, then the new trip shown in the Trips list
3. **Read** — Trips list grouped by day + Trip Details screen
4. **Update** — "Edit Trip" form with a changed value, then the updated row
5. **Delete** — swipe-left Delete button / confirmation dialog, then the list without the record
6. Saved Routes list and Budget screen
7. Close and reopen the app to show the data persisted

## Project structure
```
Pasahero/
├── PasaheroApp.swift          ModelContainer setup
├── ContentView.swift          Tab navigation
├── Models/                    @Model classes + VehicleType enum
├── Views/
│   ├── Dashboard/             Home screen + chart
│   ├── Trips/                 List, detail, add/edit form
│   ├── Routes/                Saved routes CRUD
│   └── Budget/                Budget CRUD + data tools
├── Components/                Theme and reusable UI
└── Utilities/                 Formatters, sample data
```
