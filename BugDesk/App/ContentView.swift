import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel(authRepository: DIContainer.shared.makeAuthRepository())
    @StateObject private var dataManager = SwiftDataManager.shared
    @StateObject private var theme = ThemeManager.shared
    @StateObject private var locale = LocaleManager.shared

    var body: some View {
        Group {
            if authViewModel.isSignedIn, let email = authViewModel.userEmail {
                if let container = dataManager.currentContainer {
                    NavigationStack {
                        MainMenuView()
                            .environmentObject(authViewModel)
                    }
                    .modelContainer(container)
                } else {
                    ProgressView("Loading...")
                        .onAppear {
                            setupDataContainer(for: email)
                        }
                }
            } else {
                AuthView(authViewModel: authViewModel)
            }
        }
        .environmentObject(theme)
        .environmentObject(locale)
        .onChange(of: authViewModel.isSignedIn) { oldValue, newValue in
            if newValue, let email = authViewModel.userEmail {
                print("📝 User signed in: \(email)")
                setupDataContainer(for: email)
            } else {
                print("📝 User signed out")
                dataManager.clearContainer()
            }
        }
        .onChange(of: authViewModel.userEmail) { oldValue, newValue in
            if let email = newValue, authViewModel.isSignedIn {
                print("📝 User email changed: \(email)")
                setupDataContainer(for: email)
            }
        }
        .onAppear {
            Task {
                await authViewModel.restorePreviousSignIn()

                if authViewModel.isSignedIn, let email = authViewModel.userEmail {
                    setupDataContainer(for: email)
                }
            }
        }
    }

    private func setupDataContainer(for email: String) {
        Task { @MainActor in
            dataManager.setupContainer(for: email)
        }
    }
}
