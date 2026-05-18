import Foundation

// MARK: - Models

typealias Mood = CanvasMood

enum DailyTaskRole: Equatable {
    case active
    case optional
    case lockedUntilActiveComplete(unlockAfter: Int)
    case bonusUntilActiveComplete(unlockAfter: Int)
    case permanentlyLocked

    var countsTowardRequired: Bool {
        if case .active = self { return true }
        return false
    }
}

struct DailyTask: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let lockedSubtitle: String
    let role: DailyTaskRole
}

struct TaskPageContent: Equatable {
    let mood: Mood
    let lifeArea: LifeArea
    let gap: GapBlocker
    let tasks: [DailyTask]
    let supportiveSentence: String
    let helperText: String
    let ctaTitle: String
    let requiredActiveCompletions: Int

    func isLocked(_ task: DailyTask, completedIDs: Set<UUID>) -> Bool {
        switch task.role {
        case .active, .optional:
            return false
        case .permanentlyLocked:
            return true
        case .lockedUntilActiveComplete(let threshold), .bonusUntilActiveComplete(let threshold):
            return unlockCompletionCount(completedIDs: completedIDs) < threshold
        }
    }

    func displaySubtitle(for task: DailyTask, completedIDs: Set<UUID>) -> String {
        if isLocked(task, completedIDs: completedIDs) {
            return task.lockedSubtitle
        }
        if task.role == .optional {
            return "\(task.subtitle) (optional)"
        }
        return task.subtitle
    }

    func canProceed(completedIDs: Set<UUID>) -> Bool {
        activeCompletedCount(completedIDs: completedIDs) >= requiredActiveCompletions
    }

    private func activeCompletedCount(completedIDs: Set<UUID>) -> Int {
        tasks
            .filter(\.role.countsTowardRequired)
            .filter { completedIDs.contains($0.id) }
            .count
    }

    /// Completed tasks that count toward progressive unlocks (active + unlocked steps).
    private func unlockCompletionCount(completedIDs: Set<UUID>) -> Int {
        tasks.filter { task in
            if case .permanentlyLocked = task.role { return false }
            return completedIDs.contains(task.id)
        }.count
    }
}

// MARK: - Generator

/// Builds mood-adaptive micro-actions from mood + life area + gap (deterministic, not random).
enum DailyTaskGenerator {

    static func makePageContent(
        mood: Mood,
        lifeArea: LifeArea,
        gap: GapBlocker,
        generationKey: String
    ) -> TaskPageContent {
        let pool = coreTasks(lifeArea: lifeArea, blocker: gap).map {
            TaskPair(
                title: $0.title,
                subtitle: moodAdjustedSubtitle($0.subtitle, mood: mood)
            )
        }
        let tasks = assembleTasks(from: pool, mood: mood, generationKey: generationKey)

        return TaskPageContent(
            mood: mood,
            lifeArea: lifeArea,
            gap: gap,
            tasks: tasks,
            supportiveSentence: mood.tasksTagline,
            helperText: mood.tasksHelperText,
            ctaTitle: mood.tasksCTATitle,
            requiredActiveCompletions: requiredCompletions(for: mood)
        )
    }

    // MARK: - Mood layout

    private static func requiredCompletions(for mood: Mood) -> Int {
        switch mood {
        case .good, .normal: return 3
        case .low, .rough: return 1
        }
    }

    private static func assembleTasks(from pool: [TaskPair], mood: Mood, generationKey: String) -> [DailyTask] {
        func task(at index: Int, role: DailyTaskRole, lockedSubtitle: String) -> DailyTask {
            let pair = pool[min(index, pool.count - 1)]
            return DailyTask(
                id: TaskIdentity.id(generationKey: generationKey, index: index),
                title: pair.title,
                subtitle: pair.subtitle,
                lockedSubtitle: lockedSubtitle,
                role: role
            )
        }

        switch mood {
        case .good:
            return goodReferenceTasks(generationKey: generationKey)
        case .normal:
            return normalReferenceTasks(generationKey: generationKey)
        case .low:
            return lowReferenceTasks(generationKey: generationKey)
        case .rough:
            return roughReferenceTasks(generationKey: generationKey)
        }
    }

