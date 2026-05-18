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
                let scrollTail = HubChromeMetrics.bottomNavReservedHeight(safeAreaBottom: safe.bottom)
                    + HubChromeMetrics.scrollTailPadding
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

                            Color.clear
                                .frame(height: scrollTail)
                        }
                        .padding(.horizontal, inset)
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

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

            Image("great_day_illustration")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(height: 118)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("You will have a great day")
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

#Preview {
    GentleReflectionView(currentStep: .constant(.gentleReflection))
}
