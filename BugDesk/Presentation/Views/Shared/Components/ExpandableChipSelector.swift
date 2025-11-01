import SwiftUI

struct ExpandableChipSelector<T: Identifiable & Hashable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    let placeholder: String
    let items: [T]
    @Binding var selected: Set<T>

    @State private var isExpanded: Bool = false
    @EnvironmentObject private var theme: ThemeManager

    private var selectedText: String {
        if selected.isEmpty {
            return placeholder
        }
        return selected.map { $0.rawValue }.sorted().joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: 0) {
            headerButton

            if isExpanded {
                chipsContent
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                    ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(isExpanded ? 0.1 : 0.05), radius: isExpanded ? 16 : 8, x: 0, y: isExpanded ? 8 : 2)
        )
        .animation(AnimationManager.spring, value: isExpanded)
    }

    private var headerButton: some View {
        Button(action: {
            withAnimation(AnimationManager.spring) {
                isExpanded.toggle()
            }
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif
        }) {
            HStack(spacing: Constants.Spacing.medium) {
                VStack(alignment: .leading, spacing: Constants.Spacing.tiny) {
                    Text(title)
                        .font(FontManager.headline())
                        .foregroundColor(theme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(selectedText)
                        .font(FontManager.callout())
                        .foregroundColor(selected.isEmpty ? theme.secondaryText : theme.accentColor)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(theme.accentColor.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: "chevron.down")
                        .font(FontManager.body())
                        .foregroundColor(theme.accentColor)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(AnimationManager.spring, value: isExpanded)
                }
            }
            .padding(Constants.Spacing.large)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

    private var chipsContent: some View {
        VStack(spacing: 0) {
            Divider()
                .background(theme.secondaryText.opacity(0.1))

            VStack(spacing: Constants.Spacing.small) {
                ForEach(items) { item in
                    ExpandableChip(
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
                            #if os(iOS)
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            #endif
                        }
                    )
                }
            }
            .padding(Constants.Spacing.large)
        }
    }
}

struct ExpandableChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Constants.Spacing.medium) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? theme.accentColor : theme.secondaryText.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(theme.accentColor)
                            .frame(width: 14, height: 14)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(AnimationManager.spring, value: isSelected)

                Text(title)
                    .font(FontManager.body())
                    .foregroundColor(isSelected ? theme.primaryText : theme.secondaryText)
                    .fontWeight(isSelected ? .semibold : .regular)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(FontManager.callout())
                        .foregroundColor(theme.accentColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, Constants.Spacing.large)
            .padding(.vertical, Constants.Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .fill(isSelected ? theme.accentColor.opacity(0.1) : theme.tertiaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .strokeBorder(
                        isSelected ? theme.accentColor.opacity(0.3) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
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
