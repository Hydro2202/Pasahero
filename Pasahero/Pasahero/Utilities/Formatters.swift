//
//  Formatters.swift
//  Pasahero
//
//  Formatting and date helpers.
//

import Foundation

extension Double {
    /// Formats the value as Philippine pesos, e.g. "₱1,250.00".
    var peso: String {
        "₱" + formatted(.number.precision(.fractionLength(2)))
    }

    /// Compact peso format without trailing decimals, e.g. "₱13" or "₱12.5".
    var pesoCompact: String {
        "₱" + formatted(.number.precision(.fractionLength(0...2)))
    }

    /// Value suitable for editing in a text field (no grouping separators).
    var editableString: String {
        if self == rounded() {
            return String(Int(self))
        }
        return String(format: "%.2f", self)
    }
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Parses user-typed money input such as "13", "12.50" or "12,50".
    var moneyValue: Double? {
        let cleaned = trimmed
            .replacingOccurrences(of: "₱", with: "")
            .replacingOccurrences(of: ",", with: ".")
        guard !cleaned.isEmpty else { return nil }
        return Double(cleaned)
    }
}

extension Date {
    var isInCurrentMonth: Bool {
        Calendar.current.isDate(self, equalTo: .now, toGranularity: .month)
    }

    var isInCurrentWeek: Bool {
        Calendar.current.isDate(self, equalTo: .now, toGranularity: .weekOfYear)
    }

    /// "Today", "Yesterday" or a medium date like "Oct 3, 2026".
    var relativeDayTitle: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) { return "Today" }
        if calendar.isDateInYesterday(self) { return "Yesterday" }
        return formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
    }
}
