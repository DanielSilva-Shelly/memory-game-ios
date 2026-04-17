import SwiftUI

// MARK: - Design system tokens

enum DS {
    static let accent        = Color(red: 1.00, green: 0.36, blue: 0.30)  // coral
    static let textPrimary   = Color(red: 0.10, green: 0.10, blue: 0.10)  // #1A1A1A
    static let textSecondary = Color(red: 0.42, green: 0.42, blue: 0.42)  // #6B6B6B
    static let textTertiary  = Color(red: 0.63, green: 0.63, blue: 0.63)  // #A0A0A0
    static let surface       = Color.white
    static let background    = Color(red: 0.98, green: 0.97, blue: 0.96)  // warm off-white
    static let pillBg        = Color(red: 0.93, green: 0.93, blue: 0.93)  // light neutral
}

// MARK: - Shared button styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(DS.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundStyle(Color.white)
            .shadow(color: DS.accent.opacity(configuration.isPressed ? 0.18 : 0.28),
                    radius: configuration.isPressed ? 4 : 8,
                    x: 0, y: configuration.isPressed ? 2 : 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.85), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(DS.pillBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .foregroundStyle(DS.textSecondary)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.85), value: configuration.isPressed)
    }
}
