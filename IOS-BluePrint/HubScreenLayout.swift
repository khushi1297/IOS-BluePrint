import SwiftUI

// MARK: - Hub screen chrome (CTA above global bottom nav)

enum HubChromeMetrics {
    /// Figma reference frame width — content is centered when the device is wider.
    static let designContentWidth: CGFloat = 402

    /// `HighVoltageNavBar` capsule height.
    static let navBarHeight: CGFloat = 68
    /// Space between scroll content / CTA and the top of the floating nav capsule.
    static let ctaGapAboveNavBar: CGFloat = 20
    /// Matches `ContentView` nav stack (padding above the capsule).
    static let navBarStackTopPadding: CGFloat = 6
    static let navBarBottomPadding: CGFloat = 10

    /// Typical primary CTA (Continue) block height including vertical padding.
    static let ctaBlockHeight: CGFloat = 56
    static let ctaFooterVerticalPadding: CGFloat = 18

    /// Extra scroll padding when content scrolls above a pinned CTA footer.
    static let scrollTailPadding: CGFloat = 16

    /// Height of the floating bottom nav stack (excluding the CTA gap).
    static func bottomNavReservedHeight(safeAreaBottom: CGFloat) -> CGFloat {
        navBarHeight + navBarStackTopPadding + max(safeAreaBottom, navBarBottomPadding)
    }

    /// Bottom inset so pinned CTAs sit at least `ctaGapAboveNavBar` above the nav capsule.
    static func ctaFooterBottomPadding(safeAreaBottom: CGFloat) -> CGFloat {
        ctaGapAboveNavBar + bottomNavReservedHeight(safeAreaBottom: safeAreaBottom)
    }

    /// Canvas has no page CTA — only reserve space for the global bottom nav.
    static func canvasScrollBottomInset(safeAreaBottom: CGFloat) -> CGFloat {
        bottomNavReservedHeight(safeAreaBottom: safeAreaBottom) + 12
    }

    static func centeredColumnWidth(in screenWidth: CGFloat) -> CGFloat {
        min(screenWidth, designContentWidth)
    }
}

/// Pinned footer region for hub screens — sits above `ContentView`'s bottom nav inset.
struct HubCTAFooter<Content: View>: View {
    var background: Color
    /// When nil, no extra bottom padding (hub screens get clearance from `ContentView`).
    var bottomPadding: CGFloat?
    @ViewBuilder var content: () -> Content

    init(
        background: Color = .clear,
        bottomPadding: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.background = background
        self.bottomPadding = bottomPadding
        self.content = content
    }

    var body: some View {
        VStack(spacing: 12) {
            content()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, bottomPadding ?? 0)
        .frame(maxWidth: .infinity)
        .background(background)
    }
}

/// Standard hub page shell: scrollable body + CTA footer (nav is applied in `ContentView`).
struct HubScreenLayout<Content: View, Footer: View>: View {
    let background: Color
    @ViewBuilder let content: () -> Content
    @ViewBuilder let footer: () -> Footer

    var body: some View {
        VStack(spacing: 0) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            HubCTAFooter(background: background) {
                footer()
            }
        }
        .background(background.ignoresSafeArea())
    }
}
