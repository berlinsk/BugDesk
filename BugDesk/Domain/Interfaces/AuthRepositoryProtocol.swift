import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

protocol AuthRepositoryProtocol {
    #if os(iOS)
    func signIn(presentingViewController: UIViewController) async throws -> AuthResult
    #elseif os(macOS)
    func signIn(presentingWindow: NSWindow) async throws -> AuthResult
    #endif

    func restorePreviousSignIn() async throws -> AuthResult?
    func signOut()
}
