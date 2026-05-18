import SwiftUI

// MARK: - Figma task frame (402 × 874) — Continue CTA

private enum TasksFigmaLayout {
    static let continueWidth: CGFloat = 247
    static let continueHeight: CGFloat = 48
    static let continueCornerRadius: CGFloat = 24
    static let horizontalMargin: CGFloat = 78
    /// Bottom edge of the pill, measured from the physical screen bottom.
    static let continueBottomFromScreen: CGFloat = 97
    /// Reference inset above the home-indicator safe area (97 − 34).
    static let continueBottomAboveSafeArea: CGFloat = 63

    static func continueBottomPadding(safeAreaBottom: CGFloat) -> CGFloat {
        max(continueBottomAboveSafeArea, continueBottomFromScreen - safeAreaBottom)
    }

    /// Scroll tail so task rows clear the CTA (helper sits in the band below the button).
    static func scrollBottomInset(safeAreaBottom: CGFloat) -> CGFloat {
        continueBottomPadding(safeAreaBottom: safeAreaBottom)
            + continueHeight
            + 20
    }
}

// MARK: - Prototype layout

private enum TaskScreenLayout {
    case standard
    case good
    case normal
    case rough
    case low
}

// MARK: - Good mood prototype tokens (High Voltage reference)

private enum GoodTasksDesign {
    static let canvas = Color(red: 1.0, green: 0.984, blue: 0.973)       // #FFFBF8
    static let cardYellow = Color(red: 1.0, green: 0.84, blue: 0.32)
    static let chipYellow = Color(red: 1.0, green: 0.93, blue: 0.62)
    static let emojiOrange = Color(red: 1.0, green: 0.62, blue: 0.28)
    static let titleText = Color.black.opacity(0.9)
    static let subtitleText = Color.black.opacity(0.55)
    static let taglineText = Color(red: 0.35, green: 0.35, blue: 0.35)
    static let helperText = Color(red: 0.55, green: 0.55, blue: 0.55)
    static let changeMoodText = Color(red: 0.55, green: 0.55, blue: 0.55)

    static let ctaFill = Color(red: 0.92, green: 0.76, blue: 0.52)
}

// MARK: - Normal mood prototype tokens (High Voltage reference)

private enum NormalTasksDesign {
    static let canvas = Color(red: 1.0, green: 0.984, blue: 0.973)       // #FFFBF8
    static let cardAqua = Color(red: 0.45, green: 0.78, blue: 0.95)
    static let chipBlue = Color(red: 0.85, green: 0.93, blue: 1.0)
    static let emojiBlue = Color(red: 0.55, green: 0.78, blue: 0.95)
    static let titleText = Color.black.opacity(0.9)
    static let subtitleText = Color.black.opacity(0.55)
    static let taglineText = Color(red: 0.35, green: 0.35, blue: 0.35)
    static let helperText = Color(red: 0.55, green: 0.55, blue: 0.55)
    static let changeMoodText = Color(red: 0.55, green: 0.55, blue: 0.55)
    static let accentNavy = Color(red: 0.15, green: 0.35, blue: 0.55)

    static let ctaFill = Color(red: 0.65, green: 0.84, blue: 0.96)
}

// MARK: - Rough mood prototype tokens (High Voltage reference)

private enum RoughTasksDesign {
    static let canvas = Color(red: 1.0, green: 0.984, blue: 0.973)       // #FFFBF8
    static let cardCoral = Color(red: 1.0, green: 0.42, blue: 0.42)      // #FF6B6B
    static let chipPink = Color(red: 1.0, green: 0.82, blue: 0.835)      // #FFD1D5
    static let emojiSquare = Color(red: 0.90, green: 0.42, blue: 0.45)
    static let titleText = Color.black.opacity(0.9)
    static let subtitleText = Color(red: 0.42, green: 0.14, blue: 0.16).opacity(0.72)
    static let taglineText = Color(red: 0.35, green: 0.35, blue: 0.35)
    static let helperText = Color(red: 0.55, green: 0.55, blue: 0.55)
    static let changeMoodText = Color(red: 0.55, green: 0.55, blue: 0.55)

    static let ctaFill = Color(red: 1.0, green: 0.77, blue: 0.78)
}

