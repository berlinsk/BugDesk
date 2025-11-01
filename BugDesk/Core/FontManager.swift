import SwiftUI

enum FontManager {
    static func largeTitle() -> Font {
        #if os(iOS)
        .system(size: 34, weight: .bold, design: .rounded)
        #elseif os(macOS)
        .system(size: 28, weight: .bold, design: .rounded)
        #endif
    }

    static func title() -> Font {
        #if os(iOS)
        .system(size: 28, weight: .bold, design: .rounded)
        #elseif os(macOS)
        .system(size: 22, weight: .bold, design: .rounded)
        #endif
    }

    static func title2() -> Font {
        #if os(iOS)
        .system(size: 22, weight: .semibold, design: .rounded)
        #elseif os(macOS)
        .system(size: 18, weight: .semibold, design: .rounded)
        #endif
    }

    static func headline() -> Font {
        #if os(iOS)
        .system(size: 17, weight: .semibold, design: .rounded)
        #elseif os(macOS)
        .system(size: 15, weight: .semibold, design: .rounded)
        #endif
    }

    static func body() -> Font {
        #if os(iOS)
        .system(size: 17, weight: .regular, design: .rounded)
        #elseif os(macOS)
        .system(size: 13, weight: .regular, design: .rounded)
        #endif
    }

    static func callout() -> Font {
        #if os(iOS)
        .system(size: 16, weight: .regular, design: .rounded)
        #elseif os(macOS)
        .system(size: 12, weight: .regular, design: .rounded)
        #endif
    }

    static func subheadline() -> Font {
        #if os(iOS)
        .system(size: 15, weight: .regular, design: .rounded)
        #elseif os(macOS)
        .system(size: 11, weight: .regular, design: .rounded)
        #endif
    }

    static func footnote() -> Font {
        #if os(iOS)
        .system(size: 13, weight: .regular, design: .rounded)
        #elseif os(macOS)
        .system(size: 10, weight: .regular, design: .rounded)
        #endif
    }

    static func caption() -> Font {
        #if os(iOS)
        .system(size: 12, weight: .regular, design: .rounded)
        #elseif os(macOS)
        .system(size: 9, weight: .regular, design: .rounded)
        #endif
    }

    static func caption2() -> Font {
        #if os(iOS)
        .system(size: 11, weight: .regular, design: .rounded)
        #elseif os(macOS)
        .system(size: 8, weight: .regular, design: .rounded)
        #endif
    }
}
