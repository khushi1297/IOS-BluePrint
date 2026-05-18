import SwiftUI

/// Axis-aligned size of a `width × height` rectangle rotated by `degrees` (any anchor).
private func rotatedBoundsSize(width: CGFloat, height: CGFloat, degrees: Double) -> CGSize {
    let radians = degrees * .pi / 180
    let c = abs(cos(radians))
    let s = abs(sin(radians))
    return CGSize(width: width * c + height * s, height: width * s + height * c)
}

struct PriorityItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle1: String
    let subtitle2: String
    let subtitle3: String
    let color: Color
    let rotation: Double
}

private let maxPriorityCardCount = 6

struct PrioritiesView: View {
    @Binding var currentStep: AppStep
    @ObservedObject var blueprint: BlueprintState

    @State private var items: [PriorityItem] = [
        PriorityItem(title: "Financial Security", subtitle1: "Save for my next trip", subtitle2: "Review monthly spending", subtitle3: "Set up an emergency buffer", color: Color(red: 1.0, green: 0.64, blue: 0.65), rotation: 7.0),
        PriorityItem(title: "Relationships", subtitle1: "Plan one catch-up this week", subtitle2: "Edit the travel video", subtitle3: "Plan a date place for birthday", color: Color(red: 0.80, green: 0.72, blue: 0.98), rotation: 0.0),
        PriorityItem(title: "Health & Energy", subtitle1: "Move my body 3x this week", subtitle2: "Sleep before 10pm", subtitle3: "Take one screen-free reset", color: Color(red: 0.55, green: 0.84, blue: 0.90), rotation: -7.5),
        PriorityItem(title: "Growth & Learning", subtitle1: "Read 10 pages a day", subtitle2: "Get in touch with the professor", subtitle3: "Watch one design podcast", color: Color(red: 1.0, green: 0.85, blue: 0.42), rotation: 0.0),
        PriorityItem(title: "Freedom & Flexibility", subtitle1: "Work on my side project", subtitle2: "Explore a new place", subtitle3: "Register for Sydney marathon", color: Color(red: 1.0, green: 0.64, blue: 0.76), rotation: -5.8)
    ]

    @State private var draggingID: UUID?
    @State private var dragOffset: CGSize = .zero
    /// Disables `ScrollView` as soon as a drag begins so the deck wins the gesture arena.
    @State private var isDeckDragActive = false

    private let deckHorizontalInset: CGFloat = 24
    private let deckSideSlack: CGFloat = 44

    private var deckCardWidth: CGFloat {
        max(200, min(330, UIScreen.main.bounds.width - deckHorizontalInset * 2 - deckSideSlack))
    }

    private var deckCardHeight: CGFloat {
        141 * (deckCardWidth / 330)
    }

    private var deckStep: CGFloat {
        stackStep(cardHeight: deckCardHeight, cardWidth: deckCardWidth)
    }

    private var deckInteriorHeight: CGFloat {
        let maxAbsRotation = abs(stackTilt(stackDepth: 0))
        let bbox = rotatedBoundsSize(width: deckCardWidth, height: deckCardHeight, degrees: maxAbsRotation)
        let stackCount = max(items.count - 1, 0)
        let rotationExtra = max(0, bbox.height - deckCardHeight)
        return CGFloat(stackCount) * deckStep + bbox.height + rotationExtra * 0.85 + 40
    }

    /// Vertical offset between card tops — larger step so each card shows more (less vertical overlap).
    private func stackStep(cardHeight: CGFloat, cardWidth: CGFloat) -> CGFloat {
        let titlePeek = 16 + 20 * (cardWidth / 330) * 1.22 + 6
        let minStep = titlePeek + 32
        let preferred = cardHeight * 0.52
        return min(max(preferred, minStep), cardHeight * 0.68)
    }

    /// Alternating tilt: #1 slightly CCW, #2 CW, … (matches “messy deck” reference).
    private func stackTilt(stackDepth: Int) -> Double {
        stackDepth.isMultiple(of: 2) ? -4.2 : 4.2
    }

