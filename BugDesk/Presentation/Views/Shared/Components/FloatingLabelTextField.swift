import SwiftUI

struct FloatingLabelTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var lineLimit: ClosedRange<Int> = 1...1

    @FocusState private var isFocused: Bool
    @EnvironmentObject private var theme: ThemeManager

    private var isActive: Bool {
        isFocused || !text.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                TextField("", text: $text, axis: axis)
                    .lineLimit(lineLimit)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .padding(.top, isActive ? 20 : 0)
                    .padding(.horizontal, Constants.Spacing.large)
                    .padding(.vertical, Constants.Spacing.medium)
                    .font(FontManager.body())
                    .foregroundColor(theme.primaryText)
                    .animation(AnimationManager.spring, value: isActive)

                Text(isActive ? title : placeholder)
                    .font(isActive ? FontManager.caption() : FontManager.body())
                    .foregroundColor(isFocused ? theme.accentColor : theme.secondaryText)
                    .padding(.horizontal, Constants.Spacing.large)
                    .padding(.top, isActive ? Constants.Spacing.small : Constants.Spacing.medium)
                    .animation(AnimationManager.spring, value: isActive)
                    .allowsHitTesting(false)
            }
            .frame(minHeight: lineLimit.upperBound > 1 ? CGFloat(lineLimit.upperBound) * 24 + 32 : 56)
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .fill(theme.secondaryBackground)
                    .shadow(color: isFocused ? theme.accentColor.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .strokeBorder(
                        isFocused ? theme.accentColor : theme.secondaryBackground.opacity(0.5),
                        lineWidth: isFocused ? 2 : 1
                    )
            )
            .animation(AnimationManager.spring, value: isFocused)
        }
    }
}
