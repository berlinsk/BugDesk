import Foundation
import GoogleSignIn

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

final class AuthRepository: AuthRepositoryProtocol {
    private var isSigningIn = false

    #if os(iOS)
    func signIn(presentingViewController: UIViewController) async throws -> AuthResult {
        guard !isSigningIn else {
            throw DomainError.auth("Sign-in already in progress")
        }

        isSigningIn = true
        defer { isSigningIn = false }

        let config = GIDConfiguration(clientID: APIConfig.clientID)
        GIDSignIn.sharedInstance.configuration = config

        let scopes = [
            "https://www.googleapis.com/auth/drive",
            "https://www.googleapis.com/auth/drive.file",
            "https://www.googleapis.com/auth/spreadsheets"
        ]

        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController,
                hint: nil,
                additionalScopes: scopes
            ) { result, error in
                if let error = error {
                    let nsError = error as NSError
                    if nsError.code == -5 {
                        continuation.resume(throwing: DomainError.auth("Sign-in cancelled by user"))
                    } else {
                        continuation.resume(throwing: DomainError.auth(error.localizedDescription))
                    }
                    return
                }

                guard let user = result?.user else {
                    continuation.resume(throwing: DomainError.auth("No user data"))
                    return
                }

                let authResult = AuthResult(
                    accessToken: user.accessToken.tokenString,
                    userEmail: user.profile?.email ?? ""
                )
                continuation.resume(returning: authResult)
            }
        }
    }
    #elseif os(macOS)
    func signIn(presentingWindow: NSWindow) async throws -> AuthResult {
        guard !isSigningIn else {
            throw DomainError.auth("Sign-in already in progress")
        }

        isSigningIn = true
        defer { isSigningIn = false }

        let config = GIDConfiguration(clientID: APIConfig.clientID)
        GIDSignIn.sharedInstance.configuration = config

        let scopes = [
            "https://www.googleapis.com/auth/drive",
            "https://www.googleapis.com/auth/drive.file",
            "https://www.googleapis.com/auth/spreadsheets"
        ]

        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingWindow,
                hint: nil,
                additionalScopes: scopes
            ) { result, error in
                if let error = error {
                    let nsError = error as NSError
                    if nsError.code == -5 {
                        continuation.resume(throwing: DomainError.auth("Sign-in cancelled by user"))
                    } else {
                        continuation.resume(throwing: DomainError.auth(error.localizedDescription))
                    }
                    return
                }

                guard let user = result?.user else {
                    continuation.resume(throwing: DomainError.auth("No user data"))
                    return
                }

                let authResult = AuthResult(
                    accessToken: user.accessToken.tokenString,
                    userEmail: user.profile?.email ?? ""
                )
                continuation.resume(returning: authResult)
            }
        }
    }
    #endif

    func restorePreviousSignIn() async throws -> AuthResult? {
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let error = error {
                    let nsError = error as NSError
                    if nsError.domain == "com.google.GIDSignIn" && nsError.code == -4 {
                        continuation.resume(returning: nil)
                    } else {
                        continuation.resume(throwing: DomainError.auth(error.localizedDescription))
                    }
                    return
                }

                guard let user else {
                    continuation.resume(returning: nil)
                    return
                }

                let authResult = AuthResult(
                    accessToken: user.accessToken.tokenString,
                    userEmail: user.profile?.email ?? ""
                )
                continuation.resume(returning: authResult)
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}
