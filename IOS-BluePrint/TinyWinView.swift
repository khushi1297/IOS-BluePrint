import SwiftUI

// MARK: - Prototype layout

private enum TinyWinPrototypeLayout {
    case steady
    case gentle
    case rough
    case momentum
}

// MARK: - Momentum (Good) tiny win prototype

private enum MomentumTinyWinDesign {
    static let canvas = Color(red: 0.99, green: 0.98, blue: 0.95)       // #FDF9F3
    static let bodyText = Color(red: 0.35, green: 0.35, blue: 0.35)
    static let progressText = Color(red: 0.45, green: 0.45, blue: 0.45)
    static let ctaFill = Color(red: 0.91, green: 0.79, blue: 0.89)
}

// MARK: - Steady (Normal) tiny win prototype

private enum SteadyTinyWinDesign {
    static let canvas = Color(red: 0.99, green: 0.98, blue: 0.96)
    static let bodyText = Color(red: 0.35, green: 0.35, blue: 0.35)
    static let progressText = Color(red: 0.45, green: 0.45, blue: 0.45)
    static let ctaFill = Color(red: 0.88, green: 0.77, blue: 0.93)
}

// MARK: - Rough tiny win prototype

private enum RoughTinyWinDesign {
    static let canvas = Color(red: 0.98, green: 0.969, blue: 0.949)       // #FAF7F2
    static let bodyText = Color(red: 0.35, green: 0.35, blue: 0.35)
    static let progressText = Color(red: 0.45, green: 0.45, blue: 0.45)
    static let ctaFill = Color(red: 0.86, green: 0.77, blue: 0.88)
}

// MARK: - Gentle (Low) tiny win prototype

private enum GentleTinyWinDesign {
    static let canvas = Color(red: 0.99, green: 0.98, blue: 0.96)
    static let bodyText = Color(red: 0.35, green: 0.35, blue: 0.35)
    static let progressText = Color(red: 0.45, green: 0.45, blue: 0.45)
    static let ctaFill = Color(red: 0.82, green: 0.71, blue: 0.88)
}

private struct PrototypeTinyWinCapsuleButtonStyle: ButtonStyle {
    let fill: Color
    let shadowTint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.black.opacity(0.82))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background {
                ZStack {
                    Capsule()
                        .fill(fill)
                    Capsule()
                        .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.28))
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                }
                .shadow(color: shadowTint.opacity(0.28), radius: 12, x: 0, y: 6)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.32, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

/// Shown after the user leaves the Tasks screen — small celebration before continuing the flow.
struct TinyWinView: View {
    @Binding var currentStep: AppStep
    @ObservedObject var blueprint: BlueprintState

    private var mood: CanvasMood { blueprint.selectedMood ?? .rough }

    private var prototypeLayout: TinyWinPrototypeLayout {
        switch mood {
        case .good: .momentum
        case .normal: .steady
        case .low: .gentle
        case .rough: .rough
        }
    }

    private var taskPageContent: TaskPageContent {
        let lifeArea = blueprint.selectedLifeArea ?? .freedomFlexibility
        let gap = blueprint.selectedGap ?? .burnout
        let key = blueprint.taskGenerationKey
            ?? "preview|\(mood.rawValue)|\(lifeArea.rawValue)|\(gap.rawValue)"
        return DailyTaskGenerator.makePageContent(
            mood: mood,
            lifeArea: lifeArea,
            gap: gap,
            generationKey: key
        )
    }

    private var completedActiveTasks: [DailyTask] {
        taskPageContent.tasks.filter { task in
            task.role.countsTowardRequired && blueprint.isTaskCompleted(task.id)
        }
    }

    private var totalStepsCompleted: Int {
        taskPageContent.tasks.filter { task in
            if case .permanentlyLocked = task.role { return false }
            return blueprint.isTaskCompleted(task.id)
        }.count
    }

    private var activeStepsCompleted: Int {
        completedActiveTasks.count
    }

    private var progressLabel: String {
        switch prototypeLayout {
        case .momentum:
            let count = max(totalStepsCompleted, 1)
            return count == 1 ? "1 step completed" : "\(count) steps completed"
        case .steady:
            return activeStepsCompleted == 1
                ? "1 steady step completed"
                : "\(activeStepsCompleted) steady steps completed"
        case .gentle, .rough:
            return activeStepsCompleted == 1
                ? "1 gentle step completed"
                : "\(activeStepsCompleted) gentle steps completed"
        }
    }

