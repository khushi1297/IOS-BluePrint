import SwiftUI

// MARK: - Mood (canvas check-in)

enum CanvasMood: String, CaseIterable, Identifiable {
    case good
    case normal
    case low
    case rough

    var id: String { rawValue }

    var title: String {
        switch self {
        case .good: "Good"
        case .normal: "Normal"
        case .low: "Low"
        case .rough: "Rough"
        }
    }

    var caption: String {
        switch self {
        case .good: "Do a little more"
        case .normal: "Steady peace"
        case .low: "Keep it low"
        case .rough: "Make it gentle"
        }
    }

    var emoji: String {
        switch self {
        case .good: "😊"
        case .normal: "😐"
        case .low: "😕"
        case .rough: "😣"
        }
    }

    /// Card tint in the picker grid.
    var pickerTint: Color {
        switch self {
        case .good:
            Color(red: 1.0, green: 0.92, blue: 0.55)
        case .normal:
            Color(red: 0.78, green: 0.9, blue: 0.98)
        case .low:
            Color(red: 0.88, green: 0.84, blue: 0.98)
        case .rough:
            Color(red: 1.0, green: 0.82, blue: 0.78)
        }
    }

    /// Header chip background once selected.
    var chipBackground: Color {
        switch self {
        case .good:
            Color(red: 1.0, green: 0.92, blue: 0.72)
        case .normal:
            Color(red: 0.82, green: 0.92, blue: 1.0)
        case .low:
            Color(red: 0.9, green: 0.86, blue: 1.0)
        case .rough:
            Color(red: 1.0, green: 0.78, blue: 0.82)
        }
    }
}

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

    @State private var showMoodOverlay = false
    @State private var pendingMood: CanvasMood?
    @State private var selectedMood: CanvasMood?
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

                    if let mood = selectedMood {
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
                                            withAnimation {
                                                currentStep = .gap
                                            }
                                        }
                                }
                            }

                            VStack(spacing: 16) {
                                ForEach(rightCategories) { category in
                                    CategoryCard(category: category)
                                        .contentShape(RoundedRectangle(cornerRadius: 16))
                                        .onTapGesture {
                                            withAnimation {
                                                currentStep = .gap
                                            }
                                        }
                                }
                            }
                        }

                        CategoryCard(category: GoalCategory(title: "Financial Security", completed: 3, total: 6, color: Color(hue: 0.98, saturation: 0.4, brightness: 0.98), height: 120))
                            .contentShape(RoundedRectangle(cornerRadius: 16))
                            .onTapGesture {
                                withAnimation {
                                    currentStep = .gap
                                }
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
                CanvasMoodCheckInOverlay(
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
                            selectedMood = mood
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
            guard selectedMood == nil, !userSkippedMoodPrompt else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                    showMoodOverlay = true
                }
            }
        }
    }
}

// MARK: - Mood overlay

private struct CanvasMoodCheckInOverlay: View {
    @Binding var pendingMood: CanvasMood?
    let onClose: () -> Void
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.38)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(10)
                            .background(Color.black.opacity(0.06))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)

                Text("How are you feeling today?")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(.black.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                Text("We'll adjust your tasks to match your day.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(CanvasMood.allCases) { mood in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                pendingMood = mood
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(mood.emoji)
                                    .font(.system(size: 36))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(mood.title)
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundStyle(.black.opacity(0.85))

                                Text(mood.caption)
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(mood.pickerTint)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(
                                        pendingMood == mood ? Color(hue: 0.75, saturation: 0.45, brightness: 0.55) : Color.clear,
                                        lineWidth: 2.5
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)

                Button(action: onContinue) {
                    Text("Continue")
                }
                .buttonStyle(BlueprintPrimaryCapsuleButtonStyle(isEnabled: pendingMood != nil))
                .opacity(pendingMood == nil ? 0.45 : 1)
                .disabled(pendingMood == nil)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.99, green: 0.99, blue: 0.99))
            )
            .shadow(color: .black.opacity(0.18), radius: 28, y: 16)
            .padding(.horizontal, 24)
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
    CanvasView(currentStep: .constant(.canvas))
}
