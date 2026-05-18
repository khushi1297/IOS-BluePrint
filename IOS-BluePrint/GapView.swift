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
}

struct GapView: View {
    @Binding var currentStep: AppStep
    @ObservedObject var blueprint: BlueprintState

    @State private var puzzleVisible: [Bool] = Array(repeating: false, count: 16)
    @State private var blockingVisible: [Bool] = Array(repeating: false, count: 5)

    private var lifeAreaLabel: String {
        blueprint.selectedLifeArea?.title ?? "Pick a life area on Canvas"
    }

    private var moodLabel: String {
        blueprint.selectedMood?.title ?? "Set mood"
    }

    var body: some View {
        HubScreenLayout(background: Color.gapCanvas) {
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
                        .padding(.bottom, HubChromeMetrics.scrollTailPadding)
                }
                .padding(.horizontal, 20)
            }
        } footer: {
            continueButton
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
                $currentStep.navigate(to: .canvas)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: 0x747474))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back to Canvas")

            Button {
                $currentStep.navigate(to: .canvas)
            } label: {
                chipPill(text: lifeAreaLabel)
                    .lineLimit(1)
            }
            .buttonStyle(.plain)
            .layoutPriority(-1)
            .accessibilityLabel("Life area, go to Canvas")

            Spacer(minLength: 8)

            moodChip
                .layoutPriority(1)
                .accessibilityLabel(moodLabel)
                .accessibilityAddTraits(.isStaticText)
        }
    }

    /// Read-only mood from Canvas check-in (not editable on Gap).
    private var moodChip: some View {
        HStack(spacing: 6) {
            if let mood = blueprint.selectedMood {
                MoodAssetIcon(mood: mood, height: 20, maxWidth: 58)
            }
            Text(moodLabel)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.gapTextPrimary.opacity(blueprint.selectedMood == nil ? 0.55 : 1))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gapPink.opacity(0.72))
        .overlay(
            Capsule()
                .strokeBorder(Color.gapChipBorder.opacity(0.9), lineWidth: 0.5)
        )
        .clipShape(Capsule())
        .allowsHitTesting(false)
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

            ForEach(Array(GapBlocker.allCases.enumerated()), id: \.element.id) { index, blocker in
                let visible = index < blockingVisible.count ? blockingVisible[index] : false
                let selected = blueprint.selectedGap == blocker

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        blueprint.selectedGap = blocker
                    }
                } label: {
                    HStack(alignment: .center, spacing: 10) {
                        Text("\(index + 1).")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.gapTextPrimary.opacity(0.7))

                        Text(blocker.listTitle)
                            .font(.system(size: 14, weight: selected ? .semibold : .regular, design: .rounded))
                            .foregroundStyle(Color.gapTextPrimary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.12), radius: 0, x: 0, y: 1)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(selected ? Color.gapPurple.opacity(0.55) : Color.gapPink.opacity(0.7))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(
                                selected ? Color.gapChipBorder : Color.black.opacity(0.18),
                                lineWidth: selected ? 1.5 : 0.35
                            )
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(blocker.listTitle)
                .accessibilityAddTraits(selected ? .isSelected : [])
                .opacity(visible ? 1 : 0)
                .offset(y: visible ? 0 : 16)
            }
        }
    }

    // MARK: Bottom chrome

    private var continueButton: some View {
        Button {
            $currentStep.navigate(to: .afterGapContinue)
        } label: {
            Text("Continue")
        }
        .buttonStyle(BlueprintPrimaryCapsuleButtonStyle(isEnabled: blueprint.selectedGap != nil))
        .disabled(blueprint.selectedGap == nil)
        .opacity(blueprint.selectedGap == nil ? 0.5 : 1)
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
    GapView(currentStep: .constant(.gap), blueprint: BlueprintState())
}
