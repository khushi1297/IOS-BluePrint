import SwiftUI

private enum QuestionsPalette {
    static let canvas = Color(red: 251 / 255, green: 246 / 255, blue: 243 / 255) // #FBF6F3
    static let yellow = Color(red: 245 / 255, green: 200 / 255, blue: 66 / 255) // #F5C842
    static let pink = Color(red: 255 / 255, green: 163 / 255, blue: 194 / 255) // #FFA3C2
    static let purple = Color(red: 205 / 255, green: 183 / 255, blue: 250 / 255) // #CDB7FA
    static let blue = Color(red: 140 / 255, green: 215 / 255, blue: 230 / 255) // #8CD7E6
    /// Menu icon on cards
    static let menuIcon = Color(red: 91 / 255, green: 127 / 255, blue: 212 / 255) // #5B7FD4
}

struct QuestionCard: Identifiable {
    let id = UUID()
    let number: String
    let question: String
    let color: Color
}

struct QuestionsView: View {
    @Binding var currentStep: AppStep

    /// Bottom → top in stack: 05 … 01 (01 on top).
    @State private var cards: [QuestionCard] = [
        QuestionCard(number: "05", question: "What is one pattern you are ready to leave behind?", color: QuestionsPalette.yellow),
        QuestionCard(number: "04", question: "When do you feel most like yourself?", color: QuestionsPalette.pink),
        QuestionCard(number: "03", question: "What brings you the most peace right now?", color: QuestionsPalette.purple),
        QuestionCard(number: "02", question: "If time wasn't an issue, what would you do today?", color: QuestionsPalette.blue),
        QuestionCard(number: "01", question: "What's something kind you haven't done for yourself in a while?", color: QuestionsPalette.blue),
    ]

    private let cardSize = CGSize(width: 280, height: 320)
    /// Axis-aligned room for the deck at scale 1.0 (280×320 cards + rotation + offsets + shadow).
    private let stackDesignSize = CGSize(width: 360, height: 470)

    var body: some View {
        ZStack {
            QuestionsPalette.canvas
                .ignoresSafeArea()

            GeometryReader { geo in
                let safe = geo.safeAreaInsets
                let horizontalInset: CGFloat = 24
                let headerBlock: CGFloat = 50
                let dotsAndHint: CGFloat = 56
                /// Continue + tab bar + padding (tab bar already pads safe bottom).
                let bottomChrome: CGFloat = 118
                let availableHeight = geo.size.height - safe.top - safe.bottom - headerBlock - dotsAndHint - bottomChrome
                let availableWidth = geo.size.width - horizontalInset * 2
                let scale = min(
                    1,
                    availableWidth / stackDesignSize.width,
                    max(160, availableHeight) / stackDesignSize.height
                )
                let scaledW = stackDesignSize.width * scale
                let scaledH = stackDesignSize.height * scale

                VStack(spacing: 0) {
                    Text("Based on your board")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hue: 0.0, saturation: 0.0, brightness: 0.3))
                        .padding(.top, max(safe.top, 12) + 4)
                        .padding(.horizontal, horizontalInset)
                        .padding(.bottom, 10)

                    ZStack {
                        ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                            CardView(card: card, index: index, totalCards: cards.count, cardSize: cardSize) {
                                withAnimation(.spring()) {
                                    _ = cards.popLast()
                                }
                            }
                        }
                    }
                    .frame(width: stackDesignSize.width, height: stackDesignSize.height)
                    .scaleEffect(scale, anchor: .center)
                    .frame(width: scaledW, height: scaledH)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("questionCardStack")

                    HStack(spacing: 8) {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(index == (5 - cards.count) ? Color(hue: 0.72, saturation: 0.4, brightness: 0.8) : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 8)

                    Text("drag and swipe left for the next card")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                        .padding(.bottom, 8)

                    Spacer(minLength: 0)

                    Button {
                        withAnimation {
                            currentStep = .priorities
                        }
                    } label: {
                        Text("Continue")
                    }
                    .buttonStyle(BlueprintPrimaryCapsuleButtonStyle())
                    .padding(.horizontal, horizontalInset)
                    .padding(.top, 2)
                    .padding(.bottom, 6)

                    BlueprintBottomNavBar(currentStep: $currentStep, horizontalInset: horizontalInset)
                        .padding(.bottom, max(safe.bottom, 10))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

private struct CardStackStyle {
    let rotation: Double
    let offset: CGSize

    /// Slightly tighter offsets so the scaled deck fits small phones without clipping.
    static func style(forStackFromTop stackFromTop: Int) -> CardStackStyle {
        let styles: [CardStackStyle] = [
            CardStackStyle(rotation: 3, offset: CGSize(width: 0, height: 0)),
            CardStackStyle(rotation: 8, offset: CGSize(width: 16, height: -6)),
            CardStackStyle(rotation: -8, offset: CGSize(width: -18, height: 5)),
            CardStackStyle(rotation: -5, offset: CGSize(width: -12, height: -8)),
            CardStackStyle(rotation: -2, offset: CGSize(width: -8, height: 8)),
            CardStackStyle(rotation: 2, offset: CGSize(width: 4, height: -12)),
        ]

        return styles[min(stackFromTop, styles.count - 1)]
    }
}

struct CardView: View {
    let card: QuestionCard
    let index: Int
    let totalCards: Int
    let cardSize: CGSize
    let onRemove: () -> Void

    @State private var translation: CGSize = .zero
    @State private var answerText: String = ""

    var body: some View {
        let stackFromTop = totalCards - 1 - index
        let stackStyle = CardStackStyle.style(forStackFromTop: stackFromTop)
        let isTopCard = stackFromTop == 0

        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(card.color)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)

            VStack(spacing: 0) {
                Text(card.number)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 22)

                Text(card.question)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                TextField("tap to write..", text: $answerText, axis: .vertical)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.black.opacity(0.75))
                    .lineLimit(1...6)
                    .padding(12)
                    .background(Color.white.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    .disabled(!isTopCard)

                Spacer(minLength: 0)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                // Placeholder — wire later if needed
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(QuestionsPalette.menuIcon)
                    .padding(10)
                    .background(Color.white.opacity(0.45))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
            .padding(.trailing, 12)
            .opacity(isTopCard ? 1 : 0.4)
            .allowsHitTesting(isTopCard)
        }
        .zIndex(isTopCard ? 2 : 0)
        .frame(width: cardSize.width, height: cardSize.height)
        .offset(
            x: stackStyle.offset.width + (isTopCard ? translation.width : 0),
            y: stackStyle.offset.height + (isTopCard ? translation.height : 0)
        )
        .rotationEffect(
            .degrees(stackStyle.rotation + (isTopCard ? Double(translation.width / 20) : 0))
        )
        .scaleEffect(1 - CGFloat(stackFromTop) * 0.015)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if isTopCard {
                        translation = value.translation
                    }
                }
                .onEnded { value in
                    if isTopCard {
                        if value.translation.width < -100 {
                            onRemove()
                        } else {
                            withAnimation(.spring()) {
                                translation = .zero
                            }
                        }
                    }
                }
        )
    }
}

#Preview {
    QuestionsView(currentStep: .constant(.questions))
}
