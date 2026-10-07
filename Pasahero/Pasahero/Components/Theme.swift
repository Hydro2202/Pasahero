//
//  Theme.swift
//  Pasahero
//
//  Central place for colors, gradients and reusable view styling.
//

import SwiftUI

enum Theme {
    static let brand      = Color(hex: 0x2563EB)   // vivid blue
    static let brandDeep  = Color(hex: 0x1E3A8A)   // navy
    static let brandViolet = Color(hex: 0x7C3AED)  // violet
    static let accent     = Color(hex: 0xF59E0B)   // jeepney amber

    static let success = Color(hex: 0x16A34A)
    static let warning = Color(hex: 0xF59E0B)
    static let danger  = Color(hex: 0xDC2626)

    static let heroGradient = LinearGradient(
        colors: [brandDeep, brand, brandViolet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardRadius: CGFloat = 20
}

extension Color {
    /// Creates a color from a hex value like `0x2563EB`.
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

extension VehicleType {
    /// Signature color of each vehicle type.
    var color: Color {
        switch self {
        case .jeepney:   return Color(hex: 0xEA580C)  // orange
        case .tricycle:  return Color(hex: 0x16A34A)  // green
        case .bus:       return Color(hex: 0x2563EB)  // blue
        case .uvExpress: return Color(hex: 0x9333EA)  // purple
        case .ferry:     return Color(hex: 0x0891B2)  // teal
        }
    }
}

extension BudgetStatus {
    var color: Color {
        switch self {
        case .onTrack: return Theme.success
        case .warning: return Theme.warning
        case .over:    return Theme.danger
        }
    }
}

// MARK: - Card style

struct CardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
            )
    }
}

extension View {
    /// Wraps the view in a rounded, grouped-background card.
    func card(padding: CGFloat = 16) -> some View {
        modifier(CardModifier(padding: padding))
    }
}
