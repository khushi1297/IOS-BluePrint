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
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        currentStep = step
                    }
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
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary.opacity(0.82))
                .frame(width: 44, height: 44)
                .liquidGlassChip(cornerRadius: 12)
        }
        .accessibilityLabel("Jump to page")
    }
}
