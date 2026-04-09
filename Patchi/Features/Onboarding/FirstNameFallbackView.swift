import SwiftUI

/// Affiché quand Sign in with Apple réussit mais ne renvoie pas de `givenName`
/// (cas d'un 2e sign-in sur le même appareil, ou quand l'utilisateur a masqué
/// son nom chez Apple).
///
/// Le nom est optionnel côté Apple — on demande donc nous-mêmes à l'utilisateur
/// de se présenter, avec un ton cohérent avec le reste de l'onboarding.
struct FirstNameFallbackView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String = ""
    @FocusState private var isFocused: Bool

    let onComplete: (_ firstName: String) -> Void

    private var canSubmit: Bool { !firstName.isBlank }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Avant qu'on continue…")
                        .font(.patchiDisplay(28, weight: .semibold))
                        .multilineTextAlignment(.center)

                    Text("Comment tu préfères qu'on t'appelle ?")
                        .font(.patchiDisplay(16, weight: .regular))
                        .foregroundStyle(Color.mdTextGray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                TextField("Ton prénom", text: $firstName)
                    .font(.patchiDisplay(22, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.mdBgSubtle)
                    )
                    .padding(.horizontal, 32)
                    .onSubmit {
                        if canSubmit { submit() }
                    }

                Spacer()

                PillButton(title: "Continuer", style: .dark) { submit() }
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1 : 0.3)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
            }
            .background(Color.mdBgSubtle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .focusAfter(.milliseconds(300)) { isFocused = true }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func submit() {
        let cleaned = firstName.trimmed
        guard !cleaned.isEmpty else { return }
        onComplete(cleaned)
        dismiss()
    }
}

#Preview {
    FirstNameFallbackView { name in
        print("firstName:", name)
    }
}