// MARK: - Low mood prototype tokens (High Voltage reference)

private enum LowTasksDesign {
    static let canvas = Color(red: 0.98, green: 0.969, blue: 0.949)       // #FAF7F2
    static let cardLavender = Color(red: 0.82, green: 0.74, blue: 0.94)
    static let chipLavender = Color(red: 0.88, green: 0.82, blue: 0.97)
    static let accentPurple = Color(red: 0.30, green: 0.18, blue: 0.45)
    static let titleText = Color(red: 0.28, green: 0.15, blue: 0.42)
    static let subtitleText = Color(red: 0.38, green: 0.28, blue: 0.48)
    static let taglineText = Color(red: 0.35, green: 0.35, blue: 0.35)
    static let helperText = Color(red: 0.55, green: 0.55, blue: 0.55)
    static let changeMoodText = Color(red: 0.55, green: 0.55, blue: 0.55)

    static let ctaFill = Color(red: 0.83, green: 0.72, blue: 0.90)
}

struct TasksView: View {
    @Binding var currentStep: AppStep
    @ObservedObject var blueprint: BlueprintState

    @State private var pageContent: TaskPageContent?
    @State private var generationKey: String = ""
    @State private var showMoodOverlay = false
    @State private var pendingMood: CanvasMood?

    private var mood: CanvasMood? { blueprint.selectedMood }

    private var taskLayout: TaskScreenLayout {
        switch mood {
        case .good: .good
        case .normal: .normal
        case .rough: .rough
        case .low: .low
        default: .standard
        }
    }

    private var isPrototypeLayout: Bool {
        taskLayout != .standard
    }

    private var screenBackground: Color {
        switch taskLayout {
        case .good: GoodTasksDesign.canvas
        case .normal: NormalTasksDesign.canvas
        case .rough: RoughTasksDesign.canvas
        case .low: LowTasksDesign.canvas
        case .standard: GoodTasksDesign.canvas
        }
    }

    private var cardFill: Color {
        switch taskLayout {
        case .good: GoodTasksDesign.cardYellow
        case .normal: NormalTasksDesign.cardAqua
        case .rough: RoughTasksDesign.cardCoral
        case .low: LowTasksDesign.cardLavender
        case .standard: GoodTasksDesign.cardYellow
        }
    }

    private var isFlowComplete: Bool { blueprint.isReadyForTasks }

    private var supportiveSentence: String {
        mood?.tasksTagline ?? pageContent?.supportiveSentence ?? "Be kind to yourself today"
    }

    private var helperText: String {
        mood?.tasksHelperText ?? pageContent?.helperText ?? "Check off the task as you go"
    }

    private var ctaTitle: String {
        mood?.tasksCTATitle ?? pageContent?.ctaTitle ?? "Continue"
    }

    private var canProceed: Bool {
        guard let pageContent else { return false }
        let tasksDone = pageContent.canProceed(completedIDs: blueprint.completedTaskIDs)
        if !pageContent.mood.tasksShowsContextChips {
            return tasksDone
        }
        return isFlowComplete && tasksDone
    }

