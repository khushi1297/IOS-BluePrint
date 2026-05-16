import SwiftUI

/// Shared home / stack / star bar used across blueprint screens. Star opens gentle reflection.
struct BlueprintBottomNavBar: View {
    @Binding var currentStep: AppStep
    var horizontalInset: CGFloat = 24
    var style: Style = .light

    enum Style {
        case light
        case dark
    }

    var body: some View {
        HStack {
            Spacer()
            tabButton(icon: "house", target: .canvas, isActive: currentStep == .canvas)
            Spacer()
            tabButton(icon: "square.stack.3d.up", target: .priorities, isActive: currentStep == .priorities)
            Spacer()
            tabButton(
                icon: currentStep == .gentleReflection ? "star.fill" : "star",
                target: .gentleReflection,
                isActive: currentStep == .gentleReflection
            )
            Spacer()
        }
        .padding(.vertical, 16)
        .background(style == .light ? Color.white : Color(white: 0.22))
        .clipShape(Capsule())
        .padding(.horizontal, horizontalInset)
        .shadow(color: style == .light ? .black.opacity(0.05) : .clear, radius: 10, x: 0, y: 5)
    }

    private func tabButton(icon: String, target: AppStep, isActive: Bool) -> some View {
        Button {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                currentStep = target
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(foreground(isActive: isActive, isStar: target == .gentleReflection))
        }
        .buttonStyle(.plain)
    }

    private func foreground(isActive: Bool, isStar: Bool) -> Color {
        switch style {
        case .light:
            if isActive {
                if isStar { return Color(hue: 0.52, saturation: 0.42, brightness: 0.92) }
                return Color(hue: 0.72, saturation: 0.45, brightness: 0.88)
            }
            if isStar { return Color(hue: 0.52, saturation: 0.35, brightness: 0.72) }
            return Color.secondary
        case .dark:
            return Color(hue: 0.55, saturation: 0.28, brightness: isActive ? 1.0 : 0.88)
        }
    }
}
