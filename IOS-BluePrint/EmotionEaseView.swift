//
//  EmotionEaseView.swift
//  IOS-BluePrint
//
//  Emotion Ease onboarding screen — users build a personal moodboard
//  (photos + quotes) to capture who they are and what they love.
//

import SwiftUI
import PhotosUI

// MARK: - Models

enum MoodContent {
    case photo(UIImage)
    case quote(String, Color)
}

struct MoodTile: Identifiable {
    let id = UUID()
    var content: MoodContent? = nil
    let accentColor: Color
    let heightRatio: CGFloat
}

// MARK: - Helpers (module-level so static init works)

private func makeTiles() -> [MoodTile] {
    let lavender = Color(hue: 0.72, saturation: 0.30, brightness: 0.88)
    let teal     = Color(hue: 0.52, saturation: 0.28, brightness: 0.86)
    return [
        MoodTile(accentColor: lavender, heightRatio: 1.8),
        MoodTile(accentColor: teal,     heightRatio: 1.2),
        MoodTile(accentColor: teal,     heightRatio: 1.2),
        MoodTile(accentColor: lavender, heightRatio: 1.8),
        MoodTile(accentColor: lavender, heightRatio: 1.5),
        MoodTile(accentColor: teal,     heightRatio: 1.0),
        MoodTile(accentColor: teal,     heightRatio: 1.1),
        MoodTile(accentColor: lavender, heightRatio: 1.6),
    ]
}

// MARK: - Main View

struct EmotionEaseView: View {

    @State private var tiles: [MoodTile] = makeTiles()

    @State private var pendingTileID: UUID?
    @State private var showActionSheet  = false
    @State private var showPhotoPicker  = false
    @State private var showQuoteSheet   = false
    @State private var photosPickerItems: [PhotosPickerItem] = []
    @State private var quoteText        = ""
    @State private var quoteShakeError  = false
    @State private var didTapContinue   = false

    private let minimumRequired = 3

    var filledCount: Int { tiles.filter { $0.content != nil }.count }
    var canContinue: Bool { filledCount >= minimumRequired }
    var remaining:   Int  { max(0, minimumRequired - filledCount) }

    // MARK: Body
    var body: some View {
        ZStack {
            Color(hue: 0.08, saturation: 0.05, brightness: 0.98)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                    .padding(.top, 56)
                    .padding(.horizontal, 24)

                progressStrip
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                moodboardGrid
                    .padding(.top, 20)
                    .padding(.horizontal, 16)

                Spacer(minLength: 16)

                continueBtn
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $photosPickerItems,
            maxSelectionCount: 1,
            matching: .images
        )
        .onChange(of: photosPickerItems) { _, items in
            loadPhoto(from: items)
        }
        .sheet(isPresented: $showQuoteSheet) {
            quoteSheet
        }
        .confirmationDialog("What would you like to add?",
                            isPresented: $showActionSheet,
                            titleVisibility: .visible) {
            Button("Photo from Library") { showPhotoPicker = true }
            Button("A Quote or Words")   { quoteText = ""; showQuoteSheet = true }
            Button("Cancel", role: .cancel) { pendingTileID = nil }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("This is your space \u{1F33F}")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hue: 0.72, saturation: 0.5, brightness: 0.38))