    var body: some View {
        GeometryReader { geo in
            let continueBottom = TasksFigmaLayout.continueBottomPadding(
                safeAreaBottom: geo.safeAreaInsets.bottom
            )
            let scrollInset = TasksFigmaLayout.scrollBottomInset(
                safeAreaBottom: geo.safeAreaInsets.bottom
            )

            ZStack {
                screenBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 24)
                        .padding(.top, isPrototypeLayout ? 16 : 12)
                        .padding(.bottom, isPrototypeLayout ? 10 : 12)

                    ScrollView {
                        VStack(spacing: isPrototypeLayout ? 12 : 14) {
                            if !isFlowComplete, !isPrototypeLayout {
                                flowSetupBanner
                            }

                            if let pageContent {
                                if pageContent.mood.tasksShowsContextChips, isFlowComplete {
                                    contextChips(pageContent)
                                }

                                ForEach(pageContent.tasks) { task in
                                    let locked = pageContent.isLocked(task, completedIDs: blueprint.completedTaskIDs)
                                    TodayTaskRow(
                                        task: task,
                                        displaySubtitle: pageContent.displaySubtitle(
                                            for: task,
                                            completedIDs: blueprint.completedTaskIDs
                                        ),
                                        locked: locked,
                                        isCompleted: blueprint.isTaskCompleted(task.id),
                                        cardFill: cardFill,
                                        layout: taskLayout
                                    ) {
                                        toggleTask(task, locked: locked)
                                    }
                                }
                            } else if mood == nil {
                                setMoodBanner
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, isPrototypeLayout ? 6 : 4)
                        .padding(.bottom, scrollInset)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                tasksFooterChrome(continueBottom: continueBottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.horizontal, TasksFigmaLayout.horizontalMargin)

                if showMoodOverlay {
                MoodCheckInOverlay(
                    pendingMood: $pendingMood,
                    onClose: {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                            showMoodOverlay = false
                            pendingMood = nil
                        }
                    },
                    onContinue: {
                        guard let newMood = pendingMood else { return }
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                            blueprint.selectedMood = newMood
                            blueprint.completedTaskIDs.removeAll()
                            showMoodOverlay = false
                            pendingMood = nil
                            refreshPageContent(force: true)
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .center)))
                .zIndex(50_000)
                }
            }
        }
        .onAppear {
            blueprint.prepareForTasksIfNeeded()
            refreshPageContent(force: false)
        }
        .onChange(of: blueprint.selectedMood) { _, _ in refreshPageContent(force: true) }
        .onChange(of: blueprint.selectedLifeArea) { _, _ in refreshPageContent(force: true) }
        .onChange(of: blueprint.selectedGap) { _, _ in refreshPageContent(force: true) }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: isPrototypeLayout ? 12 : 14) {
            Group {
                if let mood {
                    mood.styledScreenTitle(
                        "Today's task",
                        size: isPrototypeLayout ? 38 : 34,
                        weight: .heavy,
                        tracking: isPrototypeLayout ? -0.6 : 0
                    )
                } else {
                    Text("Today's task")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(MoodScreenAccent.goodTitle)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HStack(alignment: .center, spacing: 8) {
                moodChip
                Spacer(minLength: 4)
                Button {
                    pendingMood = blueprint.selectedMood
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                        showMoodOverlay = true
                    }
                } label: {
                    Text("Change mood ›")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(prototypeChangeMoodColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, isPrototypeLayout ? 44 : 8)

            Text(supportiveSentence)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(prototypeTaglineColor)
                .multilineTextAlignment(.center)
                .lineSpacing(isPrototypeLayout ? 2 : 0)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, isPrototypeLayout ? 4 : 0)
        }
    }

    private var prototypeChangeMoodColor: Color {
        switch taskLayout {
        case .good: GoodTasksDesign.changeMoodText
        case .normal: NormalTasksDesign.changeMoodText
        case .rough: RoughTasksDesign.changeMoodText
        case .low: LowTasksDesign.changeMoodText
        case .standard: Color(white: 0.45)
        }
    }

    private var prototypeTaglineColor: Color {
        switch taskLayout {
        case .good: GoodTasksDesign.taglineText
        case .normal: NormalTasksDesign.taglineText
        case .rough: RoughTasksDesign.taglineText
        case .low: LowTasksDesign.taglineText
        case .standard: Color(white: 0.32)
        }
    }

    @ViewBuilder
    private var moodChip: some View {
        if let mood {
            if taskLayout == .good {
                HStack(spacing: 8) {
                    MoodAssetIcon(mood: mood, height: 24, maxWidth: 68)

                    Text(mood.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.88))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(GoodTasksDesign.chipYellow)
                .clipShape(Capsule())
            } else if taskLayout == .normal {
                HStack(spacing: 8) {
                    MoodAssetIcon(mood: mood, height: 24, maxWidth: 68)

                    Text(mood.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(NormalTasksDesign.accentNavy)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(NormalTasksDesign.chipBlue)
                .clipShape(Capsule())
            } else if taskLayout == .rough {
                HStack(spacing: 8) {
                    MoodAssetIcon(mood: mood, height: 24, maxWidth: 68)

                    Text(mood.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.88))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(RoughTasksDesign.chipPink)
                .clipShape(Capsule())
            } else if taskLayout == .low {
                HStack(spacing: 8) {
                    MoodAssetIcon(mood: mood, height: 24, maxWidth: 68)

                    Text(mood.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(LowTasksDesign.accentPurple)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(LowTasksDesign.chipLavender)
                .clipShape(Capsule())
            } else {
                HStack(spacing: 8) {
                    MoodAssetIcon(mood: mood, height: 24, maxWidth: 68)

                    Text(mood.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(mood.tasksChipLabelColor)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(mood.tasksChipBackground)
                .clipShape(Capsule())
            }
        } else {
            Text("Set mood")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(RoughTasksDesign.chipPink)
                .clipShape(Capsule())
        }
    }

    private func contextChips(_ content: TaskPageContent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            chipLabel(content.lifeArea.title)
            chipLabel(content.gap.listTitle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func chipLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(Color(white: 0.35))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.85))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 0.5)
            )
    }

    private var flowSetupBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Personalize your list")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color(white: 0.28))

            Text("Pick a life area on Canvas and a blocker on Gap — your micro-actions will update.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color(white: 0.4))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                if blueprint.selectedLifeArea == nil {
                    Button {
                        withAnimation { currentStep = .canvas }
                    } label: {
                        Text("Go to Canvas")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(RoughTasksDesign.chipPink)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                if blueprint.selectedGap == nil {
                    Button {
                        withAnimation { currentStep = .gap }
                    } label: {
                        Text("Go to Gap")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(RoughTasksDesign.chipPink)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private var setMoodBanner: some View {
        Text("Check in on Canvas to set how you're feeling today.")
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(Color(white: 0.4))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Footer (Figma 402×874)

    /// Continue at Figma offset; helper text in the open band between the button and bottom nav.
    private func tasksFooterChrome(continueBottom: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Text(helperText)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(prototypeHelperColor)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 10)
            }
            .frame(height: continueBottom)

            tasksContinueButton
                .frame(maxWidth: .infinity)
                .padding(.bottom, continueBottom)
        }
    }

    @ViewBuilder
    private var tasksContinueButton: some View {
        let action = { $currentStep.navigate(to: .afterTasksContinue) }

        switch taskLayout {
        case .good:
            Button(action: action) { Text(ctaTitle) }
                .buttonStyle(GoodContinueButtonStyle(isEnabled: canProceed))
                .disabled(!canProceed)
        case .normal:
            Button(action: action) { Text(ctaTitle) }
                .buttonStyle(NormalContinueButtonStyle(isEnabled: canProceed))
                .disabled(!canProceed)
        case .rough:
            Button(action: action) { Text(ctaTitle) }
                .buttonStyle(RoughContinueButtonStyle(isEnabled: canProceed))
                .disabled(!canProceed)
        case .low:
            Button(action: action) { Text(ctaTitle) }
                .buttonStyle(LowContinueButtonStyle(isEnabled: canProceed))
                .disabled(!canProceed)
        case .standard:
            Button(action: action) {
                Text(ctaTitle)
                    .font(BlueprintPrimaryButton.titleFont)
                    .foregroundStyle(Color.black.opacity(canProceed ? 0.82 : 0.38))
            }
            .buttonStyle(LiquidGlassCapsuleButtonStyle(tint: mood?.tasksChipBackground ?? Color(red: 1.0, green: 0.82, blue: 0.84)))
            .disabled(!canProceed)
            .opacity(canProceed ? 1 : 0.5)
            .frame(width: TasksFigmaLayout.continueWidth, height: TasksFigmaLayout.continueHeight)
            .clipShape(RoundedRectangle(cornerRadius: TasksFigmaLayout.continueCornerRadius, style: .continuous))
        }
    }

    private var prototypeHelperColor: Color {
        switch taskLayout {
        case .good: GoodTasksDesign.helperText
        case .normal: NormalTasksDesign.helperText
        case .rough: RoughTasksDesign.helperText
        case .low: LowTasksDesign.helperText
        case .standard: Color(white: 0.5)
        }
    }

    // MARK: - Data

    private func refreshPageContent(force: Bool) {
        guard let mood = blueprint.selectedMood else {
            pageContent = nil
            generationKey = ""
            return
        }

        let lifeArea = blueprint.selectedLifeArea ?? .freedomFlexibility
        let gap = blueprint.selectedGap ?? .burnout
        let key = blueprint.taskGenerationKey
            ?? "preview|\(mood.rawValue)|\(lifeArea.rawValue)|\(gap.rawValue)"

        if !force, key == generationKey, pageContent != nil { return }
        generationKey = key

        let content = DailyTaskGenerator.makePageContent(
            mood: mood,
            lifeArea: lifeArea,
            gap: gap,
            generationKey: key
        )

        withAnimation(.easeInOut(duration: 0.25)) {
            pageContent = content
        }

        let validIDs = Set(content.tasks.map(\.id))
        blueprint.completedTaskIDs = blueprint.completedTaskIDs.intersection(validIDs)
    }

    private func toggleTask(_ task: DailyTask, locked: Bool) {
        guard !locked else { return }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            blueprint.toggleTaskCompleted(task.id)
        }
    }
}

// MARK: - Normal Continue button

private struct NormalContinueButtonStyle: ButtonStyle {
    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(NormalTasksDesign.accentNavy.opacity(isEnabled ? 1 : 0.35))
            .frame(width: TasksFigmaLayout.continueWidth, height: TasksFigmaLayout.continueHeight)
            .background {
                prototypeCapsuleBackground(
                    fill: NormalTasksDesign.ctaFill,
                    shadow: Color(red: 0.45, green: 0.72, blue: 0.90).opacity(0.35),
                    pressed: configuration.isPressed,
                    cornerRadius: TasksFigmaLayout.continueCornerRadius
                )
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(.spring(response: 0.32, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

// MARK: - Good Continue button

private struct GoodContinueButtonStyle: ButtonStyle {
    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.black.opacity(isEnabled ? 0.85 : 0.35))
            .frame(width: TasksFigmaLayout.continueWidth, height: TasksFigmaLayout.continueHeight)
            .background {
                prototypeCapsuleBackground(
                    fill: GoodTasksDesign.ctaFill,
                    shadow: Color(red: 0.88, green: 0.68, blue: 0.38).opacity(0.35),
                    pressed: configuration.isPressed,
                    cornerRadius: TasksFigmaLayout.continueCornerRadius
                )
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(.spring(response: 0.32, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

// MARK: - Low Continue button

private struct LowContinueButtonStyle: ButtonStyle {
    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(LowTasksDesign.accentPurple.opacity(isEnabled ? 1 : 0.35))
            .frame(width: TasksFigmaLayout.continueWidth, height: TasksFigmaLayout.continueHeight)
            .background {
                prototypeCapsuleBackground(
                    fill: LowTasksDesign.ctaFill,
                    shadow: Color(red: 0.65, green: 0.52, blue: 0.78).opacity(0.35),
                    pressed: configuration.isPressed,
                    cornerRadius: TasksFigmaLayout.continueCornerRadius
                )
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(.spring(response: 0.32, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

// MARK: - Rough Continue button

private struct RoughContinueButtonStyle: ButtonStyle {
    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.black.opacity(isEnabled ? 0.85 : 0.35))
            .frame(width: TasksFigmaLayout.continueWidth, height: TasksFigmaLayout.continueHeight)
            .background {
                prototypeCapsuleBackground(
                    fill: RoughTasksDesign.ctaFill,
                    shadow: Color(red: 1.0, green: 0.6, blue: 0.65).opacity(0.35),
                    pressed: configuration.isPressed,
                    cornerRadius: TasksFigmaLayout.continueCornerRadius
                )
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .opacity(isEnabled ? 1 : 0.42)
            .animation(.spring(response: 0.32, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

@ViewBuilder
private func prototypeCapsuleBackground(
    fill: Color,
    shadow: Color,
    pressed: Bool,
    cornerRadius: CGFloat = TasksFigmaLayout.continueCornerRadius
) -> some View {
    let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    ZStack {
        shape.fill(fill)
        shape.fill(Color.white.opacity(pressed ? 0.15 : 0.28))
        shape.strokeBorder(Color.white.opacity(0.55), lineWidth: 1)
    }
    .shadow(color: shadow, radius: 12, x: 0, y: 6)
    .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
}

// MARK: - Task row

private struct TodayTaskRow: View {
    let task: DailyTask
    let displaySubtitle: String
    let locked: Bool
    let isCompleted: Bool
    let cardFill: Color
    var layout: TaskScreenLayout = .standard
    let onToggle: () -> Void

    private var isPrototypeLayout: Bool {
        layout != .standard
    }

    private var titleColor: Color {
        switch layout {
        case .good: GoodTasksDesign.titleText
        case .normal: NormalTasksDesign.titleText
        case .rough: RoughTasksDesign.titleText
        case .low: LowTasksDesign.titleText
        case .standard: Color.black.opacity(locked ? 0.82 : 0.9)
        }
    }

    private var subtitleColor: Color {
        switch layout {
        case .good: GoodTasksDesign.subtitleText
        case .normal: NormalTasksDesign.subtitleText
        case .rough: RoughTasksDesign.subtitleText
        case .low: LowTasksDesign.subtitleText
        case .standard: Color.black.opacity(locked ? 0.48 : 0.55)
        }
    }

    private var iconStroke: Color {
        switch layout {
        case .low: LowTasksDesign.accentPurple
        case .good, .normal, .rough, .standard: Color.black.opacity(0.88)
        }
    }

    private var pencilColor: Color {
        switch layout {
        case .low: LowTasksDesign.accentPurple.opacity(isCompleted ? 0.25 : 0.65)
        case .good, .normal, .rough, .standard: Color.black.opacity(isCompleted ? 0.25 : 0.55)
        }
    }

    private var checkboxSize: CGFloat { isPrototypeLayout ? 36 : 32 }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            leadingIcon

            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(titleColor)
                    .strikethrough(isCompleted && !locked, color: .black.opacity(0.35))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(displaySubtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(subtitleColor)
                    .strikethrough(isCompleted && !locked, color: .black.opacity(0.3))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !locked {
                Image(systemName: "pencil")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(pencilColor)
                    .frame(width: 26)
            }
        }
        .padding(.horizontal, isPrototypeLayout ? 18 : 16)
        .padding(.vertical, isPrototypeLayout ? 18 : 16)
        .frame(minHeight: isPrototypeLayout ? 76 : 0)
        .background(cardFill)
        .clipShape(RoundedRectangle(cornerRadius: isPrototypeLayout ? 18 : 16, style: .continuous))
        .opacity(isCompleted && !locked ? 0.65 : 1)
        .animation(.easeInOut(duration: 0.22), value: isCompleted)
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if locked {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .strokeBorder(iconStroke, lineWidth: 2)
                    .frame(width: checkboxSize, height: checkboxSize)
                Image(systemName: "lock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(iconStroke)
            }
            .frame(width: checkboxSize)
        } else {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.white.opacity(isCompleted ? 0 : 1))
                        .frame(width: checkboxSize, height: checkboxSize)

                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .strokeBorder(iconStroke, lineWidth: 2)
                        .frame(width: checkboxSize, height: checkboxSize)

                    if isCompleted {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(iconStroke.opacity(0.65))
                            .frame(width: checkboxSize, height: checkboxSize)
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview("Rough") {
    let blueprint = BlueprintState()
    blueprint.selectedMood = .rough
    blueprint.selectedLifeArea = .freedomFlexibility
    blueprint.selectedGap = .burnout
    return TasksView(currentStep: .constant(.tasks), blueprint: blueprint)
}

#Preview("Normal") {
    let blueprint = BlueprintState()
    blueprint.selectedMood = .normal
    blueprint.selectedLifeArea = .healthEnergy
    blueprint.selectedGap = .lowConsistency
    return TasksView(currentStep: .constant(.tasks), blueprint: blueprint)
}

#Preview("Low") {
    let blueprint = BlueprintState()
    blueprint.selectedMood = .low
    blueprint.selectedLifeArea = .freedomFlexibility
    blueprint.selectedGap = .burnout
    return TasksView(currentStep: .constant(.tasks), blueprint: blueprint)
}

#Preview("Good") {
    let blueprint = BlueprintState()
    blueprint.selectedMood = .good
    blueprint.selectedLifeArea = .growthLearning
    blueprint.selectedGap = .lowConsistency
    return TasksView(currentStep: .constant(.tasks), blueprint: blueprint)
}