    /// Normal mood screen — fixed prototype copy (3 active + 2 progressive unlocks).
    private static func normalReferenceTasks(generationKey: String) -> [DailyTask] {
        func row(
            _ index: Int,
            title: String,
            subtitle: String,
            role: DailyTaskRole,
            lockedSubtitle: String = ""
        ) -> DailyTask {
            DailyTask(
                id: TaskIdentity.id(generationKey: generationKey, index: index),
                title: title,
                subtitle: subtitle,
                lockedSubtitle: lockedSubtitle,
                role: role
            )
        }

        return [
            row(0, title: "Choose one recipe to cook", subtitle: "Focus on making the food taste good", role: .active),
            row(1, title: "Spend 10 mins on meditation", subtitle: "Take slow breaths", role: .active),
            row(2, title: "Remove one small blocker", subtitle: "Make tomorrow easier", role: .active),
            row(
                3,
                title: "Plan the next step",
                subtitle: "Map one small move for tomorrow",
                role: .lockedUntilActiveComplete(unlockAfter: 3),
                lockedSubtitle: "Unlocks after 3 tasks"
            ),
            row(
                4,
                title: "Book the Perth trip",
                subtitle: "Lock in dates when you're ready",
                role: .lockedUntilActiveComplete(unlockAfter: 4),
                lockedSubtitle: "Unlocks after 4 tasks"
            ),
        ]
    }

    /// Good mood screen — fixed prototype copy (3 active + 2 unlock after 3 wins).
    private static func goodReferenceTasks(generationKey: String) -> [DailyTask] {
        func row(
            _ index: Int,
            title: String,
            subtitle: String,
            role: DailyTaskRole,
            lockedSubtitle: String = ""
        ) -> DailyTask {
            DailyTask(
                id: TaskIdentity.id(generationKey: generationKey, index: index),
                title: title,
                subtitle: subtitle,
                lockedSubtitle: lockedSubtitle,
                role: role
            )
        }

        return [
            row(0, title: "Start a pottery workshop", subtitle: "Pick the thing that moves you forward", role: .active),
            row(1, title: "Spend 30 mins in the library", subtitle: "Use your energy with focus", role: .active),
            row(2, title: "Do one brave follow-up", subtitle: "Message, book, apply, ask or decide", role: .active),
            row(
                3,
                title: "Set up your next step",
                subtitle: "Make future-you's life easier",
                role: .lockedUntilActiveComplete(unlockAfter: 3),
                lockedSubtitle: "Make future-you's life easier"
            ),
            row(
                4,
                title: "Bonus stretch goal",
                subtitle: "Pick the thing that moves you forward",
                role: .bonusUntilActiveComplete(unlockAfter: 3),
                lockedSubtitle: "Saved for better energy days"
            ),
        ]
    }

    /// Low mood screen — fixed prototype copy (3 active + 2 locked).
    private static func lowReferenceTasks(generationKey: String) -> [DailyTask] {
        func row(
            _ index: Int,
            title: String,
            subtitle: String,
            role: DailyTaskRole,
            lockedSubtitle: String = ""
        ) -> DailyTask {
            DailyTask(
                id: TaskIdentity.id(generationKey: generationKey, index: index),
                title: title,
                subtitle: subtitle,
                lockedSubtitle: lockedSubtitle,
                role: role
            )
        }

        return [
            row(0, title: "Name what feels heavy", subtitle: "Write one sentence about what is in your mind", role: .active),
            row(1, title: "Do a 5-minute reset", subtitle: "Stretch, breathe, sit outside, drink water", role: .active),
            row(2, title: "Choose one easy next step", subtitle: "Deep-research work session", role: .active),
            row(
                3,
                title: "Plan a freedom block",
                subtitle: "",
                role: .permanentlyLocked,
                lockedSubtitle: "Create a 1-hour space for the work"
            ),
            row(
                4,
                title: "Work on big goal (2hrs)",
                subtitle: "",
                role: .permanentlyLocked,
                lockedSubtitle: "Saved for better energy days"
            ),
        ]
    }

