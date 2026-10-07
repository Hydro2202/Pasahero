# 🚌 Pasahero — Commute Fare Log

An iOS app built with **SwiftUI** and **SwiftData** that helps Filipino commuters record and track their daily fare expenses for jeepney, tricycle, bus, UV Express, and ferry rides.

This project demonstrates **persistent data storage** and the four basic data operations: **Create, Read, Update, and Delete (CRUD)**.

---

## ✨ Features

- **Log trips** with origin, destination, fare, vehicle type, passengers, date, and notes
- **Trips list** grouped by day, with daily totals, search, and a vehicle filter
- **Trip details** screen with edit and delete actions
- **Saved routes** for one-tap trip logging, with favorites shown on the Home screen
- **Monthly budget** with a progress bar and "On track / Near limit / Over budget" status
- **Dashboard** with monthly spending, weekly stats, and a spending-by-vehicle chart
- **Sample data** loader for quick testing
- All data is **saved on the device** and persists after the app is closed

---

## 🛠 Tech Stack

| Technology | Purpose |
|---|---|
| Swift 5 | Programming language |
| SwiftUI | User interface |
| SwiftData | Persistent data storage |
| Swift Charts | Spending-by-vehicle donut chart |
| Xcode 15+ | Development environment |
| iOS 17.0+ | Minimum deployment target |

---

## 🗂 SwiftData Models

### `Trip`
A single commute or ride.

| Attribute | Type | Description |
|---|---|---|
| `origin` | String | Starting point of the ride |
| `destination` | String | End point of the ride |
| `fare` | Double | Fare per passenger (₱) |
| `date` | Date | Date and time of the ride |
| `vehicleTypeRaw` | String | Jeepney, Tricycle, Bus, UV Express, or Ferry |
| `passengers` | Int | Number of passengers paid for |
| `notes` | String | Optional remarks |
| `createdAt` | Date | When the record was saved |
| `route` | SavedRoute? | Optional link to a saved route |

### `SavedRoute`
A frequently used route for quick logging.

| Attribute | Type | Description |
|---|---|---|
| `name` | String | Route name (e.g., Home to School) |
| `origin` | String | Starting point |
| `destination` | String | End point |
| `defaultFare` | Double | Usual fare |
| `vehicleTypeRaw` | String | Usual vehicle |
| `isFavorite` | Bool | Shown on the Home screen if true |
| `createdAt` | Date | When the route was created |
| `trips` | [Trip] | Trips logged from this route |

### `Budget`
The user's monthly fare budget.

| Attribute | Type | Description |
|---|---|---|
| `label` | String | Budget name |
| `monthlyLimit` | Double | Monthly spending limit (₱) |
| `warningThreshold` | Double | Percentage at which the app warns the user |
| `createdAt` | Date | When the budget was created |
| `updatedAt` | Date | When the budget was last edited |

**Relationship:** One `SavedRoute` → many `Trip` records (delete rule: `.nullify`, so deleting a route keeps its trips).

---

## 💾 How SwiftData Is Used

| Component | Where | What it does |
|---|---|---|
| `@Model` | `Models/` | Turns `Trip`, `SavedRoute`, and `Budget` into persistent models |
| `ModelContainer` | `PasaheroApp.swift` | Creates the on-device database and injects it with `.modelContainer()` |
| `ModelContext` | `@Environment(\.modelContext)` | Inserts, deletes, and saves records |
| `@Query` | List and dashboard views | Fetches records and keeps the UI updated automatically |

### CRUD Operations

| Operation | How it works |
|---|---|
| **Create** | `modelContext.insert(newTrip)` then `try modelContext.save()` |
| **Read** | `@Query(sort: \Trip.date, order: .reverse) var trips: [Trip]` |
| **Update** | Change the object's properties (e.g., `trip.fare = 20`) then save |
| **Delete** | `modelContext.delete(trip)` then save |

---

## 📁 Project Structure

```
Pasahero/
├── PasaheroApp.swift          # App entry point + ModelContainer
├── ContentView.swift          # Tab navigation
├── Models/
│   ├── Trip.swift
│   ├── SavedRoute.swift
│   ├── Budget.swift
│   └── VehicleType.swift
├── Views/
│   ├── Dashboard/             # Home screen and chart
│   ├── Trips/                 # List, detail, add/edit form
│   ├── Routes/                # Saved routes CRUD
│   └── Budget/                # Budget CRUD and data tools
├── Components/                # Theme and reusable UI
└── Utilities/                 # Formatters and sample data
```

---

## 🚀 Getting Started

1. Clone the repository:
```bash
   git clone https://github.com/<your-username>/Pasahero.git
```
2. Open `Pasahero.xcodeproj` in Xcode 15 or newer.
3. Select an iPhone simulator running **iOS 17 or later**.
4. Press **⌘R** to build and run.
5. *(Optional)* Go to **Budget → Load Sample Data** to fill the app with demo records.

> To run on a real iPhone, select your Apple ID team under **Signing & Capabilities**.

---

## 👤 Author

**Raiden Villapando**
BS Information Technology — Manuel S. Enverga University Foundation, Lucena City

---

## 📄 License

This project was created for educational purposes.
