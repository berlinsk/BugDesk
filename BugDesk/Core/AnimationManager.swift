import SwiftUI

enum AnimationManager {
    static var spring: Animation {
        .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    }

    static var easeInOut: Animation {
        .easeInOut(duration: Constants.Animation.standard)
    }

    static var easeOut: Animation {
        .easeOut(duration: Constants.Animation.standard)
    }

    static var fast: Animation {
        .easeInOut(duration: Constants.Animation.fast)
    }

    static var slow: Animation {
        .easeInOut(duration: Constants.Animation.slow)
    }

    static var bouncy: Animation {
        .interpolatingSpring(stiffness: 170, damping: 15)
    }

    static var smooth: Animation {
        .interactiveSpring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.25)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(AnimationManager.spring, value: configuration.isPressed)
    }
}

struct FadeInModifier: ViewModifier {
    @State private var isVisible = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .onAppear {
                withAnimation(AnimationManager.easeOut.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }

    func scaleButtonStyle() -> some View {
        buttonStyle(ScaleButtonStyle())
    }
}
