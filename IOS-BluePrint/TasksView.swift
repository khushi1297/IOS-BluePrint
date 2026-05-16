import SwiftUI

private enum TasksPalette {
    static let canvas = Color(red: 0.98, green: 0.96, blue: 0.95)
    static let titleYellow = Color(hue: 0.12, saturation: 0.55, brightness: 0.95)
    static let cardOpen = Color(red: 1.0, green: 0.55, blue: 0.52)
    static let cardLocked = Color(red: 0.94, green: 0.92, blue: 0.88)
}

private struct TodayTask: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var subtitle: String
    var isCompleted: Bool
}

struct TasksView: View {
    @Binding var currentStep: AppStep

    /// First three tasks must all be completed before any task at index ≥ 3 unlocks (“keep 3 open” gate).
    private let openGroupSize = 3

    @State private var moodLabel: String = "Rough"
    @State private var moodEmoji: String = "😣"

    @State private var tasks: [TodayTask] = [
        TodayTask(title: "Reply to 1 important email", subtitle: "Instead of clearing your inbox", isCompleted: false),
        TodayTask(title: "Walk for 10 minutes", subtitle: "A lighter version of workout", isCompleted: false),
        TodayTask(title: "Review portfolio", subtitle: "Deep-research work session", isCompleted: false),
        TodayTask(title: "Book the Perth trip", subtitle: "View the website that have cheaper tickets", isCompleted: false),
        TodayTask(title: "Work on big goal (2hrs)", subtitle: "Saved for better energy days", isCompleted: false),
    ]

    private var firstOpenGroupComplete: Bool {
        guard tasks.count >= openGroupSize else { return tasks.allSatisfy(\.isCompleted) }
        return tasks.prefix(openGroupSize).allSatisfy(\.isCompleted)
    }

    private func isLocked(index: Int) -> Bool {
        index >= openGroupSize && !firstOpenGroupComplete
    }

    var body: some View {
        ZStack {
            TasksPalette.canvas
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                            let locked = isLocked(index: index)
                            TodayTaskRow(
                                task: task,
                                locked: locked,
                                accent: TasksPalette.cardOpen
                            ) {
                                toggleTask(id: task.id, locked: locked)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                footerChrome
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("Today's task")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(TasksPalette.titleYellow)

                Spacer(minLength: 8)

                Button {
                    // Placeholder — hook mood sheet later
                } label: {
                    Text("Change mood ›")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Text(moodEmoji)
                        .font(.system(size: 16))
                    Text(moodLabel)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.65))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(red: 1.0, green: 0.88, blue: 0.9).opacity(0.95))
                .clipShape(Capsule())

                Spacer()
            }

            Text(moodTagline)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .italic()
        }
    }

    private var moodTagline: String {
        switch moodLabel {
        case "Rough": return "Rough days count too. Be easy on yourself."
        case "Low": return "Small steps still move you forward."
        case "Normal": return "Steady is enough today."
        case "Good": return "You’ve got room to stretch a little."
        default: return "Be kind to yourself today."
        }
    }

    private var footerChrome: some View {
        VStack(spacing: 12) {
            Text("Check off the task as you go.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .italic()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

            Button {
                withAnimation { currentStep = .tinyWin }
            } label: {
                Text("Continue")
            }
            .buttonStyle(BlueprintPrimaryCapsuleButtonStyle())
            .padding(.horizontal, 48)

            BlueprintBottomNavBar(currentStep: $currentStep)
        }
        .padding(.top, 8)
        .padding(.bottom, 28)
    }

    private func toggleTask(id: UUID, locked: Bool) {
        guard !locked else { return }
        guard let i = tasks.firstIndex(where: { $0.id == id }) else { return }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            tasks[i].isCompleted.toggle()
        }
    }
}

private struct TodayTaskRow: View {
    let task: TodayTask
    let locked: Bool
    let accent: Color
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.black.opacity(locked ? 0.12 : 0.35), lineWidth: 2)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(task.isCompleted ? Color.black.opacity(0.55) : Color.clear)
                        )

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(locked)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(locked ? 0.35 : 0.88))
                    .strikethrough(task.isCompleted, color: .black.opacity(0.35))
                    .multilineTextAlignment(.leading)

                Text(task.subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(locked ? Color.black.opacity(0.28) : Color.black.opacity(0.55))
                    .strikethrough(task.isCompleted, color: .black.opacity(0.3))
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.35))
                } else {
                    Image(systemName: "pencil")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black.opacity(task.isCompleted ? 0.25 : 0.55))
                }
            }
            .frame(width: 28)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .opacity(task.isCompleted ? 0.58 : 1)
        .animation(.easeInOut(duration: 0.22), value: task.isCompleted)
    }

    private var rowBackground: Color {
        if locked { return TasksPalette.cardLocked }
        return accent.opacity(0.92)
    }
}

#Preview {
    TasksView(currentStep: .constant(.tasks))
}
