import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var accessToken: String?
    @Published var userEmail: String?

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    #if os(iOS)
    func signIn(presentingViewController: UIViewController) async {
        do {
            let result = try await authRepository.signIn(presentingViewController: presentingViewController)
            self.isSignedIn = true
            self.userEmail = result.userEmail
            self.accessToken = result.accessToken
        } catch {
            print("Sign-in error:", error.localizedDescription)
        }
    }
    #elseif os(macOS)
    func signIn(presentingWindow: NSWindow) async {
        do {
            let result = try await authRepository.signIn(presentingWindow: presentingWindow)
            self.isSignedIn = true
            self.userEmail = result.userEmail
            self.accessToken = result.accessToken
        } catch {
            print("Sign-in error:", error.localizedDescription)
        }
    }
    #endif

    func restorePreviousSignIn() async {
        do {
            if let result = try await authRepository.restorePreviousSignIn() {
                self.isSignedIn = true
                self.userEmail = result.userEmail
                self.accessToken = result.accessToken
            }
        } catch {
            print("Could not restore session:", error.localizedDescription)
        }
    }

    func signOut() {
        authRepository.signOut()
        self.isSignedIn = false
        self.accessToken = nil
        self.userEmail = nil
    }
}
