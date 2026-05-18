import SwiftUI

extension AppStep {
    /// Labels for the dev hamburger menu (temporary navigation).
    var devJumpTitle: String {
        switch self {
        case .landing: return "Landing"
        case .moodboard: return "Mood board"
        case .questions: return "Questions"
        case .priorities: return "Priorities"
        case .canvas: return "Canvas"
        case .gap: return "Gap"
        case .tasks: return "Tasks"
        case .tinyWin: return "Tiny win"
        case .gentleReflection: return "Reflection"
        }
    }
}

/// Three-line menu to jump to any `AppStep` (for development / previews).
struct DevPageJumpMenu: View {
    @Binding var currentStep: AppStep

    var body: some View {
        Menu {
            ForEach(Array(AppStep.allCases), id: \.self) { step in
                Button {
                    $currentStep.navigate(to: step)
                } label: {
                    Label {
                        Text(step.devJumpTitle)
                    } icon: {
                        Image(systemName: currentStep == step ? "checkmark.circle.fill" : "circle")
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hue: 0.58, saturation: 0.45, brightness: 0.72).opacity(0.55))
                .frame(width: 36, height: 36)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.85)
                }
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.42))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .accessibilityLabel("Jump to page")
    }
}
