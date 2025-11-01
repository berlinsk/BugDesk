import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogoutConfirmation = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                theme.primaryBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    customNavBar

                    ScrollView {
                        VStack(spacing: Constants.Spacing.xxlarge) {
                            headerSection

                            menuOptions(geometry: geometry)
                        }
                        .padding(.horizontal, adaptiveHorizontalPadding(geometry))
                        .padding(.vertical, Constants.Spacing.xxlarge)
                    }
                }
            }
        }
        .alert("auth.signOut".localized, isPresented: $showLogoutConfirmation, actions: {
            Button("auth.cancel".localized, role: .cancel) {}
            Button("auth.signOut".localized, role: .destructive) {
                authViewModel.signOut()
            }
        }, message: {
            Text("auth.signOutConfirm".localized)
        })
    }

    private var customNavBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("app.title".localized)
                    .font(FontManager.title2())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.bold)

                Text("menu.welcome".localized)
                    .font(FontManager.caption())
                    .foregroundColor(theme.secondaryText)
            }

            Spacer()

            Button(action: {
                showLogoutConfirmation = true
            }) {
                HStack(spacing: Constants.Spacing.small) {
                    if let email = authViewModel.userEmail {
                        Text(email)
                            .font(FontManager.caption())
                            .foregroundColor(theme.secondaryText)
                            .lineLimit(1)
                    }

                    ZStack {
                        Circle()
                            .fill(theme.accentColor.opacity(0.15))
                            .frame(width: 36, height: 36)

                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(FontManager.callout())
                            .foregroundColor(theme.accentColor)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.Spacing.large)
        .padding(.vertical, Constants.Spacing.medium)
        .background(
            theme.secondaryBackground
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private var headerSection: some View {
        VStack(spacing: Constants.Spacing.large) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.accentColor.opacity(0.3), theme.accentColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Circle()
                    .fill(theme.secondaryBackground)
                    .frame(width: 100, height: 100)
                    .shadow(color: theme.accentColor.opacity(0.3), radius: 20, x: 0, y: 10)

                Image(systemName: "ladybug.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.accentColor, theme.accentColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: Constants.Spacing.small) {
                Text("menu.title".localized)
                    .font(FontManager.largeTitle())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.bold)

                if let email = authViewModel.userEmail {
                    Text(email)
                        .font(FontManager.body())
                        .foregroundColor(theme.secondaryText)
                }
            }
        }
        .fadeIn(delay: 0.1)
    }

    private func menuOptions(geometry: GeometryProxy) -> some View {
        VStack(spacing: Constants.Spacing.large) {
            NavigationLink(destination: ProjectsListView().environmentObject(authViewModel)) {
                MenuCard(
                    icon: "folder.fill",
                    title: "menu.projects".localized,
                    subtitle: "menu.projectsDesc".localized,
                    color: .blue
                )
            }
            #if os(iOS)
            .buttonStyle(.plain)
            #endif
            .fadeIn(delay: 0.2)

            NavigationLink(destination: SettingsView().environmentObject(authViewModel)) {
                MenuCard(
                    icon: "gearshape.fill",
                    title: "menu.settings".localized,
                    subtitle: "menu.settingsDesc".localized,
                    color: .purple
                )
            }
            #if os(iOS)
            .buttonStyle(.plain)
            #endif
            .fadeIn(delay: 0.3)
        }
        .frame(maxWidth: min(geometry.size.width, Constants.Layout.maxFormWidth))
        .frame(maxWidth: .infinity)
    }

    private func adaptiveHorizontalPadding(_ geometry: GeometryProxy) -> CGFloat {
        #if os(iOS)
        return Constants.Spacing.large
        #elseif os(macOS)
        let contentWidth = min(geometry.size.width, Constants.Layout.maxFormWidth)
        return max(Constants.Spacing.large, (geometry.size.width - contentWidth) / 2)
        #endif
    }
}

struct MenuCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    @EnvironmentObject private var theme: ThemeManager
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: Constants.Spacing.large) {
            ZStack {
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .fill(color.opacity(0.15))
                    .frame(width: 64, height: 64)

                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(alignment: .leading, spacing: Constants.Spacing.tiny) {
                Text(title)
                    .font(FontManager.title2())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(FontManager.callout())
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(FontManager.body())
                .foregroundColor(theme.secondaryText)
        }
        .padding(Constants.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                .fill(theme.secondaryBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AnimationManager.spring, value: isPressed)
        #if os(iOS)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        #elseif os(macOS)
        .onHover { hovering in
            isPressed = hovering
        }
        #endif
    }
}
