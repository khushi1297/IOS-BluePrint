import SwiftUI

// MARK: - Mood asset icons (header chips)

/// Pill artwork from Assets (`mood_good`, `mood_normal`, `mood_low`, `mood_rough`).
struct MoodAssetIcon: View {
    let mood: CanvasMood
    var height: CGFloat = 22
    var maxWidth: CGFloat = 72

    var body: some View {
        Image(mood.pickerImageName)
            .resizable()
            .renderingMode(.original)
            .scaledToFit()
            .frame(maxWidth: maxWidth)
            .frame(height: height)
            .accessibilityHidden(true)
    }
}

// MARK: - Mood accent colors (prototype reference)

enum MoodScreenAccent {
  // Good — warm gold (#F9D976)
  static let goodTitle = Color(red: 0.98, green: 0.85, blue: 0.46)

  // Normal / Steady — sky cyan (#7ED9E6)
  static let normalTitle = Color(red: 0.49, green: 0.85, blue: 0.90)

  // Rough — coral pink (#FF6B7D)
  static let roughTitle = Color(red: 1.0, green: 0.42, blue: 0.49)

  static func titleColor(for mood: CanvasMood) -> Color {
    switch mood {
    case .good: goodTitle
    case .normal: normalTitle
    case .rough: roughTitle
    case .low: Color(red: 0.68, green: 0.52, blue: 0.82)
    }
  }
}

extension CanvasMood {
  /// “Today's task”, “Steady win.”, etc. — color matches checked-in mood.
  @ViewBuilder
  func styledScreenTitle(
    _ text: String,
    size: CGFloat,
    weight: Font.Weight = .bold,
    tracking: CGFloat = 0
  ) -> some View {
    Text(text)
      .font(.system(size: size, weight: weight, design: .rounded))
      .foregroundStyle(MoodScreenAccent.titleColor(for: self))
      .tracking(tracking)
      .multilineTextAlignment(.center)
  }
}

// MARK: - Progress badge (Canvas + optional reuse)

enum CanvasProgressBadgeDesign {
  static let fill = Color(red: 0.94, green: 0.91, blue: 0.98)
  static let border = Color(red: 0.78, green: 0.72, blue: 0.88)
  static let track = Color(red: 0.82, green: 0.78, blue: 0.90)
  static let arc = Color(red: 0.52, green: 0.38, blue: 0.68)
  static let text = Color(red: 0.28, green: 0.24, blue: 0.34)
}

struct CanvasProgressBadge: View {
  let completed: Int
  let total: Int

  private var progress: Double {
    guard total > 0 else { return 0 }
    return min(1, max(0, Double(completed) / Double(total)))
  }

  var body: some View {
    HStack(spacing: 8) {
      ZStack {
        Circle()
          .stroke(
            CanvasProgressBadgeDesign.track,
            style: StrokeStyle(lineWidth: 2.25, lineCap: .round)
          )

        Circle()
          .trim(from: 0, to: progress)
          .stroke(
            CanvasProgressBadgeDesign.arc,
            style: StrokeStyle(lineWidth: 2.25, lineCap: .butt)
          )
          .rotationEffect(.degrees(-90))
      }
      .frame(width: 15, height: 15)

      Text("\(completed) of \(total) steps")
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundStyle(CanvasProgressBadgeDesign.text)
        .fixedSize()
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 7)
    .background(CanvasProgressBadgeDesign.fill)
    .clipShape(Capsule())
    .overlay(
      Capsule()
        .strokeBorder(CanvasProgressBadgeDesign.border, lineWidth: 1)
    )
  }
}
