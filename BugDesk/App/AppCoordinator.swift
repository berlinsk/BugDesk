import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var currentView: AppView = .auth

    enum AppView {
        case auth
        case reports
    }

    func navigate(to view: AppView) {
        withAnimation(AnimationManager.easeInOut) {
            currentView = view
        }
    }
}
