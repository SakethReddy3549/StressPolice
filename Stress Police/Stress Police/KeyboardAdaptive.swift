import SwiftUI
import Combine

private struct KeyboardAdaptiveModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { height in
                withAnimation(.easeOut(duration: 0.25)) {
                    self.keyboardHeight = height
                }
            }
    }
}

extension View {
    func keyboardAdaptive(extraPadding: CGFloat = 0) -> some View {
        self.modifier(KeyboardAdaptiveModifier())
    }
}