    var body: some View {
        ZStack {
            prototypeCanvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                winContent

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var winContent: some View {
        VStack(spacing: 22) {
            mood.styledScreenTitle(mood.tinyWinHeadline, size: 34)

            Text(mood.tinyWinBody)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(prototypeBodyText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            winCardImage

            Text(progressLabel)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(prototypeProgressText)

            gentleReflectionButton
                .padding(.horizontal, 20)
                .padding(.top, 4)
        }
    }

    private var prototypeCanvas: Color {
        switch prototypeLayout {
        case .momentum: MomentumTinyWinDesign.canvas
        case .steady: SteadyTinyWinDesign.canvas
        case .gentle: GentleTinyWinDesign.canvas
        case .rough: RoughTinyWinDesign.canvas
        }
    }

    private var prototypeBodyText: Color {
        switch prototypeLayout {
        case .momentum: MomentumTinyWinDesign.bodyText
        case .steady: SteadyTinyWinDesign.bodyText
        case .gentle: GentleTinyWinDesign.bodyText
        case .rough: RoughTinyWinDesign.bodyText
        }
    }

    private var prototypeProgressText: Color {
        switch prototypeLayout {
        case .momentum: MomentumTinyWinDesign.progressText
        case .steady: SteadyTinyWinDesign.progressText
        case .gentle: GentleTinyWinDesign.progressText
        case .rough: RoughTinyWinDesign.progressText
        }
    }

    private var winCardImage: some View {
        Image(mood.tinyWinCardAsset)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
    }

    private var prototypeCtaFill: Color {
        switch prototypeLayout {
        case .momentum: MomentumTinyWinDesign.ctaFill
        case .steady: SteadyTinyWinDesign.ctaFill
        case .gentle: GentleTinyWinDesign.ctaFill
        case .rough: RoughTinyWinDesign.ctaFill
        }
    }

    private var prototypeCtaShadow: Color {
        switch prototypeLayout {
        case .momentum, .steady:
            Color(red: 0.65, green: 0.52, blue: 0.78)
        case .gentle, .rough:
            Color(red: 0.58, green: 0.42, blue: 0.78)
        }
    }

    private var gentleReflectionButton: some View {
        Button {
            $currentStep.navigate(to: .afterTinyWinContinue)
        } label: {
            Text("Gentle Reflection")
        }
        .buttonStyle(
            PrototypeTinyWinCapsuleButtonStyle(
                fill: prototypeCtaFill,
                shadowTint: prototypeCtaShadow
            )
        )
    }
}

#Preview("Momentum") {
    let blueprint = BlueprintState()
    blueprint.selectedMood = .good
    let content = DailyTaskGenerator.makePageContent(
        mood: .good,
        lifeArea: .freedomFlexibility,
        gap: .burnout,
        generationKey: "preview"
    )
    blueprint.completedTaskIDs = Set(content.tasks.prefix(4).map(\.id))
    return TinyWinView(currentStep: .constant(.tinyWin), blueprint: blueprint)
}

#Preview("Steady") {
    let blueprint = BlueprintState()
    blueprint.selectedMood = .normal
    blueprint.completedTaskIDs = Set(
        DailyTaskGenerator.makePageContent(
            mood: .normal,
            lifeArea: .freedomFlexibility,
            gap: .burnout,
            generationKey: "preview"
        )
        .tasks
        .filter(\.role.countsTowardRequired)
        .prefix(3)
        .map(\.id)
    )
    return TinyWinView(currentStep: .constant(.tinyWin), blueprint: blueprint)
}

#Preview("Gentle") {
    let blueprint = BlueprintState()
    blueprint.selectedMood = .low
    let content = DailyTaskGenerator.makePageContent(
        mood: .low,
        lifeArea: .freedomFlexibility,
        gap: .burnout,
        generationKey: "preview"
    )
    blueprint.completedTaskIDs = Set(
        content.tasks.filter(\.role.countsTowardRequired).prefix(2).map(\.id)
    )
    return TinyWinView(currentStep: .constant(.tinyWin), blueprint: blueprint)
}

#Preview("Rough") {
    let blueprint = BlueprintState()
    blueprint.selectedMood = .rough
    let content = DailyTaskGenerator.makePageContent(
        mood: .rough,
        lifeArea: .freedomFlexibility,
        gap: .burnout,
        generationKey: "preview"
    )
    blueprint.completedTaskIDs = Set(
        content.tasks.filter(\.role.countsTowardRequired).prefix(1).map(\.id)
    )
    return TinyWinView(currentStep: .constant(.tinyWin), blueprint: blueprint)
}
