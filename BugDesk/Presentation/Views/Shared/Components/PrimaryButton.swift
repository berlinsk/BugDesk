import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var isEnabled: Bool = true

    @State private var isPressed = false
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        Button(action: {
            action()
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
        }) {
            HStack(spacing: Constants.Spacing.medium) {
                Image(systemName: icon)
                    .font(FontManager.headline())

                Text(title)
                    .font(FontManager.headline())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: Constants.Layout.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .fill(
                        LinearGradient(
                            colors: isEnabled ? [
                                theme.accentColor,
                                theme.accentColor.opacity(0.8)
                            ] : [
                                theme.secondaryText.opacity(0.3),
                                theme.secondaryText.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: isEnabled ? theme.accentColor.opacity(0.3) : Color.clear,
                        radius: 12,
                        x: 0,
                        y: 6
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isEnabled {
                        withAnimation(AnimationManager.fast) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(AnimationManager.fast) {
                        isPressed = false
                    }
                }
        )
        #if os(macOS)
        .onHover { hovering in
            if hovering && isEnabled {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        #endif
    }
}
