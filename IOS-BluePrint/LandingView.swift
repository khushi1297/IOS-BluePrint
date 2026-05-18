import SwiftUI

struct LandingView: View {
    @Binding var currentStep: AppStep
    @State private var appear = false
    
    var body: some View {
        ZStack {
            Color(hue: 0.08, saturation: 0.05, brightness: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: -8) {
                    Text("BLUE")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hue: 0.68, saturation: 0.42, brightness: 0.86))
                        .shadow(color: Color(hue: 0.6, saturation: 0.4, brightness: 0.8).opacity(0.3), radius: 2, x: 2, y: 2)
                    
                    Text("PRINT")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hue: 0.68, saturation: 0.42, brightness: 0.86))
                        .shadow(color: Color(hue: 0.6, saturation: 0.4, brightness: 0.8).opacity(0.3), radius: 2, x: 2, y: 2)
                }
                .scaleEffect(appear ? 1 : 0.9)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : -18)

                Text("Design a life that feels good")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -22)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                appear = true
            }
            
            // Auto transition after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    if currentStep == .landing {
                        currentStep = .moodboard
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation {
                currentStep = .moodboard
            }
        }
    }
}

#Preview {
    LandingView(currentStep: .constant(.landing))
}
