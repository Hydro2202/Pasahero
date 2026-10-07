//
//  Budget.swift
//  Pasahero
//
//  SwiftData model for the commuter's monthly fare budget.
//

import Foundation
import SwiftData

@Model
final class Budget {
    /// Name shown in the UI, e.g. "Commute Budget".
    var label: String

    /// Maximum amount the user plans to spend on fares per month.
    var monthlyLimit: Double

    /// Fraction of the limit (0.5 – 1.0) at which the app warns the user.
    var warningThreshold: Double

    /// When the budget was first created.
    var createdAt: Date

    /// When the budget was last edited.
    var updatedAt: Date

    init(label: String = "Commute Budget", monthlyLimit: Double, warningThreshold: Double = 0.8) {
        self.label = label
        self.monthlyLimit = monthlyLimit
        self.warningThreshold = warningThreshold
        self.createdAt = .now
        self.updatedAt = .now
    }

    // MARK: - Helpers (not persisted)

    func progress(for spent: Double) -> Double {
        guard monthlyLimit > 0 else { return 0 }
        return spent / monthlyLimit
    }

    func status(for spent: Double) -> BudgetStatus {
        let value = progress(for: spent)
        if value >= 1 { return .over }
        if value >= warningThreshold { return .warning }
        return .onTrack
    }
}

enum BudgetStatus {
    case onTrack, warning, over

    var title: String {
        switch self {
        case .onTrack: return "On track"
        case .warning: return "Near limit"
        case .over:    return "Over budget"
        }
    }

    var symbol: String {
        switch self {
        case .onTrack: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .over:    return "xmark.octagon.fill"
        }
    }
}
