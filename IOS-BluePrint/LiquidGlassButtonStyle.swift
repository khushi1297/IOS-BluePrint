import SwiftUI

// MARK: - Shared primary CTA (Continue, etc.)

/// One pink fill, one type size, and one vertical padding for primary capsule actions app-wide.
enum BlueprintPrimaryButton {
    static let fill = Color(red: 0.96, green: 0.50, blue: 0.70)

    static let titleFont: Font = .system(size: 17, weight: .semibold, design: .rounded)
    static let verticalPadding: CGFloat = 16

    static let disabledBackground = Color(hue: 0.72, saturation: 0.08, brightness: 0.93)
}

/// Primary capsule with a hint of frost and specular edge.
struct BlueprintPrimaryCapsuleButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BlueprintPrimaryButton.titleFont)
            .foregroundStyle(isEnabled ? Color.white : Color.black.opacity(0.38))
            .frame(maxWidth: .infinity)
            .padding(.vertical, BlueprintPrimaryButton.verticalPadding)
            .background {
                ZStack {
                    if isEnabled {
                        Capsule()
                            .fill(BlueprintPrimaryButton.fill)
                        Capsule()
                            .fill(.ultraThinMaterial)
                        Capsule()
                            .fill(Color.white.opacity(configuration.isPressed ? 0.1 : 0.18))
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                    } else {
                        Capsule()
                            .fill(BlueprintPrimaryButton.disabledBackground)
                    }
                }
                .compositingGroup()
                .shadow(color: .black.opacity(isEnabled ? 0.11 : 0.06), radius: 14, x: 0, y: 8)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                .shadow(color: .white.opacity(isEnabled ? 0.38 : 0), radius: 1, x: 0, y: -1)
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.97 : 1)
            .animation(.spring(response: 0.32, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

extension View {
    /// Typography + color for labels on `BlueprintPrimaryCapsuleButtonStyle` when you need custom label content (e.g. `HStack` with an icon).
    func blueprintPrimaryCTALabel(enabled: Bool = true) -> some View {
        font(BlueprintPrimaryButton.titleFont)
            .foregroundStyle(enabled ? Color.white : Color.black.opacity(0.38))
    }
}

// MARK: - Capsule primary actions (Continue, etc.)

/// Frosted “liquid glass” capsule — use for **buttons only**, not full cards.
struct LiquidGlassCapsuleButtonStyle: ButtonStyle {
    /// Soft tint under the material (e.g. lavender / teal).
    var tint: Color? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)

                    if let tint {
                        Capsule()
                            .fill(tint.opacity(0.22))
                    }

                    Capsule()
                        .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.28))

                    Capsule()
                        .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.1)
                }
                .compositingGroup()
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 10)
                .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
                .shadow(color: .white.opacity(0.5), radius: 1, x: 0, y: -1)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.32, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

// MARK: - Small chip (e.g. dev hamburger)

private struct LiquidGlassChipBackground: View {
    var cornerRadius: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.22))

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 6)
        .shadow(color: .white.opacity(0.45), radius: 0.5, x: 0, y: -0.5)
    }
}

extension View {
    /// Compact glass plate for icon-only controls (not cards).
    func liquidGlassChip(cornerRadius: CGFloat = 12) -> some View {
        background {
            LiquidGlassChipBackground(cornerRadius: cornerRadius)
        }
    }
}