    /// Rough mood screen — fixed prototype copy (3 active + 2 locked).
    private static func roughReferenceTasks(generationKey: String) -> [DailyTask] {
        func row(
            _ index: Int,
            title: String,
            subtitle: String,
            role: DailyTaskRole,
            lockedSubtitle: String = ""
        ) -> DailyTask {
            DailyTask(
                id: TaskIdentity.id(generationKey: generationKey, index: index),
                title: title,
                subtitle: subtitle,
                lockedSubtitle: lockedSubtitle,
                role: role
            )
        }

        return [
            row(0, title: "Reply to 1 important email", subtitle: "Instead of clearing your inbox", role: .active),
            row(1, title: "Walk for 10 minutes", subtitle: "No plan. Just change your environment", role: .active),
            row(2, title: "Review portfolio", subtitle: "Deep-research work session", role: .active),
            row(
                3,
                title: "Plan a full free day",
                subtitle: "",
                role: .permanentlyLocked,
                lockedSubtitle: "Saved for when your energy feels stronger"
            ),
            row(
                4,
                title: "Work on big goal (2hrs)",
                subtitle: "",
                role: .permanentlyLocked,
                lockedSubtitle: "Saved for better energy days"
            ),
        ]
    }

    private static func moodAdjustedSubtitle(_ base: String, mood: Mood) -> String {
        switch mood {
        case .good, .normal, .rough, .low:
            return base
        }
    }

    // MARK: - Task bank

    private struct TaskPair {
        let title: String
        let subtitle: String
    }

