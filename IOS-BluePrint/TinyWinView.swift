import SwiftUI

/// Shown after the user leaves the Tasks screen — small celebration before continuing the flow.
struct TinyWinView: View {
    @Binding var currentStep: AppStep

    private let canvas = Color(red: 0.98, green: 0.96, blue: 0.95)
    private let titleYellow = Color(hue: 0.12, saturation: 0.55, brightness: 0.95)
    private let cardFill = Color(red: 0.82, green: 0.93, blue: 0.99)

    var body: some View {
        ZStack {
            canvas
                .ignoresSafeArea()

            GeometryReader { geo in
                let safe = geo.safeAreaInsets
                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    VStack(spacing: 22) {
                        Text("One tiny win today.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(titleYellow)
                            .multilineTextAlignment(.center)

                        Text("You showed up, and that's the whole thing.")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(Color(white: 0.32))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your progress isn't gone")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.black.opacity(0.88))

                            Text("Even on the rough days, you're still moving forward. Every small thing you do adds up.")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundStyle(.black.opacity(0.72))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(cardFill)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 0)

                    VStack(spacing: 14) {
                        Button {
                            withAnimation { currentStep = .gentleReflection }
                        } label: {
                            Text("Gentle Reflection")
                        }
                        .buttonStyle(BlueprintPrimaryCapsuleButtonStyle())
                        .padding(.horizontal, 48)

                        BlueprintBottomNavBar(currentStep: $currentStep)
                    }
                    .padding(.bottom, max(safe.bottom, 20))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    TinyWinView(currentStep: .constant(.tinyWin))
}
