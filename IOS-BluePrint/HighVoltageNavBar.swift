import SwiftUI

/// Floating bottom nav from High Voltage prototype SVGs.
struct HighVoltageNavBar: View {
    @Binding var selection: Tab

    enum Tab: CaseIterable {
        case home, documents, starred

        var iconName: String {
            switch self {
            case .home: "icon_home"
            case .documents: "icon_documents"
            case .starred: "icon_star"
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .home: "Canvas"
            case .documents: "Today's tasks"
            case .starred: "Gentle reflection"
            }
        }

        init(appStep: AppStep) {
            switch appStep {
            case .tasks, .tinyWin:
                self = .documents
            case .gentleReflection:
                self = .starred
            default:
                self = .home
            }
        }

        var appStep: AppStep {
            switch self {
            case .home: .bottomNavHome
            case .documents: .bottomNavTasks
            case .starred: .bottomNavStar
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        selection = tab
                    }
                } label: {
                    Image(tab.iconName)
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .opacity(selection == tab ? 1.0 : 0.4)
                        .scaleEffect(selection == tab ? 1.0 : 0.88)
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.accessibilityLabel)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(.horizontal, 28)
        .frame(height: 68)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selection)
    }
}

/// App routing wrapper — maps `AppStep` ↔ nav tabs.
struct BlueprintBottomNavBar: View {
    @Binding var currentStep: AppStep
    var horizontalInset: CGFloat = 24

    private var selection: Binding<HighVoltageNavBar.Tab> {
        Binding(
            get: { HighVoltageNavBar.Tab(appStep: currentStep) },
            set: { tab in
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    currentStep = tab.appStep
                }
            }
        )
    }

    var body: some View {
        HighVoltageNavBar(selection: selection)
            .padding(.horizontal, horizontalInset)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color(red: 0.98, green: 0.96, blue: 0.95).ignoresSafeArea()
        BlueprintBottomNavBar(currentStep: .constant(.canvas))
            .padding(.bottom, 24)
    }
}
