import SwiftUI

// MARK: - Design tokens (Emotional Ease Gap screen)

private extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    static let gapCanvas = Color(hex: 0xFBF6F3)
    static let gapTitleYellow = Color(hex: 0xFFBC2B)
    static let gapTextPrimary = Color(hex: 0x5A5757)
    static let gapPink = Color(hex: 0xFFA3C2)
    static let gapPurple = Color(hex: 0xCDB7FA)
    static let gapBlue = Color(hex: 0x8CD7E6)
    static let gapChipBorder = Color(hex: 0xCDB6E2)
    static let gapTabBarFill = Color(hex: 0x3A3A3A).opacity(0.92)
}

struct BlockingItem: Identifiable {
    let id = UUID()
    let text: String
}

struct GapView: View {
    @Binding var currentStep: AppStep

    /// Shown in the header life-area chip (wire from flow later).
    var selectedLifeArea: String = "Freedom & Flexibility"
    /// Shown in the mood chip (wire from flow later).
    var selectedMood: String = "Rough"
    /// Emoji prefix for mood chip; swap per mood if needed.
    var moodEmoji: String = "😤"

    @State private var puzzleVisible: [Bool] = Array(repeating: false, count: 16)
    @State private var blockingVisible: [Bool] = Array(repeating: false, count: 5)

    private let blockingItems: [BlockingItem] = [
        BlockingItem(text: "1. Contract job with no paid leave, can't take time off"),
        BlockingItem(text: "2. Daily burnout and lack of recovery time"),
        BlockingItem(text: "3. Student debt repayments eating every spare dollar"),
        BlockingItem(text: "4. Hard to stay consistent when I'm low"),
        BlockingItem(text: "5. My environment doesn't support this yet"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.gapCanvas
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                        .padding(.top, 8)

                    titleBlock
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)

                    puzzleGrid16
                        .padding(.top, 20)

                    progressRow
                        .padding(.top, 16)

                    blockingSection
                        .padding(.top, 22)
                        .padding(.bottom, 160)
                }
                .padding(.horizontal, 20)
            }

            VStack(spacing: 10) {
                continueButton
                tabBar
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .background(Color.gapCanvas)
        }
        .onAppear {
            startPuzzleAnimation()
            startBlockingAnimation()
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            Button {
                withAnimation {
                    currentStep = .canvas
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: 0x747474))
            }
            .buttonStyle(.plain)

            chipPill(text: selectedLifeArea)
                .lineLimit(1)
                .layoutPriority(-1)

            Spacer(minLength: 8)

            moodChip
                .layoutPriority(1)
        }
    }

    private var moodChip: some View {
        HStack(spacing: 6) {
            Text(moodEmoji)
                .font(.system(size: 14))
            Text(selectedMood)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.gapTextPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gapPink.opacity(0.72))
        .overlay(
            Capsule()
                .strokeBorder(Color.gapChipBorder.opacity(0.9), lineWidth: 0.5)
        )
        .clipShape(Capsule())
    }

    private func chipPill(text: String) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.gapTextPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gapPink.opacity(0.72))
        .overlay(
            Capsule()
                .strokeBorder(Color.gapChipBorder.opacity(0.9), lineWidth: 0.5)
        )
        .clipShape(Capsule())
    }

    // MARK: Title

    private var titleBlock: some View {
        VStack(spacing: 6) {
            Text("Your Gap")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(Color.gapTitleYellow)

            Text("How far have you come")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.gapTextPrimary.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: 4×4 puzzle (numbers 1…16, piece 7 = “gap” highlight)

    private let puzzleColumns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
    ]

    private var puzzleGrid16: some View {
        LazyVGrid(columns: puzzleColumns, spacing: 3) {
            ForEach(1...16, id: \.self) { n in
                let idx = n - 1
                let visible = idx < puzzleVisible.count ? puzzleVisible[idx] : false
                let edges = GapJigsawCatalog.edges(forPieceNumber: n)
                let fill = GapJigsawCatalog.fillColor(forPieceNumber: n)

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    ZStack {
                        GapJigsawShape(top: edges.0, right: edges.1, bottom: edges.2, left: edges.3)
                            .fill(fill)
                        GapJigsawShape(top: edges.0, right: edges.1, bottom: edges.2, left: edges.3)
                            .stroke(Color.white.opacity(0.92), lineWidth: 1.1)
                        GapJigsawShape(top: edges.0, right: edges.1, bottom: edges.2, left: edges.3)
                            .stroke(Color.black.opacity(0.14), lineWidth: 0.35)
                        Text("\(n)")
                            .font(.system(size: max(11, min(w, h) * 0.34), weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: 0x262626))
                    }
                    .frame(width: w, height: h, alignment: .center)
                }
                .aspectRatio(1, contentMode: .fit)
                .opacity(visible ? 1 : 0)
                .offset(y: visible ? 0 : 10)
            }
        }
        .padding(.top, 10)
        .padding(.vertical, 8)
    }

    // MARK: Progress

    private var progressRow: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.65)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 16, height: 16)
                        .rotationEffect(.degrees(-90))
                    Circle()
                        .fill(Color.green.opacity(0.35))
                        .frame(width: 8, height: 8)
                }
                Text("On-track")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.gapTextPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.green.opacity(0.35), lineWidth: 1)
            )

            Spacer()

            Text("7 out of 16")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.gapTitleYellow)
        }
    }

    // MARK: Blocking list

    private var blockingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's blocking it")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color.gapTextPrimary.opacity(0.85))

            ForEach(Array(blockingItems.enumerated()), id: \.element.id) { index, item in
                let visible = index < blockingVisible.count ? blockingVisible[index] : false

                Text(item.text)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.gapTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.gapPink.opacity(0.7))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.18), lineWidth: 0.35)
                    )
                    .opacity(visible ? 1 : 0)
                    .offset(y: visible ? 0 : 16)
            }
        }
    }

    // MARK: Bottom chrome

    private var continueButton: some View {
        Button {
            withAnimation {
                currentStep = .tasks
            }
        } label: {
            Text("Continue")
        }
        .buttonStyle(BlueprintPrimaryCapsuleButtonStyle())
    }

    private var tabBar: some View {
        HStack {
            Spacer()
            tabBarIcon("house.fill")
            Spacer()
            tabBarIcon("doc.on.doc.fill")
            Spacer()
            tabBarIcon("star.fill")
            Spacer()
        }
        .padding(.vertical, 14)
        .background(
            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                Capsule()
                    .fill(Color.gapTabBarFill.opacity(0.88))
            }
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
    }

    private func tabBarIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color.gapPurple.opacity(0.98),
                        Color.gapBlue.opacity(0.98),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 1)
    }

    // MARK: Animations

    private func startPuzzleAnimation() {
        for index in 0..<puzzleVisible.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.045) {
                withAnimation(.easeOut(duration: 0.45)) {
                    puzzleVisible[index] = true
                }
            }
        }
    }

    private func startBlockingAnimation() {
        for index in 0..<blockingVisible.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.08) {
                withAnimation(.easeOut(duration: 0.5)) {
                    blockingVisible[index] = true
                }
            }
        }
    }
}

#Preview {
    GapView(currentStep: .constant(.gap))
}
