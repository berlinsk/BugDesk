import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            theme.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                customNavBar

                ScrollView {
                    VStack(spacing: Constants.Spacing.large) {
                        languageSection
                        storageSection
                        aboutSection
                    }
                    .padding(Constants.Spacing.large)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    @Environment(\.dismiss) private var dismiss

    private var customNavBar: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(FontManager.title2())
                    .foregroundColor(theme.accentColor)
            }
            .buttonStyle(.plain)

            Text("settings.title".localized)
                .font(FontManager.largeTitle())
                .foregroundColor(theme.primaryText)
                .fontWeight(.bold)

            Spacer()
        }
        .padding(.horizontal, Constants.Spacing.large)
        .padding(.vertical, Constants.Spacing.medium)
        .background(
            theme.secondaryBackground
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            sectionHeader(
                icon: "globe",
                title: "settings.language".localized,
                subtitle: "settings.languageDesc".localized
            )

            VStack(spacing: Constants.Spacing.small) {
                ForEach(Language.allCases) { language in
                    LanguageRow(language: language)
                }
            }
        }
        .padding(Constants.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .fadeIn(delay: 0.1)
    }

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            sectionHeader(
                icon: "internaldrive",
                title: "Data Storage",
                subtitle: "Your data is stored locally per account"
            )

            VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                if let email = authViewModel.userEmail {
                    HStack {
                        VStack(alignment: .leading, spacing: Constants.Spacing.tiny) {
                            Text("Current Account")
                                .font(FontManager.caption())
                                .foregroundColor(theme.secondaryText)

                            Text(email)
                                .font(FontManager.body())
                                .foregroundColor(theme.primaryText)
                                .fontWeight(.medium)
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

                Text("Each account has its own isolated database. Switch accounts to access different projects.")
                    .font(FontManager.caption())
                    .foregroundColor(theme.secondaryText)
                    .padding(.top, Constants.Spacing.tiny)
            }
        }
        .padding(Constants.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .fadeIn(delay: 0.15)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            sectionHeader(
                icon: "info.circle",
                title: "settings.about".localized,
                subtitle: ""
            )

            HStack {
                VStack(alignment: .leading, spacing: Constants.Spacing.tiny) {
                    Text("app.title".localized)
                        .font(FontManager.body())
                        .foregroundColor(theme.primaryText)
                        .fontWeight(.medium)

                    Text("app.subtitle".localized)
                        .font(FontManager.caption())
                        .foregroundColor(theme.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: Constants.Spacing.tiny) {
                    Text("settings.version".localized)
                        .font(FontManager.caption())
                        .foregroundColor(theme.secondaryText)

                    Text(appVersion)
                        .font(FontManager.body())
                        .foregroundColor(theme.primaryText)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(Constants.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .fadeIn(delay: 0.25)
    }

    private func sectionHeader(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: Constants.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(theme.accentColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(FontManager.title2())
                    .foregroundColor(theme.accentColor)
            }

            VStack(alignment: .leading, spacing: Constants.Spacing.tiny) {
                Text(title)
                    .font(FontManager.title2())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.semibold)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(FontManager.callout())
                        .foregroundColor(theme.secondaryText)
                }
            }

            Spacer()
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

struct LanguageRow: View {
    let language: Language

    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(AnimationManager.spring) {
                locale.currentLanguage = language
            }

            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
        }) {
            HStack(spacing: Constants.Spacing.medium) {
                Text(language.flag)
                    .font(.system(size: 28))

                Text(language.displayName)
                    .font(FontManager.body())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.medium)

                Spacer()

                if locale.currentLanguage == language {
                    Image(systemName: "checkmark.circle.fill")
                        .font(FontManager.title2())
                        .foregroundColor(theme.accentColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(Constants.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .fill(locale.currentLanguage == language ? theme.accentColor.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .strokeBorder(
                        locale.currentLanguage == language ? theme.accentColor : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AnimationManager.spring, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
