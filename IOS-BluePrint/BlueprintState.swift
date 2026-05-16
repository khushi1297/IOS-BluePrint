import SwiftUI
import Combine

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
        case .normal: "Steady pace"
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

    // MARK: Tasks page styling

    var tasksTagline: String {
        switch self {
        case .rough: "Rough days count too. Be easy on yourself"
        case .low: "Small steps still move you forward"
        case .normal: "Steady is enough today"
        case .good: "You have energy today. Let's rock it"
        }
    }

    var tasksChipBackground: Color {
        switch self {
        case .rough:
            Color(red: 1.0, green: 0.82, blue: 0.84) // #FFD1D5
        case .low:
            Color(red: 0.92, green: 0.86, blue: 0.98)
        case .normal:
            Color(red: 0.85, green: 0.93, blue: 1.0)
        case .good:
            Color(red: 1.0, green: 0.93, blue: 0.62)
        }
    }

    var tasksChipLabelColor: Color {
        switch self {
        case .rough:
            Color.black.opacity(0.88)
        case .low:
            Color(red: 0.35, green: 0.22, blue: 0.55)
        case .normal:
            Color(red: 0.15, green: 0.35, blue: 0.55)
        case .good:
            Color.black.opacity(0.88)
        }
    }

    /// Active + locked task cards on the tasks screen.
    var tasksCardFill: Color {
        switch self {
        case .good:
            Color(red: 1.0, green: 0.84, blue: 0.32) // bright yellow / gold
        case .normal:
            Color(red: 0.45, green: 0.78, blue: 0.95) // aqua / blue
        case .low:
            Color(red: 0.72, green: 0.58, blue: 0.95) // lavender / purple
        case .rough:
            Color(red: 1.0, green: 0.35, blue: 0.37) // coral #FF5A5F
        }
    }

    var tasksHelperText: String {
        switch self {
        case .good:
            "Check off the task as you go"
        case .normal:
            "Check off the task as you go"
        case .low:
            "Only one required today — optional tasks are extra"
        case .rough:
            "Check off the task as you go"
        }
    }

    /// Label on the Tasks screen primary button (Tiny Win copy stays mood-specific).
    var tasksCTATitle: String {
        switch self {
        case .good: "Continue"
        case .normal: "Continue to steady win"
        case .low: "Take a small win"
        case .rough: "Continue"
        }
    }

    /// Good / Rough task pages hide life-area / gap chips (prototype layout).
    var tasksShowsContextChips: Bool {
        switch self {
        case .good, .rough: false
        default: true
        }
    }

    var tinyWinHeadline: String {
        switch self {
        case .good: "Momentum win today."
        case .normal: "Steady win today."
        case .low: "Small win today."
        case .rough: "One tiny win today."
        }
    }

    var tinyWinBody: String {
        switch self {
        case .good:
            "You built real momentum. That energy is yours to keep."
        case .normal:
            "You stayed steady today. Consistency is the whole game."
        case .low:
            "You took a small win when it mattered. That counts."
        case .rough:
            "You showed up on a rough day. That's the whole thing."
        }
    }

    var tinyWinCardTitle: String {
        switch self {
        case .good: "Momentum adds up"
        case .normal: "Steady still moves you"
        case .low: "Small is still forward"
        case .rough: "Your progress isn't gone"
        }
    }

    var tinyWinCardBody: String {
        switch self {
        case .good:
            "Even a good day doesn't have to be perfect. What you finished today builds tomorrow."
        case .normal:
            "You don't need a spike of energy — showing up at a sustainable pace is enough."
        case .low:
            "On low days, one completed micro-action is a real win. Rest is part of the plan too."
        case .rough:
            "Even on the rough days, you're still moving forward. Every small thing you do adds up."
        }
    }
}

// MARK: - Life area (canvas card)

enum LifeArea: String, CaseIterable, Identifiable {
    case freedomFlexibility
    case healthEnergy
    case relationships
    case growthLearning
    case financialSecurity

    var id: String { rawValue }

    var title: String {
        switch self {
        case .freedomFlexibility: "Freedom & Flexibility"
        case .healthEnergy: "Health & Energy"
        case .relationships: "Relationships"
        case .growthLearning: "Growth & Learning"
        case .financialSecurity: "Financial Security"
        }
    }

    static func from(canvasTitle: String) -> LifeArea? {
        let normalized = canvasTitle
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespaces)
        return allCases.first { $0.title == normalized }
    }
}

// MARK: - Gap / blocker (gap page)

enum GapBlocker: String, CaseIterable, Identifiable {
    case noTimeOff
    case burnout
    case financialPressure
    case lowConsistency
    case unsupportiveEnvironment

    var id: String { rawValue }

    var listTitle: String {
        switch self {
        case .noTimeOff:
            "No paid leave / can't take time off"
        case .burnout:
            "Daily burnout and lack of recovery"
        case .financialPressure:
            "Money pressure on every spare dollar"
        case .lowConsistency:
            "Hard to stay consistent when I'm low"
        case .unsupportiveEnvironment:
            "My environment doesn't support this yet"
        }
    }
}

// MARK: - Shared app state

@MainActor
final class BlueprintState: ObservableObject {
    @Published var selectedMood: CanvasMood?
    @Published var selectedLifeArea: LifeArea?
    @Published var selectedGap: GapBlocker?
    @Published var completedTaskIDs: Set<UUID> = []

    var isReadyForTasks: Bool {
        selectedMood != nil && selectedLifeArea != nil && selectedGap != nil
    }

    var taskGenerationKey: String? {
        guard let mood = selectedMood,
              let area = selectedLifeArea,
              let gap = selectedGap else { return nil }
        return "\(mood.rawValue)|\(area.rawValue)|\(gap.rawValue)"
    }

    func toggleTaskCompleted(_ id: UUID) {
        if completedTaskIDs.contains(id) {
            completedTaskIDs.remove(id)
        } else {
            completedTaskIDs.insert(id)
        }
    }

    func isTaskCompleted(_ id: UUID) -> Bool {
        completedTaskIDs.contains(id)
    }
}

// MARK: - Mood check-in overlay (Canvas + Tasks)

struct MoodCheckInOverlay: View {
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

// MARK: - Stable task IDs (persist completion across regenerations)

enum TaskIdentity {
    static func id(generationKey: String, index: Int) -> UUID {
        var bytes = [UInt8](repeating: 0, count: 16)
        let seed = "\(generationKey)|\(index)"
        for (offset, byte) in seed.utf8.enumerated() {
            bytes[offset % 16] = bytes[offset % 16] &+ byte
        }
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
