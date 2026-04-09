import SwiftUI

extension View {
    /// Limite la longueur d'un texte bindé (pour TextEditor)
    func textLimit(_ text: Binding<String>, max: Int = 5000) -> some View {
        self.onChange(of: text.wrappedValue) {
            if text.wrappedValue.count > max {
                text.wrappedValue = String(text.wrappedValue.prefix(max))
            }
        }
    }
}