    @ViewBuilder
    private func priorityDeckLayer(
        cardW: CGFloat,
        cardH: CGFloat,
        step: CGFloat,
        interiorDeckHeight: CGFloat,
        horizontalInset: CGFloat
    ) -> some View {
        ZStack(alignment: .top) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let isDragging = draggingID == item.id
                let stackDepth = items.count - 1 - index
                let stackOffset = CGFloat(stackDepth) * step

                PriorityStackCard(
                    item: item,
                    priority: items.count - index,
                    isDragging: isDragging,
                    cardWidth: cardW,
                    cardHeight: cardH
                )
                .rotationEffect(.degrees(isDragging ? 0 : stackTilt(stackDepth: stackDepth)))
                .offset(
                    x: isDragging ? dragOffset.width : 0,
                    y: (isDragging ? dragOffset.height : 0) + stackOffset
                )
                .zIndex(isDragging ? 999 : Double(index))
                .scaleEffect(isDragging ? 1.03 : 1.0)
                .shadow(
                    color: item.color.opacity(isDragging ? 0.4 : 0.2),
                    radius: isDragging ? 16 : 6,
                    x: 0,
                    y: isDragging ? 10 : 4
                )
                .frame(width: cardW, height: cardH)
                .contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            isDeckDragActive = true
                            if draggingID == nil {
                                if let idx = items.firstIndex(where: { $0.id == item.id }),
                                   idx != items.count - 1
                                {
                                    withAnimation(nil) {
                                        var next = items
                                        let picked = next.remove(at: idx)
                                        next.append(picked)
                                        items = next
                                    }
                                }
                                draggingID = item.id
                            }
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            let dy = value.translation.height
                            let from = items.count - 1
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                                if dy < -55 {
                                    let card = items.remove(at: from)
                                    items.insert(card, at: 0)
                                } else {
                                    let slotDelta = Int(round(dy / max(step, 1)))
                                    var target = from - slotDelta
                                    target = max(0, min(items.count - 1, target))
                                    if target != from {
                                        let card = items.remove(at: from)
                                        items.insert(card, at: target)
                                    }
                                }
                            }
                            dragOffset = .zero
                            draggingID = nil
                            isDeckDragActive = false
                        }
                )
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: items)
        .frame(height: interiorDeckHeight)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalInset)
        .defersSystemGestures(on: .vertical)
    }

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.95)
                .ignoresSafeArea()

            GeometryReader { geo in
                let safe = geo.safeAreaInsets
                let horizontalInset: CGFloat = 24
                /// Horizontal slack so rotated corners and shadows stay inside the screen.
                let sideSlack: CGFloat = 44
                let designCard = CGSize(width: 330, height: 141)
                let maxCardWidth = max(
                    200,
                    min(
                        designCard.width,
                        geo.size.width - horizontalInset * 2 - sideSlack
                    )
                )
                let cardScale = maxCardWidth / designCard.width
                let cardW = designCard.width * cardScale
                let cardH = designCard.height * cardScale
                let step = stackStep(cardHeight: cardH, cardWidth: cardW)
                let maxAbsRotation = abs(stackTilt(stackDepth: 0))
                let bbox = rotatedBoundsSize(width: cardW, height: cardH, degrees: maxAbsRotation)
                let stackCount = max(items.count - 1, 0)
                let rotationExtra = max(0, bbox.height - cardH)
                /// Tall enough that rotated cards + shadows are not clipped inside the ZStack.
                let interiorDeckHeight = CGFloat(stackCount) * step + bbox.height + rotationExtra * 0.85 + 40
                /// When the deck fits, avoid `ScrollView` — short scroll content is vertically centered and leaves a gap under the header.
                let headerChrome = max(safe.top, 12) + 44
                let footerChrome = 128 + max(safe.bottom, 10)
                let deckSlotHeight = max(100, geo.size.height - headerChrome - footerChrome)
                let needsDeckScroll = interiorDeckHeight > deckSlotHeight

                VStack(spacing: 0) {

                    // Header
                    VStack(spacing: 2) {
                        Text("Based on your board")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(white: 0.3))
                            .padding(.top, max(safe.top, 12))
                        Text("drag cards to rank your priorities")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, horizontalInset)
                    .padding(.bottom, 0)

                    ScrollView(.vertical, showsIndicators: needsDeckScroll) {
                        VStack(spacing: 0) {
                            priorityDeckLayer(
                                cardW: cardW,
                                cardH: cardH,
                                step: step,
                                interiorDeckHeight: interiorDeckHeight,
                                horizontalInset: horizontalInset
                            )
                            if needsDeckScroll {
                                Spacer(minLength: 0)
                            }
                        }
                        .frame(
                            maxWidth: .infinity,
                            minHeight: needsDeckScroll ? deckSlotHeight : interiorDeckHeight,
                            alignment: .top
                        )
                    }
                    .defaultScrollAnchor(.top)
                    .scrollClipDisabled(true)
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollDisabled(isDeckDragActive)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentMargins(.vertical, 0, for: .scrollContent)
                    .padding(.top, -100)

                    // Footer (nudged up so Continue overlaps the bottom of the stack, like the reference)
                    VStack(spacing: 12) {
                        Button {
                            blueprint.shouldPresentCanvasWelcome = true
                            withAnimation { currentStep = .canvas }
                        } label: {
                            Text("Continue")
                        }
                        .buttonStyle(BlueprintPrimaryCapsuleButtonStyle())
                        .padding(.horizontal, horizontalInset)
                    }
                    .padding(.top, 12) // footer
                    .padding(.bottom, max(safe.bottom, 10))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .onAppear {
                    if items.count > maxPriorityCardCount {
                        items = Array(items.prefix(maxPriorityCardCount))
                    }
                }
            }
        }
    }
}

struct PriorityStackCard: View {
    let item: PriorityItem
    let priority: Int
    let isDragging: Bool
    var cardWidth: CGFloat = 330
    var cardHeight: CGFloat = 141

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 8)
                .fill(item.color)

            // 2x3 dot grid top right
            VStack(spacing: 4.7) {
                ForEach(0..<3) { _ in
                    HStack(spacing: 4.7) {
                        ForEach(0..<2) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.55))
                                .frame(width: 2.3, height: 2.3)
                        }
                    }
                }
            }
            .padding(14)

            // Card content
            VStack(alignment: .leading, spacing: 0) {
                Text(item.title)
                    .font(.system(size: 20 * (cardWidth / 330), weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                Spacer(minLength: 0)

                HStack(alignment: .bottom, spacing: 10) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.subtitle1)
                            .font(.system(size: 13 * (cardWidth / 330), weight: .regular, design: .rounded))
                            .foregroundStyle(.black.opacity(0.65))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(item.subtitle2)
                            .font(.system(size: 13 * (cardWidth / 330), weight: .regular, design: .rounded))
                            .foregroundStyle(.black.opacity(0.65))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(item.subtitle3)
                            .font(.system(size: 13 * (cardWidth / 330), weight: .regular, design: .rounded))
                            .foregroundStyle(.black.opacity(0.65))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text("#\(priority) Priority")
                        .font(.system(size: 11 * (cardWidth / 330), weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.5))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.39))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .fixedSize(horizontal: true, vertical: false)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
    }
}

#Preview {
    PrioritiesView(currentStep: .constant(.priorities), blueprint: BlueprintState())
}
