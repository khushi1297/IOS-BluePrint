import SwiftUI
import UIKit

/// Canva / Figma typography for Canvas life-area cards.
enum CanvasTypography {
    private static let familyName = "Alumni Sans"
    private static let boldPostScriptName = "AlumniSansRoman-Bold"

    static var isAlumniSansAvailable: Bool {
        UIFont(name: boldPostScriptName, size: 26) != nil
            || !UIFont.fontNames(forFamilyName: familyName).isEmpty
    }

    /// Alumni Sans 26pt bold — matches Canva export; falls back to system bold if font missing.
    static func lifeAreaTitle() -> Font {
        if UIFont(name: boldPostScriptName, size: 26) != nil {
            return .custom(boldPostScriptName, size: 26)
        }
        if !UIFont.fontNames(forFamilyName: familyName).isEmpty {
            return .custom(familyName, size: 26).weight(.bold)
        }
        return .system(size: 26, weight: .bold)
    }
}
