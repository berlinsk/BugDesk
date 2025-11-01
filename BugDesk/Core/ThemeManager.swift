import SwiftUI

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var isDarkMode: Bool = false

    private init() {
        #if os(iOS)
        isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        #elseif os(macOS)
        isDarkMode = NSApp.effectiveAppearance.name == .darkAqua
        #endif
    }

    var primaryBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    var secondaryBackground: Color {
        #if os(iOS)
        Color(uiColor: .secondarySystemBackground)
        #elseif os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #endif
    }

    var tertiaryBackground: Color {
        #if os(iOS)
        Color(uiColor: .tertiarySystemBackground)
        #elseif os(macOS)
        Color(nsColor: .textBackgroundColor)
        #endif
    }

    var primaryText: Color {
        Color.primary
    }

    var secondaryText: Color {
        Color.secondary
    }

    var accentColor: Color {
        Color.accentColor
    }

    var successColor: Color {
        Color.green
    }

    var errorColor: Color {
        Color.red
    }

    var warningColor: Color {
        Color.orange
    }

    var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                accentColor.opacity(0.1),
                accentColor.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var subtleGradient: LinearGradient {
        LinearGradient(
            colors: [
                primaryBackground,
                secondaryBackground
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
