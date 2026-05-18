import SwiftUI

// MARK: - App flow routing

extension AppStep {
    /// Bottom nav: house → `CanvasView`
    static let bottomNavHome = AppStep.canvas
    /// Bottom nav: stack → `TasksView`
    static let bottomNavTasks = AppStep.tasks
    /// Bottom nav: star → `GentleReflectionView`
    static let bottomNavStar = AppStep.gentleReflection

    /// `GapView` Continue → `TasksView`
    static let afterGapContinue = AppStep.tasks
    /// `TasksView` Continue → `TinyWinView`
    static let afterTasksContinue = AppStep.tinyWin
    /// `TinyWinView` Continue → `GentleReflectionView`
    static let afterTinyWinContinue = AppStep.gentleReflection

    /// Main hub screens that can show the floating bottom nav (not onboarding).
    var isMainHub: Bool {
        switch self {
        case .canvas, .gap, .tasks, .tinyWin, .gentleReflection:
            true
        default:
            false
        }
    }

    /// Whether the bottom nav should appear on main hub screens (including Canvas behind modals).
    var showsBottomNav: Bool { isMainHub }
}

extension Binding where Value == AppStep {
    func navigate(to step: AppStep) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            wrappedValue = step
        }
    }
}
