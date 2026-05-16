import SwiftUI

private enum TasksPalette {
    static let canvas = Color(red: 0.99, green: 0.98, blue: 0.97)
    static let titleYellow = Color(red: 1.0, green: 0.74, blue: 0.17)
}

struct TasksView: View {
    @Binding var currentStep: AppStep
    @ObservedObject var blueprint: BlueprintState

    @State private var pageContent: TaskPageContent?
    @State private var generationKey: String = ""
    @State private var showMoodOverlay = false
    @State private var pendingMood: CanvasMood?

    private var mood: CanvasMood? { blueprint.selectedMood }
    private var cardFill: Color { mood?.tasksCardFill ?? Color(red: 1.0, green: 0.36, blue: 0.40) }
    private var ctaTint: Color { mood?.tasksChipBackground ?? Color(red: 1.0, green: 0.82, blue: 0.84) }

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
        if pageContent.mood == .rough {
            return tasksDone
        }
        return isFlowComplete && tasksDone
    }

    var body: some View {
        ZStack {
            TasksPalette.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 14) {
                        if !isFlowComplete, mood != .rough {
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
                                    cardFill: cardFill
                                ) {
                                    toggleTask(task, locked: locked)
                                }
                            }
                        } else if mood == nil {
                            setMoodBanner
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                footerChrome
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

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
        .onAppear { refreshPageContent(force: false) }
        .onChange(of: blueprint.selectedMood) { _, _ in refreshPageContent(force: true) }
        .onChange(of: blueprint.selectedLifeArea) { _, _ in refreshPageContent(force: true) }
        .onChange(of: blueprint.selectedGap) { _, _ in refreshPageContent(force: true) }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 14) {
            Text("Today's task")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(TasksPalette.titleYellow)
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
                        .foregroundStyle(Color(white: 0.45))
                }
                .buttonStyle(.plain)
            }
            .padding(.trailing, mood == .rough ? 44 : 8)

            Text(supportiveSentence)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color(white: 0.32))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var moodChip: some View {
        if let mood {
            HStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 15))
                    .frame(width: 22, height: 22)
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(mood == .rough ? Color(red: 0.95, green: 0.55, blue: 0.58) : mood.tasksChipBackground)
                    )

                Text(mood.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        (mood == .rough || mood == .good)
                            ? Color.black.opacity(0.88)
                            : mood.tasksChipLabelColor
                    )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(mood.tasksChipBackground)
            .clipShape(Capsule())
        } else {
            Text("Set mood")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(red: 1.0, green: 0.82, blue: 0.84))
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
                            .background(Color(red: 1.0, green: 0.82, blue: 0.84))
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
                            .background(Color(red: 1.0, green: 0.82, blue: 0.84))
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

    // MARK: - Footer

    private var footerChrome: some View {
        VStack(spacing: 12) {
            Text(helperText)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(Color(white: 0.5))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

            Button {
                withAnimation { currentStep = .tinyWin }
            } label: {
                Text(ctaTitle)
                    .font(BlueprintPrimaryButton.titleFont)
                    .foregroundStyle(Color.black.opacity(canProceed ? 0.82 : 0.38))
            }
            .buttonStyle(LiquidGlassCapsuleButtonStyle(tint: ctaTint))
            .disabled(!canProceed)
            .opacity(canProceed ? 1 : 0.5)
            .padding(.horizontal, 48)

            BlueprintBottomNavBar(currentStep: $currentStep)
        }
        .padding(.top, 8)
        .padding(.bottom, 28)
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

// MARK: - Task row

private struct TodayTaskRow: View {
    let task: DailyTask
    let displaySubtitle: String
    let locked: Bool
    let isCompleted: Bool
    let cardFill: Color
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            leadingIcon

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(locked ? 0.82 : 0.9))
                    .strikethrough(isCompleted && !locked, color: .black.opacity(0.35))
                    .multilineTextAlignment(.leading)

                Text(displaySubtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(locked ? 0.48 : 0.55))
                    .strikethrough(isCompleted && !locked, color: .black.opacity(0.3))
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !locked {
                Image(systemName: "pencil")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.black.opacity(isCompleted ? 0.25 : 0.55))
                    .frame(width: 28)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(cardFill)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .opacity(isCompleted && !locked ? 0.62 : 1)
        .animation(.easeInOut(duration: 0.22), value: isCompleted)
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if locked {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.35), lineWidth: 2)
                    .frame(width: 32, height: 32)
                Image(systemName: "lock.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.45))
            }
            .frame(width: 32)
        } else {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(isCompleted ? 0 : 0.92))
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.35), lineWidth: 2)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isCompleted ? Color.black.opacity(0.55) : Color.clear)
                        )

                    if isCompleted {
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

#Preview("Good") {
    let blueprint = BlueprintState()
    blueprint.selectedMood = .good
    blueprint.selectedLifeArea = .growthLearning
    blueprint.selectedGap = .lowConsistency
    return TasksView(currentStep: .constant(.tasks), blueprint: blueprint)
}
