import SwiftUI

// MARK: - Canvas model

struct GoalCategory: Identifiable {
    let id = UUID()
    let title: String
    let completed: Int
    let total: Int
    let color: Color
    let height: CGFloat
}

struct CanvasView: View {
    @Binding var currentStep: AppStep
    @ObservedObject var blueprint: BlueprintState

    @AppStorage("hasSeenCanvasWelcome") private var hasSeenCanvasWelcome = false
    @State private var showWelcomeOverlay = false
    @State private var showMoodOverlay = false
    @State private var pendingMood: CanvasMood?
    @State private var userSkippedMoodPrompt = false

    private let userName = "Jaju"

    let leftCategories = [
        GoalCategory(title: "Relationships", completed: 1, total: 5, color: Color(hue: 0.75, saturation: 0.3, brightness: 0.9), height: 140),
        GoalCategory(title: "Health & Energy", completed: 3, total: 6, color: Color(hue: 0.52, saturation: 0.3, brightness: 0.95), height: 180),
    ]

    let rightCategories = [
        GoalCategory(title: "Freedom & Flexibility", completed: 3, total: 5, color: Color(hue: 0.95, saturation: 0.3, brightness: 0.98), height: 180),
        GoalCategory(title: "Growth & Learning", completed: 2, total: 5, color: Color(hue: 0.12, saturation: 0.5, brightness: 0.98), height: 140),
    ]

    var body: some View {
        GeometryReader { geo in
            let scrollTail = HubChromeMetrics.canvasScrollBottomInset(
                safeAreaBottom: geo.safeAreaInsets.bottom
            )

            ZStack {
                Color(hue: 0.08, saturation: 0.05, brightness: 0.98)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 10) {
                        if let mood = blueprint.selectedMood {
                            HStack {
                                Spacer(minLength: 0)
                                canvasMoodChip(mood: mood)
                            }
                            .padding(.horizontal, 24)
                        }

                        VStack(alignment: .center, spacing: 8) {
                            Text("Your Canvas")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hue: 0.12, saturation: 0.6, brightness: 0.98))

                            Text("Good morning, \(userName)")
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, 48)
                    }
                    .padding(.top, max(geo.safeAreaInsets.top, 12) + 8)

                    HStack(alignment: .center) {
                        CanvasProgressBadge(completed: 7, total: 20)

                        Spacer()

                        Text("Design a life that feels like you")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 16) {
                                VStack(spacing: 16) {
                                    ForEach(leftCategories) { category in
                                        CategoryCard(category: category)
                                            .contentShape(RoundedRectangle(cornerRadius: 16))
                                            .onTapGesture {
                                                selectLifeArea(from: category.title)
                                            }
                                    }
                                }

                                VStack(spacing: 16) {
                                    ForEach(rightCategories) { category in
                                        CategoryCard(category: category)
                                            .contentShape(RoundedRectangle(cornerRadius: 16))
                                            .onTapGesture {
                                                selectLifeArea(from: category.title)
                                            }
                                    }
                                }
                            }

                            CategoryCard(category: GoalCategory(title: "Financial Security", completed: 3, total: 6, color: Color(hue: 0.98, saturation: 0.4, brightness: 0.98), height: 120))
                                .contentShape(RoundedRectangle(cornerRadius: 16))
                                .onTapGesture {
                                    selectLifeArea(from: "Financial Security")
                                }

                            Text("My task for today")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.top, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    TaskCard(title: "Book that trip", color: Color(hue: 0.12, saturation: 0.5, brightness: 0.98))
                                    TaskCard(title: "Join a hiking club", color: Color(hue: 0.98, saturation: 0.3, brightness: 0.95))
                                    TaskCard(title: "Plan a getaway", color: Color(hue: 0.75, saturation: 0.2, brightness: 0.9))
                                }
                                .padding(.vertical, 4)
                            }

                            Color.clear.frame(height: scrollTail)
                        }
                        .padding(24)
                        .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)

                if showWelcomeOverlay {
                CanvasWelcomeOverlay(userName: userName) {
                    dismissWelcomeAndStartCanvas()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .center)))
                .zIndex(60_000)
            }

            if showMoodOverlay, !showWelcomeOverlay {
                MoodCheckInOverlay(
                    pendingMood: $pendingMood,
                    onClose: {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                            userSkippedMoodPrompt = true
                            showMoodOverlay = false
                            pendingMood = nil
                        }
                    },
                    onContinue: {
                        guard let mood = pendingMood else { return }
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                            blueprint.selectedMood = mood
                            showMoodOverlay = false
                            pendingMood = nil
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .center)))
                .zIndex(50_000)
                }
            }
        }
        .onAppear {
            presentWelcomeOrMoodCheckIn()
        }
    }

    private func presentWelcomeOrMoodCheckIn() {
        showMoodOverlay = false

        if blueprint.shouldPresentCanvasWelcome || !hasSeenCanvasWelcome {
            blueprint.shouldPresentCanvasWelcome = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                showWelcomeOverlay = true
            }
            return
        }

        scheduleMoodCheckInIfNeeded()
    }

    private func dismissWelcomeAndStartCanvas() {
        hasSeenCanvasWelcome = true
        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
            showWelcomeOverlay = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            scheduleMoodCheckInIfNeeded()
        }
    }

    private func scheduleMoodCheckInIfNeeded() {
        guard !showWelcomeOverlay else { return }
        guard blueprint.selectedMood == nil, !userSkippedMoodPrompt else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            guard !showWelcomeOverlay, blueprint.selectedMood == nil, !userSkippedMoodPrompt else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                showMoodOverlay = true
            }
        }
    }

    private func selectLifeArea(from canvasTitle: String) {
        if let area = LifeArea.from(canvasTitle: canvasTitle) {
            blueprint.selectedLifeArea = area
        }
        withAnimation {
            currentStep = .gap
        }
    }

    /// Compact mood pill — smaller than Tasks/Gap so it does not cover the title.
    private func canvasMoodChip(mood: CanvasMood) -> some View {
        HStack(spacing: 4) {
            MoodAssetIcon(mood: mood, height: 14, maxWidth: 38)
            Text(mood.title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.black.opacity(0.65))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(mood.chipBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.65), lineWidth: 0.5)
        )
    }
}

struct CategoryCard: View {
    let category: GoalCategory

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(category.color)

            VStack(alignment: .leading, spacing: 0) {
                Text(category.title)
                    .font(CanvasTypography.lifeAreaTitle())
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)

                Spacer()

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        ForEach(0..<category.total, id: \.self) { index in
                            Circle()
                                .fill(index < category.completed ? Color.black.opacity(0.5) : Color.black.opacity(0.15))
                                .frame(width: 8, height: 8)
                        }
                    }
                    Text("\(category.completed)/\(category.total) goals")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.black.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.12), radius: 0, x: 0, y: 1)
                .padding(.trailing, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, minHeight: category.height)
    }
}

struct TaskCard: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(.black.opacity(0.8))
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(width: 140, alignment: .leading)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CanvasView(currentStep: .constant(.canvas), blueprint: BlueprintState())
}
