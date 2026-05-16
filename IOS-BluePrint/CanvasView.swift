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

    @State private var showMoodOverlay = false
    @State private var pendingMood: CanvasMood?
    @State private var userSkippedMoodPrompt = false

    let leftCategories = [
        GoalCategory(title: "Relationships", completed: 1, total: 5, color: Color(hue: 0.75, saturation: 0.3, brightness: 0.9), height: 140),
        GoalCategory(title: "Health &\nEnergy", completed: 3, total: 6, color: Color(hue: 0.52, saturation: 0.3, brightness: 0.95), height: 180),
    ]

    let rightCategories = [
        GoalCategory(title: "Freedom &\nFlexibility", completed: 3, total: 5, color: Color(hue: 0.95, saturation: 0.3, brightness: 0.98), height: 180),
        GoalCategory(title: "Growth &\nLearning", completed: 2, total: 5, color: Color(hue: 0.12, saturation: 0.5, brightness: 0.98), height: 140),
    ]

    var body: some View {
        ZStack {
            Color(hue: 0.08, saturation: 0.05, brightness: 0.98)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .center, spacing: 8) {
                        Text("Your Canvas")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hue: 0.12, saturation: 0.6, brightness: 0.98))

                        Text("Good morning, Jaju")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    if let mood = blueprint.selectedMood {
                        HStack(spacing: 6) {
                            Text(mood.emoji)
                                .font(.system(size: 16))
                            Text(mood.title)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(.black.opacity(0.65))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(mood.chipBackground)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.65), lineWidth: 0.5)
                        )
                        .padding(.trailing, 8)
                    }
                }
                .padding(.top, 20)

                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .strokeBorder(Color(hue: 0.75, saturation: 0.4, brightness: 0.8), lineWidth: 2)
                            .frame(width: 12, height: 12)

                        Text("7 of 20 steps")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.black.opacity(0.6))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hue: 0.75, saturation: 0.2, brightness: 0.9))
                    .clipShape(Capsule())

                    Spacer()

                    Text("Design a life that feels like you")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                ScrollView {
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

                        Color.clear.frame(height: 100)
                    }
                    .padding(24)
                }

                    BlueprintBottomNavBar(currentStep: $currentStep, horizontalInset: 24)
                        .padding(.bottom, 10)
            }

            VStack {
                Spacer()
                Button {
                    withAnimation {
                        currentStep = .gap
                    }
                } label: {
                    Text("Continue")
                }
                .buttonStyle(BlueprintPrimaryCapsuleButtonStyle())
                .padding(.horizontal, 60)
                .padding(.bottom, 90)
            }

            if showMoodOverlay {
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
        .onAppear {
            guard blueprint.selectedMood == nil, !userSkippedMoodPrompt else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    showMoodOverlay = true
                }
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
}

struct CategoryCard: View {
    let category: GoalCategory

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(category.color)

            VStack(alignment: .leading, spacing: 0) {
                Text(category.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
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