    private static func coreTasks(lifeArea: LifeArea, blocker: GapBlocker) -> [TaskPair] {
        switch (lifeArea, blocker) {

        // MARK: Freedom & Flexibility
        case (.freedomFlexibility, .noTimeOff):
            return [
                TaskPair(title: "Block 15 min on your calendar", subtitle: "Label it personal — no explanation needed"),
                TaskPair(title: "List one boundary for this week", subtitle: "One sentence, not a manifesto"),
                TaskPair(title: "Say no to one optional ask", subtitle: "Practice protecting a sliver of time"),
                TaskPair(title: "Draft a one-line out-of-office", subtitle: "For a future half-day, even if unused yet"),
                TaskPair(title: "Pick one freedom micro-goal", subtitle: "Something doable before your next shift"),
            ]
        case (.freedomFlexibility, .burnout):
            return [
                TaskPair(title: "Take a 10-minute screen break", subtitle: "No productivity during it"),
                TaskPair(title: "Choose one chore to drop today", subtitle: "Freedom starts with less, not more"),
                TaskPair(title: "Set a hard stop time tonight", subtitle: "Honor it like a meeting"),
                TaskPair(title: "Do one thing seated and slow", subtitle: "Tea, stretch, or window gaze"),
                TaskPair(title: "Text someone you're off early", subtitle: "Accountability without over-explaining"),
            ]
        case (.freedomFlexibility, .financialPressure):
            return [
                TaskPair(title: "Review one subscription", subtitle: "Keep, pause, or cancel — pick one"),
                TaskPair(title: "Move $5 to a buffer jar", subtitle: "Symbolic freedom fund"),
                TaskPair(title: "Find one free joy for the week", subtitle: "Walk, library, or park bench"),
                TaskPair(title: "Write one sentence about \"enough\"", subtitle: "What would enough look like this month?"),
                TaskPair(title: "Plan a no-spend evening", subtitle: "Flexibility without opening your wallet"),
            ]
        case (.freedomFlexibility, .lowConsistency):
            return [
                TaskPair(title: "Set a 5-minute timer", subtitle: "One freedom task only — then stop"),
                TaskPair(title: "Prep tomorrow's clothes", subtitle: "Reduce morning friction"),
                TaskPair(title: "Put one reminder on your phone", subtitle: "Same time daily for one micro-step"),
                TaskPair(title: "Celebrate yesterday's smallest win", subtitle: "Write it in Notes"),
                TaskPair(title: "Choose the easiest freedom task", subtitle: "Consistency beats intensity"),
            ]
        case (.freedomFlexibility, .unsupportiveEnvironment):
            return [
                TaskPair(title: "Name one ally you could ping", subtitle: "Even a single supportive person counts"),
                TaskPair(title: "Find a quiet corner for 10 min", subtitle: "Car, park, or headphones on"),
                TaskPair(title: "Write what you wish others understood", subtitle: "Don't send — just clarify for you"),
                TaskPair(title: "Save one article about flexible work", subtitle: "Fuel for a future conversation"),
                TaskPair(title: "Do one private freedom ritual", subtitle: "Journal, walk, or playlist — yours alone"),
            ]

        // MARK: Health & Energy
        case (.healthEnergy, .noTimeOff):
            return [
                TaskPair(title: "Drink a full glass of water", subtitle: "Before your next block of work"),
                TaskPair(title: "Stretch neck and shoulders 2 min", subtitle: "At your desk or counter"),
                TaskPair(title: "Eat one real snack", subtitle: "Not coffee-as-food"),
                TaskPair(title: "Walk to the mailbox or end of hall", subtitle: "Movement without a gym trip"),
                TaskPair(title: "Set a bedtime alarm", subtitle: "Protect tomorrow's energy"),
            ]
        case (.healthEnergy, .burnout):
            return [
                TaskPair(title: "Lie down 10 minutes eyes closed", subtitle: "Not sleep — just off"),
                TaskPair(title: "Eat something with protein", subtitle: "Stabilize blood sugar"),
                TaskPair(title: "Step outside for fresh air", subtitle: "Even 3 minutes counts"),
                TaskPair(title: "Turn off one notification category", subtitle: "Fewer pings, more recovery"),
                TaskPair(title: "Say \"I'm running low\" to one person", subtitle: "Naming it reduces shame"),
            ]
        case (.healthEnergy, .financialPressure):
            return [
                TaskPair(title: "Cook one simple meal at home", subtitle: "Rice, eggs, or frozen veg — no perfection"),
                TaskPair(title: "Take a free YouTube stretch", subtitle: "10 minutes, no equipment"),
                TaskPair(title: "Walk instead of one paid commute", subtitle: "If safe and realistic today"),
                TaskPair(title: "Refill your water bottle twice", subtitle: "Cheap energy support"),
                TaskPair(title: "Plan sleep before scrolling", subtitle: "Energy is a budget too"),
            ]
        case (.healthEnergy, .lowConsistency):
            return [
                TaskPair(title: "Do 5 squats or wall push-ups", subtitle: "Stop when the timer ends"),
                TaskPair(title: "Eat breakfast or lunch on time", subtitle: "Anchor the day with one meal"),
                TaskPair(title: "Track mood in one emoji", subtitle: "Notice patterns without judgment"),
                TaskPair(title: "Prep sneakers by the door", subtitle: "Lower friction for a later walk"),
                TaskPair(title: "Pick one health habit only today", subtitle: "Not the whole wellness overhaul"),
            ]
        case (.healthEnergy, .unsupportiveEnvironment):
            return [
                TaskPair(title: "Wear shoes that feel good", subtitle: "Small comfort you control"),
                TaskPair(title: "Open a window or step outside", subtitle: "Change the air around you"),
                TaskPair(title: "Listen to a calming track", subtitle: "Headphones as a mini sanctuary"),
                TaskPair(title: "Eat away from your stress zone", subtitle: "Different chair or room"),
                TaskPair(title: "Note one health win from this week", subtitle: "Your body did something right"),
            ]

        // MARK: Relationships
        case (.relationships, .noTimeOff):
            return [
                TaskPair(title: "Send one short check-in text", subtitle: "No call required"),
                TaskPair(title: "Voice-note a thank-you", subtitle: "30 seconds max"),
                TaskPair(title: "Schedule a 15-min catch-up", subtitle: "Phone or walk — not a dinner plan"),
                TaskPair(title: "Reply to one message you've avoided", subtitle: "Two sentences is enough"),
                TaskPair(title: "Share one honest feeling", subtitle: "With someone safe"),
            ]
        case (.relationships, .burnout):
            return [
                TaskPair(title: "Cancel one social maybe", subtitle: "Protect recovery without ghosting"),
                TaskPair(title: "Ask for help with one small thing", subtitle: "Dishes, pickup, or listening"),
                TaskPair(title: "Send a heart emoji only", subtitle: "Connection without energy drain"),
                TaskPair(title: "Set a do-not-disturb hour", subtitle: "Tell one person so it's kind"),
                TaskPair(title: "Journal one relationship need", subtitle: "Clarity before confrontation"),
            ]
        case (.relationships, .financialPressure):
            return [
                TaskPair(title: "Suggest a free hangout", subtitle: "Walk, home tea, or park"),
                TaskPair(title: "Thank someone non-materially", subtitle: "Specific words, not a gift"),
                TaskPair(title: "Decline one costly invite kindly", subtitle: "Offer a cheaper alternative"),
                TaskPair(title: "Plan a potluck instead of eating out", subtitle: "Shared cost, shared care"),
                TaskPair(title: "Text appreciation to a supporter", subtitle: "Relationships aren't only spending"),
            ]
        case (.relationships, .lowConsistency):
            return [
                TaskPair(title: "React to one friend's story", subtitle: "Low-effort presence"),
                TaskPair(title: "Save one person's birthday", subtitle: "Future you will thank you"),
                TaskPair(title: "Send a meme that made you smile", subtitle: "Light touch counts"),
                TaskPair(title: "Write one name to reach out to", subtitle: "Call tomorrow if today is hard"),
                TaskPair(title: "Set a weekly connection reminder", subtitle: "Same day, same 5 minutes"),
            ]
        case (.relationships, .unsupportiveEnvironment):
            return [
                TaskPair(title: "Message one online community", subtitle: "Find one thread where you belong"),
                TaskPair(title: "List three people who get you", subtitle: "Reach toward one of them"),
                TaskPair(title: "Practice one boundary phrase", subtitle: "Say it out loud alone first"),
                TaskPair(title: "Read one boundary article", subtitle: "Skills for unsupportive spaces"),
                TaskPair(title: "Plan time with your chosen family", subtitle: "Even virtual counts"),
            ]

        // MARK: Growth & Learning
        case (.growthLearning, .noTimeOff):
            return [
                TaskPair(title: "Read one page or one article", subtitle: "Not a whole chapter"),
                TaskPair(title: "Watch a 10-minute tutorial", subtitle: "Pause and note one takeaway"),
                TaskPair(title: "Write one question you're curious about", subtitle: "Learning starts with wonder"),
                TaskPair(title: "Review notes from last time", subtitle: "5 minutes of recall beats new content"),
                TaskPair(title: "Save one resource for the weekend", subtitle: "Batch learning when you have air"),
            ]
        case (.growthLearning, .burnout):
            return [
                TaskPair(title: "Learn something playful only", subtitle: "Song, recipe, or fun fact"),
                TaskPair(title: "Skip new input — reflect instead", subtitle: "What did you already learn this month?"),
                TaskPair(title: "Listen to a podcast while resting", subtitle: "Passive counts on tired days"),
                TaskPair(title: "Close unused learning tabs", subtitle: "Mental clutter is exhaustion too"),
                TaskPair(title: "Celebrate one skill you have", subtitle: "Growth isn't only adding"),
            ]
        case (.growthLearning, .financialPressure):
            return [
                TaskPair(title: "Use a free course or library resource", subtitle: "No new subscriptions today"),
                TaskPair(title: "Practice one skill for income", subtitle: "Portfolio line, pitch, or sample"),
                TaskPair(title: "Read one career blog post", subtitle: "Actionable, not doom-scrolling"),
                TaskPair(title: "Update one line on your resume", subtitle: "Small progress compounds"),
                TaskPair(title: "List skills you could barter", subtitle: "Growth without cash outlay"),
            ]
        case (.growthLearning, .lowConsistency):
            return [
                TaskPair(title: "Study flashcards for 5 minutes", subtitle: "Stop when timer rings"),
                TaskPair(title: "Do one practice problem", subtitle: "Quality over quantity"),
                TaskPair(title: "Put learning materials in your bag", subtitle: "See them, use them"),
                TaskPair(title: "Track streak on paper", subtitle: "Cross off today only"),
                TaskPair(title: "Teach one fact to someone", subtitle: "Teaching locks learning in"),
            ]
        case (.growthLearning, .unsupportiveEnvironment):
            return [
                TaskPair(title: "Study in a café or library", subtitle: "Change the room, change the focus"),
                TaskPair(title: "Find one online study buddy", subtitle: "Body doubling works"),
                TaskPair(title: "Mute discouraging channels", subtitle: "Protect your attention"),
                TaskPair(title: "Write why this skill matters to you", subtitle: "Internal motivation anchor"),
                TaskPair(title: "Save work in a private folder", subtitle: "Your growth, your pace"),
            ]

        // MARK: Financial Security
        case (.financialSecurity, .noTimeOff):
            return [
                TaskPair(title: "Check one account balance", subtitle: "Know the number, don't spiral"),
                TaskPair(title: "Pay one small bill early", subtitle: "Reduce mental load"),
                TaskPair(title: "Set a calendar bill reminder", subtitle: "One due date at a time"),
                TaskPair(title: "List three essential expenses", subtitle: "Clarity before cutting"),
                TaskPair(title: "Transfer $1 to savings", subtitle: "Habit over amount"),
            ]
        case (.financialSecurity, .burnout):
            return [
                TaskPair(title: "Pause money decisions today", subtitle: "No big purchases while depleted"),
                TaskPair(title: "Eat from what you have", subtitle: "Reduce decision fatigue"),
                TaskPair(title: "Automate one payment if possible", subtitle: "One less thing to remember"),
                TaskPair(title: "Write one money worry down", subtitle: "Get it out of your head"),
                TaskPair(title: "Ask: what would calm me 1%?", subtitle: "Tiny financial self-care"),
            ]
        case (.financialSecurity, .financialPressure):
            return [
                TaskPair(title: "Track spending for today only", subtitle: "Not the whole month yet"),
                TaskPair(title: "Find one expense to trim", subtitle: "Streaming, delivery, or duplicate"),
                TaskPair(title: "Compare one utility or plan", subtitle: "15-minute research cap"),
                TaskPair(title: "List income due this fortnight", subtitle: "Cash-flow snapshot"),
                TaskPair(title: "Move spare change to debt or savings", subtitle: "Direction over perfection"),
            ]
        case (.financialSecurity, .lowConsistency):
            return [
                TaskPair(title: "Log one purchase in Notes", subtitle: "Build the tracking muscle"),
                TaskPair(title: "Set a weekly money check-in alarm", subtitle: "Same time, 10 minutes"),
                TaskPair(title: "Review last week's spending", subtitle: "Patterns, not shame"),
                TaskPair(title: "Put cash in labeled envelopes", subtitle: "Physical buckets help some brains"),
                TaskPair(title: "Celebrate one money habit kept", subtitle: "Reinforce what worked"),
            ]
        case (.financialSecurity, .unsupportiveEnvironment):
            return [
                TaskPair(title: "Open banking in private mode", subtitle: "Your numbers, your screen"),
                TaskPair(title: "Read one free financial literacy page", subtitle: "Government or nonprofit source"),
                TaskPair(title: "Write a private savings goal", subtitle: "Don't share if unsafe"),
                TaskPair(title: "Find one community financial resource", subtitle: "Counseling or grants locally"),
                TaskPair(title: "Separate one wishlist from needs", subtitle: "Delay, don't deny — sort first"),
            ]

        }
    }
}
