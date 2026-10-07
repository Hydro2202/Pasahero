//
//  SharedViews.swift
//  Pasahero
//
//  Small reusable UI components used across screens.
//

import SwiftUI

/// Rounded square icon tinted with the vehicle's color.
struct VehicleIcon: View {
    let type: VehicleType
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: type.symbol)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(type.color)
            .frame(width: size, height: size)
            .background(
                type.color.opacity(0.15),
                in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            )
            .accessibilityLabel(type.rawValue)
    }
}

/// Selectable vehicle button used in the add/edit forms.
struct VehicleChip: View {
    let type: VehicleType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.symbol)
                    .font(.title3)
                Text(type.rawValue)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(width: 76, height: 64)
            .foregroundStyle(isSelected ? Color.white : type.color)
            .background(
                isSelected ? type.color : type.color.opacity(0.12),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(type.color.opacity(isSelected ? 0 : 0.25), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.0 : 0.96)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Horizontal row of vehicle chips bound to a selection.
struct VehiclePicker: View {
    @Binding var selection: VehicleType

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(VehicleType.allCases) { type in
                    VehicleChip(type: type, isSelected: selection == type) {
                        selection = type
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
        }
    }
}

/// Small statistic tile shown on the dashboard.
struct StatTile: View {
    let title: String
    let value: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.15), in: Circle())

            Text(value)
                .font(.headline.weight(.bold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 14)
    }
}

/// Capsule-shaped progress bar with custom colors.
struct CapsuleProgressBar: View {
    var progress: Double
    var tint: Color
    var track: Color = Color(.systemFill)
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { proxy in
            let clamped = min(max(progress, 0), 1)
            ZStack(alignment: .leading) {
                Capsule().fill(track)
                Capsule()
                    .fill(tint)
                    .frame(width: max(height, proxy.size.width * clamped))
            }
        }
        .frame(height: height)
        .animation(.easeInOut(duration: 0.4), value: progress)
    }
}

/// Origin → destination stack with a dotted connector line.
struct RouteTimeline: View {
    let origin: String
    let destination: String
    var tint: Color = Theme.brand
    var foreground: Color = .primary

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .strokeBorder(tint, lineWidth: 3)
                    .frame(width: 14, height: 14)
                Rectangle()
                    .fill(tint.opacity(0.5))
                    .frame(width: 2, height: 26)
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(tint)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("FROM").font(.caption2.weight(.bold)).opacity(0.6)
                    Text(origin).font(.headline)
                }
                Spacer(minLength: 10)
                VStack(alignment: .leading, spacing: 2) {
                    Text("TO").font(.caption2.weight(.bold)).opacity(0.6)
                    Text(destination).font(.headline)
                }
            }
            .foregroundStyle(foreground)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
