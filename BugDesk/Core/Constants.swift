import Foundation

enum Constants {
    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
        static let xxlarge: CGFloat = 32
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
    }

    enum Animation {
        static let fast: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
    }

    enum Layout {
        static let maxFormWidth: CGFloat = 600
        static let buttonHeight: CGFloat = 48
        static let chipHeight: CGFloat = 36
        static let minTouchTarget: CGFloat = 44
    }
}
