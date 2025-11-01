import SwiftUI
import PhotosUI

struct ModernAttachmentPicker: View {
    let title: String
    @Binding var items: [PhotosPickerItem]
    let attachments: [Attachment]
    let onSelect: () -> Void

    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            Text(title)
                .font(FontManager.headline())
                .foregroundColor(theme.primaryText)

            PhotosPicker(
                selection: $items,
                maxSelectionCount: 10,
                matching: .any(of: [.images, .videos])
            ) {
                HStack(spacing: Constants.Spacing.medium) {
                    ZStack {
                        Circle()
                            .fill(theme.accentColor.opacity(0.15))
                            .frame(width: 48, height: 48)

                        Image(systemName: "photo.stack.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("attachments.select".localized)
                            .font(FontManager.body())
                            .foregroundColor(theme.primaryText)
                            .fontWeight(.medium)

                        Text("attachments.upTo".localized)
                            .font(FontManager.caption())
                            .foregroundColor(theme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(FontManager.body())
                        .foregroundColor(theme.secondaryText)
                }
                .padding(Constants.Spacing.large)
                .background(
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                        .fill(theme.tertiaryBackground)
                )
            }
            .onChange(of: items) { _ in
                onSelect()
            }

            if !attachments.isEmpty {
                VStack(spacing: Constants.Spacing.small) {
                    ForEach(attachments) { attachment in
                        AttachmentRow(attachment: attachment)
                    }
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

struct AttachmentRow: View {
    let attachment: Attachment

    @EnvironmentObject private var theme: ThemeManager

    private var icon: String {
        attachment.mimeType.starts(with: "video") ? "video.fill" : "photo.fill"
    }

    private var iconColor: Color {
        attachment.mimeType.starts(with: "video") ? .purple : .blue
    }

    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: Constants.CornerRadius.small)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.filename)
                    .font(FontManager.callout())
                    .foregroundColor(theme.primaryText)
                    .lineLimit(1)

                Text(attachment.mimeType)
                    .font(FontManager.caption())
                    .foregroundColor(theme.secondaryText)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(FontManager.body())
                .foregroundColor(.green)
        }
        .padding(Constants.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                .fill(theme.tertiaryBackground)
        )
    }
}
