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

struct ContentView: View {
    @State private var currentStep: AppStep = .landing

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
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
                        PrioritiesView(currentStep: $currentStep)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                )
                            )
                    case .canvas:
                        CanvasView(currentStep: $currentStep)
                            .transition(.opacity)
                    case .gap:
                        GapView(currentStep: $currentStep)
                            .transition(.move(edge: .trailing))
                    case .tasks:
                        TasksView(currentStep: $currentStep)
                            .transition(.move(edge: .trailing))
                    case .tinyWin:
                        TinyWinView(currentStep: $currentStep)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    case .gentleReflection:
                        GentleReflectionView(currentStep: $currentStep)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)

                // Hidden on Questions so it is not mistaken for the in-card menu control.
                if currentStep != .questions {
                    DevPageJumpMenu(currentStep: $currentStep)
                        .padding(.top, geo.safeAreaInsets.top + 6)
                        .padding(.trailing, 12 + geo.safeAreaInsets.trailing)
                        .zIndex(10_000)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)
    }
}

#Preview {
    ContentView()
}
