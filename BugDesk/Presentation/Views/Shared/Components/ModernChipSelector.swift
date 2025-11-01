import SwiftUI

struct ModernChipSelector<T: Identifiable & Hashable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    let items: [T]
    @Binding var selected: Set<T>

    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            Text(title)
                .font(FontManager.headline())
                .foregroundColor(theme.primaryText)

            FlexibleWrap(items: items, spacing: Constants.Spacing.small, runSpacing: Constants.Spacing.small) { item in
                ModernChip(
                    title: item.rawValue,
                    isSelected: selected.contains(item),
                    onTap: {
                        withAnimation(AnimationManager.spring) {
                            if selected.contains(item) {
                                selected.remove(item)
                            } else {
                                selected.insert(item)
                            }
                        }
                    }
                )
            }
            .frame(height: calculateHeight())
        }
        .padding(Constants.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private func calculateHeight() -> CGFloat {
        let itemsPerRow = 2
        let rows = (items.count + itemsPerRow - 1) / itemsPerRow
        return CGFloat(rows) * 44 + CGFloat(max(0, rows - 1)) * Constants.Spacing.small
    }
}

struct ModernChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        Button(action: {
            onTap()
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif
        }) {
            HStack(spacing: Constants.Spacing.small) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? theme.accentColor : theme.secondaryText.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(theme.accentColor)
                            .frame(width: 12, height: 12)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(AnimationManager.spring, value: isSelected)

                Text(title)
                    .font(FontManager.body())
                    .foregroundColor(isSelected ? theme.primaryText : theme.secondaryText)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, Constants.Spacing.large)
            .padding(.vertical, Constants.Spacing.medium)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .fill(isSelected ? theme.accentColor.opacity(0.15) : theme.tertiaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .strokeBorder(
                        isSelected ? theme.accentColor.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(AnimationManager.fast) {
                        isPressed = true
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
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        #endif
    }
}