                    Text("Fill it with photos, places, words \u{2014} anything that feels like you.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }

    // MARK: - Progress Strip

    private var progressStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                let message: String = {
                    if filledCount == 0 {
                        return "Add at least \(minimumRequired) things about yourself"
                    } else if filledCount < minimumRequired {
                        return "\(remaining) more to go \u{2014} you\u{2019}re doing great!"
                    } else {
                        return "Beautiful! Keep going or continue \u{2728}"
                    }
                }()

                Label(message,
                      systemImage: canContinue ? "checkmark.seal.fill" : "sparkles")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(
                        canContinue
                            ? Color(hue: 0.38, saturation: 0.6, brightness: 0.5)
                            : Color(hue: 0.72, saturation: 0.5, brightness: 0.48)
                    )
                    .animation(.easeInOut, value: filledCount)

                Spacer()

                Text("\(filledCount) / \(tiles.count)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hue: 0.72, saturation: 0.2, brightness: 0.92))
                        .frame(height: 6)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: canContinue
                                    ? [Color(hue: 0.38, saturation: 0.6, brightness: 0.7),
                                       Color(hue: 0.45, saturation: 0.5, brightness: 0.65)]
                                    : [Color(hue: 0.72, saturation: 0.55, brightness: 0.72),
                                       Color(hue: 0.58, saturation: 0.40, brightness: 0.78)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(0, geo.size.width * CGFloat(filledCount) / CGFloat(tiles.count)),
                            height: 6
                        )
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: filledCount)
                }
            }
            .frame(height: 6)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Moodboard Grid

    private var leftTiles:  [MoodTile] { stride(from: 0, to: tiles.count, by: 2).map { tiles[$0] } }
    private var rightTiles: [MoodTile] { stride(from: 1, to: tiles.count, by: 2).map { tiles[$0] } }

    private var moodboardGrid: some View {
        GeometryReader { geo in
            let gap: CGFloat = 10
            let colW = (geo.size.width - gap) / 2

            HStack(alignment: .top, spacing: gap) {
                VStack(spacing: gap) {
                    ForEach(leftTiles) { tile in
                        tileCell(tile: tile, width: colW)
                    }
                }
                VStack(spacing: gap) {
                    ForEach(rightTiles) { tile in
                        tileCell(tile: tile, width: colW)
                    }
                }
            }
        }
        .frame(
            height: leftTiles.reduce(0) { $0 + $1.heightRatio * 110 }
                + CGFloat(max(0, leftTiles.count - 1)) * 10
        )
    }

    // MARK: - Tile Cell

    @ViewBuilder
    private func tileCell(tile: MoodTile, width: CGFloat) -> some View {
        let height = tile.heightRatio * 110

        Button {
            pendingTileID = tile.id
            showActionSheet = true
        } label: {
            tileContent(tile: tile, width: width, height: height)
                .frame(width: width, height: height)
                .shadow(color: tile.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(TileButtonStyle())
    }

    @ViewBuilder
    private func tileContent(tile: MoodTile, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(tile.accentColor)

            switch tile.content {
            case .none:
                VStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .light))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Add")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }

            case .photo(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

            case .quote(let text, let bg):
                RoundedRectangle(cornerRadius: 18)
                    .fill(bg)
                    .overlay(
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\u{201C}")
                                .font(.system(size: 32, weight: .black, design: .serif))
                                .foregroundStyle(.white.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 12)
                                .padding(.top, 6)
                            Spacer()
                            Text(text)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 12)
                                .padding(.bottom, 14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    )
            }

            // Border ring
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(.white.opacity(0.35), lineWidth: 1.5)
        }
    }

    // MARK: - Continue Button

    private var continueBtn: some View {
        Button {
            if canContinue {
                didTapContinue = true
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                    quoteShakeError = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    quoteShakeError = false
                }
            }
        } label: {
            HStack(spacing: 10) {
                Text(canContinue ? "Continue" : "Add \(remaining) more to continue")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(
                        canContinue
                            ? .white
                            : Color(hue: 0.72, saturation: 0.4, brightness: 0.5)
                    )

                if canContinue {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                Group {
                    if canContinue {
                        LinearGradient(
                            colors: [Color(hue: 0.72, saturation: 0.55, brightness: 0.72),
                                     Color(hue: 0.58, saturation: 0.45, brightness: 0.78)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .opacity(1)
                    } else {
                        Color(hue: 0.72, saturation: 0.12, brightness: 0.92)
                            .opacity(1)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: canContinue
                    ? Color(hue: 0.72, saturation: 0.5, brightness: 0.6).opacity(0.4)
                    : .clear,
                radius: 12, x: 0, y: 6
            )
            .offset(x: quoteShakeError ? -8 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.4), value: quoteShakeError)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: canContinue)
    }

    // MARK: - Quote Sheet

    private var quoteSheet: some View {
        NavigationStack {
            ZStack {
                Color(hue: 0.08, saturation: 0.05, brightness: 0.98)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Add your words \u{270F}\u{FE0F}")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("A quote, a feeling, a person \u{2014} anything that means something to you.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hue: 0.72, saturation: 0.12, brightness: 0.96))

                        if quoteText.isEmpty {
                            Text("e.g. \u{201C}Be the energy you want to attract\u{201D} or just \u{201C}sunsets\u{201D}")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 18)
                                .padding(.top, 18)
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: $quoteText)
                            .font(.system(size: 16, design: .rounded))
                            .frame(minHeight: 140)
                            .padding(10)
                            .background(Color.clear)
                            .scrollContentBackground(.hidden)
                    }
                    .frame(minHeight: 140)

                    Text("\(min(quoteText.count, 80)) / 80")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Spacer()

                    Button {
                        let trimmed = String(quoteText.prefix(80))
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        applyQuote(text: trimmed)
                        showQuoteSheet = false
                    } label: {
                        Text("Add to Board")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hue: 0.72, saturation: 0.55, brightness: 0.72),
                                             Color(hue: 0.58, saturation: 0.45, brightness: 0.78)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showQuoteSheet = false
                        pendingTileID = nil
                    }
                    .font(.system(size: 15, design: .rounded))
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helpers

    private func loadPhoto(from items: [PhotosPickerItem]) {
        guard let item = items.first, let tileID = pendingTileID else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    applyContent(.photo(image), to: tileID)
                    photosPickerItems = []
                    pendingTileID = nil
                }
            }
        }
    }

    private func applyQuote(text: String) {
        guard let tileID = pendingTileID else { return }
        let quoteColors: [Color] = [
            Color(hue: 0.72, saturation: 0.5,  brightness: 0.62),
            Color(hue: 0.58, saturation: 0.45, brightness: 0.65),
            Color(hue: 0.82, saturation: 0.4,  brightness: 0.68),
            Color(hue: 0.38, saturation: 0.45, brightness: 0.58),
        ]
        let color = quoteColors.randomElement() ?? quoteColors[0]
        applyContent(.quote(text, color), to: tileID)
        pendingTileID = nil
    }

    private func applyContent(_ content: MoodContent, to id: UUID) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            if let idx = tiles.firstIndex(where: { $0.id == id }) {
                tiles[idx].content = content
            }
        }
    }
}

// MARK: - Tile press animation

struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    EmotionEaseView()
}
