import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var locale: LocaleManager

    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                floatingShapes(geometry: geometry)

                contentView(geometry: geometry)
            }
        }
        .onAppear {
            withAnimation(AnimationManager.spring.delay(0.1)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                theme.accentColor.opacity(0.1),
                theme.primaryBackground,
                theme.accentColor.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func floatingShapes(geometry: GeometryProxy) -> some View {
        ZStack {
            Circle()
                .fill(theme.accentColor.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -geometry.size.width * 0.3, y: -geometry.size.height * 0.2)

            Circle()
                .fill(theme.accentColor.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: geometry.size.width * 0.3, y: geometry.size.height * 0.3)

            Circle()
                .fill(theme.accentColor.opacity(0.08))
                .frame(width: 150, height: 150)
                .blur(radius: 40)
                .offset(x: geometry.size.width * 0.4, y: -geometry.size.height * 0.4)
        }
    }

    private func contentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: Constants.Spacing.xxlarge) {
            Spacer()

            logoSection
                .scaleEffect(scale)
                .opacity(opacity)

            signInCard(geometry: geometry)
                .scaleEffect(scale)
                .opacity(opacity)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, Constants.Spacing.xlarge)
    }

    private var logoSection: some View {
        VStack(spacing: Constants.Spacing.large) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.accentColor.opacity(0.3),
                                theme.accentColor.opacity(0.1)
                            ],
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
                Text("app.title".localized)
                    .font(FontManager.largeTitle())
                    .foregroundColor(theme.primaryText)
                    .fontWeight(.bold)

                Text("Professional Bug Tracking")
                    .font(FontManager.body())
                    .foregroundColor(theme.secondaryText)
            }
        }
    }

    private func signInCard(geometry: GeometryProxy) -> some View {
        VStack(spacing: Constants.Spacing.xlarge) {
            VStack(spacing: Constants.Spacing.medium) {
                Text("auth.signInPrompt".localized)
                    .font(FontManager.body())
                    .foregroundColor(theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .background(theme.secondaryText.opacity(0.2))
            }

            signInButton
        }
        .padding(Constants.Spacing.xlarge)
        .frame(maxWidth: 400)
        .background(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.xlarge)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.xlarge)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            theme.accentColor.opacity(0.3),
                            theme.accentColor.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var signInButton: some View {
        Group {
            #if os(iOS)
            GoogleSignInButton(action: signIn)
                .frame(height: Constants.Layout.buttonHeight)
                .cornerRadius(Constants.CornerRadius.medium)
            #elseif os(macOS)
            Button(action: signIn) {
                HStack(spacing: Constants.Spacing.medium) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))

                    Text("auth.signInButton".localized)
                        .font(FontManager.headline())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.Layout.buttonHeight)
                .background(
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                        .fill(
                            LinearGradient(
                                colors: [theme.accentColor, theme.accentColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: theme.accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
                )
            }
            .buttonStyle(.plain)
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

    private func signIn() {
        #if os(iOS)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else { return }
        Task {
            await authViewModel.signIn(presentingViewController: rootVC)
        }
        #elseif os(macOS)
        guard let window = NSApp.windows.first else { return }
        Task {
            await authViewModel.signIn(presentingWindow: window)
        }
        #endif
    }
}
