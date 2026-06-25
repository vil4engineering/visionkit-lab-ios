import SwiftUI

enum Theme {
    enum Spacing {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
    }

    enum ColorRole {
        static let accent = SwiftUI.Color.accentColor
    }

    enum FontRole {
        static let heroTitle = Font.title2.weight(.semibold)
        static let cardTitle = Font.headline
        static let body = Font.body
        static let caption = Font.caption
    }
}
