import SwiftUI

/// Edge style for one side of a jigsaw piece (flat outer edge, tab protrusion, or blank / notch).
enum GapPuzzleEdge: Equatable {
    case flat
    case tab
    case blank
}

/// Interlocking puzzle piece path (clockwise from top-left).
struct GapJigsawShape: Shape {
    var top: GapPuzzleEdge
    var right: GapPuzzleEdge
    var bottom: GapPuzzleEdge
    var left: GapPuzzleEdge

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let r = min(w, h) * 0.195

        path.move(to: CGPoint(x: 0, y: 0))

        // —— Top (left → right) ——
        switch top {
        case .flat:
            path.addLine(to: CGPoint(x: w, y: 0))
        case .tab:
            path.addLine(to: CGPoint(x: w / 2 - r, y: 0))
            path.addQuadCurve(to: CGPoint(x: w / 2 + r, y: 0), control: CGPoint(x: w / 2, y: -r))
            path.addLine(to: CGPoint(x: w, y: 0))
        case .blank:
            path.addLine(to: CGPoint(x: w / 2 - r, y: 0))
            path.addQuadCurve(to: CGPoint(x: w / 2 + r, y: 0), control: CGPoint(x: w / 2, y: r))
            path.addLine(to: CGPoint(x: w, y: 0))
        }

        // —— Right (top → bottom) ——
        switch right {
        case .flat:
            path.addLine(to: CGPoint(x: w, y: h))
        case .tab:
            path.addLine(to: CGPoint(x: w, y: h / 2 - r))
            path.addQuadCurve(to: CGPoint(x: w, y: h / 2 + r), control: CGPoint(x: w + r, y: h / 2))
            path.addLine(to: CGPoint(x: w, y: h))
        case .blank:
            path.addLine(to: CGPoint(x: w, y: h / 2 - r))
            path.addQuadCurve(to: CGPoint(x: w, y: h / 2 + r), control: CGPoint(x: w - r, y: h / 2))
            path.addLine(to: CGPoint(x: w, y: h))
        }

        // —— Bottom (right → left) ——
        switch bottom {
        case .flat:
            path.addLine(to: CGPoint(x: 0, y: h))
        case .tab:
            path.addLine(to: CGPoint(x: w / 2 + r, y: h))
            path.addQuadCurve(to: CGPoint(x: w / 2 - r, y: h), control: CGPoint(x: w / 2, y: h + r))
            path.addLine(to: CGPoint(x: 0, y: h))
        case .blank:
            path.addLine(to: CGPoint(x: w / 2 + r, y: h))
            path.addQuadCurve(to: CGPoint(x: w / 2 - r, y: h), control: CGPoint(x: w / 2, y: h - r))
            path.addLine(to: CGPoint(x: 0, y: h))
        }

        // —— Left (bottom → top) ——
        switch left {
        case .flat:
            path.addLine(to: CGPoint(x: 0, y: 0))
        case .tab:
            path.addLine(to: CGPoint(x: 0, y: h / 2 + r))
            path.addQuadCurve(to: CGPoint(x: 0, y: h / 2 - r), control: CGPoint(x: -r, y: h / 2))
            path.addLine(to: CGPoint(x: 0, y: 0))
        case .blank:
            path.addLine(to: CGPoint(x: 0, y: h / 2 + r))
            path.addQuadCurve(to: CGPoint(x: 0, y: h / 2 - r), control: CGPoint(x: r, y: h / 2))
            path.addLine(to: CGPoint(x: 0, y: 0))
        }

        path.closeSubpath()
        return path
    }
}

enum GapJigsawCatalog {
    /// Per design reference: Top, Right, Bottom, Left for pieces 1…16.
    static func edges(forPieceNumber n: Int) -> (GapPuzzleEdge, GapPuzzleEdge, GapPuzzleEdge, GapPuzzleEdge) {
        switch n {
        case 1: return (.flat, .blank, .tab, .flat)
        case 2: return (.flat, .blank, .tab, .tab)
        case 3: return (.flat, .blank, .tab, .tab)
        case 4: return (.flat, .flat, .tab, .tab)
        case 5: return (.blank, .tab, .tab, .flat)
        case 6: return (.blank, .tab, .tab, .blank)
        case 7: return (.blank, .tab, .tab, .blank)
        case 8: return (.blank, .flat, .tab, .blank)
        case 9: return (.blank, .blank, .tab, .flat)
        case 10: return (.blank, .blank, .tab, .tab)
        case 11: return (.blank, .blank, .tab, .tab)
        case 12: return (.blank, .flat, .tab, .tab)
        case 13: return (.blank, .tab, .flat, .flat)
        case 14: return (.blank, .tab, .flat, .blank)
        case 15: return (.blank, .tab, .flat, .blank)
        case 16: return (.blank, .flat, .flat, .blank)
        default: return (.flat, .flat, .flat, .flat)
        }
    }

    /// Column-based palette; piece 7 is the lighter “gap” tile.
    static func fillColor(forPieceNumber n: Int) -> Color {
        if n == 7 {
            return Color(red: 0.929, green: 0.965, blue: 0.976) // #EDF6F9
        }
        let col = (n - 1) % 4
        switch col {
        case 0: return Color(red: 0.957, green: 0.655, blue: 0.725) // #F4A7B9
        case 1: return Color(red: 0.784, green: 0.749, blue: 0.906) // #C8BFE7
        case 2: return Color(red: 0.627, green: 0.847, blue: 0.910) // #A0D8E8
        case 3: return Color(red: 0.945, green: 0.612, blue: 0.600) // #F19C99
        default: return Color(red: 0.957, green: 0.655, blue: 0.725)
        }
    }
}
