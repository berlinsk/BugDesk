import SwiftUI

struct CriticalityPicker: View {
    let title: String
    @Binding var selection: Criticality

    @EnvironmentObject private var theme: ThemeManager

    private let items: [Criticality] = Criticality.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            Text(title)
                .font(FontManager.headline())
                .foregroundColor(theme.primaryText)

            HStack(spacing: Constants.Spacing.small) {
                ForEach(items) { item in
                    CriticalityButton(
                        criticality: item,
                        isSelected: selection == item,
                        onSelect: {
                            withAnimation(AnimationManager.spring) {
                                selection = item
                            }
                        }
                    )
                }
            }
        }
        .padding(Constants.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct CriticalityButton: View {
    let criticality: Criticality
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var isPressed = false
    @EnvironmentObject private var theme: ThemeManager

    private var color: Color {
        switch criticality {
        case .highest: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        case .lowest: return .green
        }
    }

    var body: some View {
        Button(action: {
            onSelect()
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
        }) {
            VStack(spacing: Constants.Spacing.tiny) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.2) : theme.tertiaryBackground)
                        .frame(width: 32, height: 32)

                    Circle()
                        .fill(color)
                        .frame(width: isSelected ? 16 : 12, height: isSelected ? 16 : 12)
                }
                .animation(AnimationManager.spring, value: isSelected)

                Text(criticality.rawValue)
                    .font(FontManager.caption())
                    .foregroundColor(isSelected ? theme.primaryText : theme.secondaryText)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.small)
                    .fill(isSelected ? color.opacity(0.1) : theme.tertiaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.small)
                    .strokeBorder(isSelected ? color.opacity(0.5) : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.92 : 1.0)
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
