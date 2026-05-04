//
//  ContentView.swift
//  IOS-BluePrint
//
//  Created by Khush on 04/05/26.
//

import SwiftUI

struct CarouselSlide: Identifiable {
    let id = UUID()
    let greeting: String
    let language: String
    let emoji: String
    let gradient: [Color]
}

struct ContentView: View {

    private let slides: [CarouselSlide] = [
        CarouselSlide(greeting: "Hello, World!", language: "English", emoji: "👋",
                      gradient: [Color(hue: 0.58, saturation: 0.8, brightness: 0.9),
                                 Color(hue: 0.65, saturation: 0.7, brightness: 0.7)]),
        CarouselSlide(greeting: "Hola, Mundo!", language: "Spanish", emoji: "🌍",
                      gradient: [Color(hue: 0.08, saturation: 0.85, brightness: 0.95),
                                 Color(hue: 0.02, saturation: 0.9, brightness: 0.75)]),
        CarouselSlide(greeting: "Bonjour, Monde!", language: "French", emoji: "🥐",
                      gradient: [Color(hue: 0.82, saturation: 0.7, brightness: 0.9),
                                 Color(hue: 0.75, saturation: 0.8, brightness: 0.7)]),
        CarouselSlide(greeting: "こんにちは！", language: "Japanese", emoji: "🌸",
                      gradient: [Color(hue: 0.95, saturation: 0.6, brightness: 0.95),
                                 Color(hue: 0.88, saturation: 0.75, brightness: 0.75)]),
        CarouselSlide(greeting: "مرحبا بالعالم", language: "Arabic", emoji: "🌙",
                      gradient: [Color(hue: 0.38, saturation: 0.7, brightness: 0.75),
                                 Color(hue: 0.45, saturation: 0.8, brightness: 0.55)]),
    ]

    @State private var currentPage = 0
    @State private var showEmotionEase = false

    var body: some View {
        Group {
            if showEmotionEase {
                EmotionEaseView()
                    .transition(.move(edge: .trailing))
            } else {
                ZStack {
                    TabView(selection: $currentPage) {
                        ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                            SlideView(slide: slide)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea()

                    // Custom page indicator
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            ForEach(0..<slides.count, id: \.self) { index in
                                Capsule()
                                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                            }
                        }
                        .padding(.bottom, 50)

                        // Temp button to preview Emotion Ease screen
                        Button("Next: Build Your Moodboard →") {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showEmotionEase = true
                            }
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.2), in: Capsule())
                        .padding(.bottom, 24)
                    }
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showEmotionEase)
    }
}

struct SlideView: View {
    let slide: CarouselSlide
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(colors: slide.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text(slide.emoji)
                    .font(.system(size: 80))
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appeared)

                Text(slide.greeting)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .offset(y: appeared ? 0 : 30)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: appeared)

                Text(slide.language)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.2), in: Capsule())
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.35), value: appeared)
            }
            .padding()
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }
}

#Preview {
    ContentView()
}
