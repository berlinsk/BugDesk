import SwiftUI

struct ImprovedTextField<Field: Hashable>: View {
    let text: Binding<String>
    let label: String
    let placeholder: String
    var axis: Axis = .horizontal
    var lineLimit: Int = 1
    let field: Field
    let focusedField: FocusState<Field?>.Binding

    @EnvironmentObject private var theme: ThemeManager

    init(text: Binding<String>, label: String, placeholder: String, axis: Axis = .horizontal, lineLimit: Int = 1, field: Field, focusedField: FocusState<Field?>.Binding) {
        self.text = text
        self.label = label
        self.placeholder = placeholder
        self.axis = axis
        self.lineLimit = lineLimit
        self.field = field
        self.focusedField = focusedField
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            Text(label)
                .font(FontManager.subheadline())
                .foregroundColor(theme.secondaryText)
                .fontWeight(.medium)

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(FontManager.body())
                        .foregroundColor(theme.secondaryText.opacity(0.5))
                        .padding(.horizontal, Constants.Spacing.large)
                        .padding(.vertical, Constants.Spacing.medium)
                        .allowsHitTesting(false)
                }

                if axis == .vertical {
                    TextEditor(text: text)
                        .font(FontManager.body())
                        .foregroundColor(theme.primaryText)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, Constants.Spacing.medium)
                        .padding(.vertical, Constants.Spacing.small)
                        .frame(minHeight: CGFloat(lineLimit) * 24 + 20)
                        .focused(focusedField, equals: field)
                } else {
                    TextField("", text: text)
                        .font(FontManager.body())
                        .foregroundColor(theme.primaryText)
                        .padding(.horizontal, Constants.Spacing.large)
                        .padding(.vertical, Constants.Spacing.medium)
                        .focused(focusedField, equals: field)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .fill(theme.tertiaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .strokeBorder(
                        focusedField.wrappedValue == field ? theme.accentColor : theme.secondaryText.opacity(0.1),
                        lineWidth: focusedField.wrappedValue == field ? 2 : 1
                    )
            )
            .shadow(
                color: focusedField.wrappedValue == field ? theme.accentColor.opacity(0.2) : Color.clear,
                radius: focusedField.wrappedValue == field ? 8 : 0,
                x: 0,
                y: 4
            )
            .animation(AnimationManager.spring, value: focusedField.wrappedValue == field)
        }
        .padding(Constants.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}
