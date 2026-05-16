import SwiftUI

/// Weekly reflection after “Tiny win” — also reachable from the star tab anywhere in the flow.
struct GentleReflectionView: View {
    @Binding var currentStep: AppStep

    private let canvas = Color(red: 0.98, green: 0.96, blue: 0.95)
    private let titleYellow = Color(hue: 0.12, saturation: 0.55, brightness: 0.95)
    private let cardBlue = Color(red: 0.82, green: 0.93, blue: 0.99)
    private let cardLavender = Color(red: 0.96, green: 0.92, blue: 0.97)

    private let weekdays: [(label: String, done: Bool)] = [
        ("Mon", true), ("Tue", true), ("Wed", true), ("Thu", true),
        ("Fri", false), ("Sat", false), ("Sun", false)
    ]

    var body: some View {
        ZStack {
            canvas
                .ignoresSafeArea()

            GeometryReader { geo in
                let safe = geo.safeAreaInsets
                let inset: CGFloat = 24

                VStack(spacing: 0) {
                    Text("Gentle Reflection")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(titleYellow)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, max(safe.top, 12) + 4)
                        .padding(.bottom, 14)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            connectionCard
                            streakCard
                            mantraCard
                        }
                        .padding(.horizontal, inset)
                        .padding(.top, 4)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    BlueprintBottomNavBar(currentStep: $currentStep, horizontalInset: inset, style: .dark)
                        .padding(.bottom, max(safe.bottom, 16))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private var connectionCard: some View {
        VStack(spacing: 16) {
            Text("You stayed connected this week")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.88))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            VStack(spacing: 12) {
                FortuneCookieLineArt()
                    .frame(height: 118)
                    .accessibilityLabel("Fortune cookie")

                Text("YOU WILL HAVE A GREAT DAY ☺︎")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hue: 0.72, saturation: 0.45, brightness: 0.45))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.12), lineWidth: 1)
                    )
            }
            .padding(.vertical, 8)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(cardBlue)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var streakCard: some View {
        VStack(spacing: 16) {
            Text("4 of 7 days still counts")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.88))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                ForEach(Array(weekdays.enumerated()), id: \.element.label) { _, day in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(
                                day.done
                                    ? Color(hue: 0.58, saturation: 0.55, brightness: 0.95)
                                    : Color(hue: 0.58, saturation: 0.22, brightness: 0.94).opacity(0.45)
                            )
                            .frame(width: 36, height: 36)
                            .overlay {
                                if day.done {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        Text(day.label)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(day.done ? .black.opacity(0.75) : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(cardBlue)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var mantraCard: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Progress isn’t linear. Presence is powerful.")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)

                Text("Small steps create meaningful change.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "heart")
                .font(.system(size: 32, weight: .regular))
                .foregroundStyle(.black.opacity(0.35))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(cardLavender)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

/// Purple line-art style fortune cookie character (reference illustration).
private struct FortuneCookieLineArt: View {
    private let stroke = Color(hue: 0.72, saturation: 0.5, brightness: 0.48)

    var body: some View {
        ZStack {
            // Folded cookie body
            ZStack {
                Capsule()
                    .stroke(stroke, lineWidth: 2.5)
                    .frame(width: 92, height: 44)
                    .rotationEffect(.degrees(-18))
                Capsule()
                    .stroke(stroke, lineWidth: 2.5)
                    .frame(width: 88, height: 42)
                    .rotationEffect(.degrees(14))
                    .offset(x: 4, y: 6)
            }
            .offset(y: -8)

            // Face
            HStack(spacing: 14) {
                Circle().fill(stroke).frame(width: 5, height: 5)
                Circle().fill(stroke).frame(width: 5, height: 5)
            }
            .offset(y: 2)

            SmileArc()
                .stroke(stroke, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 22, height: 12)
                .offset(y: 10)

            // Stick legs
            HStack(spacing: 18) {
                LegLine()
                LegLine()
            }
            .offset(y: 36)
        }
        .frame(maxWidth: .infinity)
    }

    private struct LegLine: View {
        private let stroke = Color(hue: 0.72, saturation: 0.5, brightness: 0.48)
        var body: some View {
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: 2, y: 14))
            }
            .stroke(stroke, style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
            .frame(width: 4, height: 14)
        }
    }

    private struct SmileArc: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.addArc(
                center: CGPoint(x: rect.midX, y: rect.minY),
                radius: rect.width / 2,
                startAngle: .degrees(12),
                endAngle: .degrees(168),
                clockwise: false
            )
            return p
        }
    }
}

#Preview {
    GentleReflectionView(currentStep: .constant(.gentleReflection))
}
