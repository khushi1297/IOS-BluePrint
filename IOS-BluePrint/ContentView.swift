import SwiftUI

enum AppStep: CaseIterable, Hashable {
    case landing
    case moodboard
    case questions
    case priorities
    case canvas
    case gap
    case tasks
    /// Post-tasks encouragement before returning to the canvas flow.
    case tinyWin
    /// Reflection hub (after tiny win; star tab elsewhere).
    case gentleReflection
}

extension AppStep {
    /// Full-screen backdrop behind the centered column (fills letterbox / padding gaps).
    var screenBackdropColor: Color {
        switch self {
        case .gentleReflection:
            Color(red: 0.98, green: 0.96, blue: 0.95)
        case .canvas, .landing, .moodboard:
            Color(hue: 0.08, saturation: 0.05, brightness: 0.98)
        case .gap, .tasks, .tinyWin:
            Color(red: 1.0, green: 0.984, blue: 0.973)
        case .priorities, .questions:
            Color(hue: 0.08, saturation: 0.05, brightness: 0.98)
        }
    }
}

struct ContentView: View {
    @State private var currentStep: AppStep = .landing
    @StateObject private var blueprint = BlueprintState()

    private var showsBottomNav: Bool {
        currentStep.showsBottomNav
    }

    /// Extra bottom inset for screens whose footer is a pinned CTA (not full-bleed scroll hubs).
    private func hubContentBottomPadding(safeAreaBottom: CGFloat) -> CGFloat {
        switch currentStep {
        case .tasks, .canvas, .gentleReflection:
            return 0
        default:
            return HubChromeMetrics.ctaFooterBottomPadding(safeAreaBottom: safeAreaBottom)
        }
    }

    var body: some View {
        GeometryReader { geo in
            let columnWidth = HubChromeMetrics.centeredColumnWidth(in: geo.size.width)

            ZStack {
                currentStep.screenBackdropColor
                    .ignoresSafeArea()

            HStack(spacing: 0) {
                Spacer(minLength: 0)

                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 0) {
                        Group {
                            switch currentStep {
                            case .landing:
                                LandingView(currentStep: $currentStep)
                                    .transition(.opacity)
                            case .moodboard:
                                EmotionEaseView(currentStep: $currentStep)
                                    .transition(.move(edge: .trailing))
                            case .questions:
                                QuestionsView(currentStep: $currentStep)
                                    .transition(.move(edge: .trailing))
                            case .priorities:
                                PrioritiesView(currentStep: $currentStep, blueprint: blueprint)
                                    .transition(
                                        .asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .trailing).combined(with: .opacity)
                                        )
                                    )
                            case .canvas:
                                CanvasView(currentStep: $currentStep, blueprint: blueprint)
                                    .transition(.opacity)
                            case .gap:
                                GapView(currentStep: $currentStep, blueprint: blueprint)
                                    .transition(.move(edge: .trailing))
                            case .tasks:
                                TasksView(currentStep: $currentStep, blueprint: blueprint)
                                    .transition(.move(edge: .trailing))
                            case .tinyWin:
                                TinyWinView(currentStep: $currentStep, blueprint: blueprint)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            case .gentleReflection:
                                GentleReflectionView(currentStep: $currentStep)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(
                            .bottom,
                            showsBottomNav
                                ? hubContentBottomPadding(safeAreaBottom: geo.safeAreaInsets.bottom)
                                : 0
                        )

                        if showsBottomNav {
                            BlueprintBottomNavBar(currentStep: $currentStep, horizontalInset: 24)
                                .padding(.top, HubChromeMetrics.navBarStackTopPadding)
                                .padding(.bottom, max(geo.safeAreaInsets.bottom, HubChromeMetrics.navBarBottomPadding))
                        }
                    }
                    .frame(width: columnWidth, height: geo.size.height, alignment: .top)

                    if currentStep != .questions {
                        DevPageJumpMenu(currentStep: $currentStep)
                            .padding(.top, geo.safeAreaInsets.top + 8)
                            .padding(.trailing, 16)
                            .zIndex(10_000)
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: showsBottomNav)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: blueprint.selectedMood?.rawValue)
        .onChange(of: currentStep) { _, step in
            if step == .tasks {
                blueprint.prepareForTasksIfNeeded()
            }
        }
    }
}

#Preview {
    ContentView()
}
