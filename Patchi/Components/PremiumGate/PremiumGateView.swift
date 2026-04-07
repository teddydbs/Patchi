import SwiftUI

/// Gate premium — affiche un overlay si l'utilisateur n'est pas premium
struct PremiumGate<Content: View>: View {
    @Environment(AppState.self) private var appState
    let feature: String
    @ViewBuilder let content: Content

    @State private var showPremium = false

    var body: some View {
        if appState.isPremium {
            content
        } else {
            ZStack {
                content
                    .blur(radius: 6)
                    .allowsHitTesting(false)

                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.orange)

                    Text("Disponible avec Patchi Premium")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(feature)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button {
                        showPremium = true
                    } label: {
                        Text("Découvrir Premium")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.patchiOrange)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.input, style: .continuous))
                    }
                }
                .padding(24)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                }
            }
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
        }
    }
}

// MARK: - Premium View

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var storeKit = StoreKitService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Patchi
                    PatchiWithBubble(
                        expression: .happy,
                        text: "7 jours pour voir si ça te parle. Pas de carte bancaire.",
                        patchiSize: .large,
                        bubbleStyle: .emotional
                    )

                    // Features premium
                    VStack(alignment: .leading, spacing: 14) {
                        PremiumFeatureRow(icon: "infinity", text: "Historique complet illimité")
                        PremiumFeatureRow(icon: "magnifyingglass", text: "Recherche par mot-clé")
                        PremiumFeatureRow(icon: "chart.bar.fill", text: "Corrélations avancées")
                        PremiumFeatureRow(icon: "square.grid.2x2.fill", text: "Widgets iOS")
                        PremiumFeatureRow(icon: "faceid", text: "Verrou biométrique")
                        PremiumFeatureRow(icon: "icloud.fill", text: "Sauvegarde cloud chiffrée")
                        PremiumFeatureRow(icon: "paintpalette.fill", text: "Thèmes visuels")
                        PremiumFeatureRow(icon: "quote.bubble.fill", text: "Citations personnalisées")
                    }
                    .padding(.horizontal, 20)

                    // Prix
                    VStack(spacing: 8) {
                        Text(storeKit.priceString + "/an")
                            .font(.title2)
                            .fontWeight(.bold)

                        if storeKit.hasTrialOffer {
                            Text("7 jours d'essai gratuit")
                                .font(.caption)
                                .foregroundStyle(.green)
                                .fontWeight(.medium)
                        }
                    }

                    // Bouton achat
                    Button {
                        Task { await storeKit.purchase() }
                    } label: {
                        Group {
                            if case .purchasing = storeKit.purchaseState {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(storeKit.hasTrialOffer ? "Essayer gratuitement" : "S'abonner")
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.patchiOrange)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button, style: .continuous))
                    }
                    .padding(.horizontal, 20)

                    // Restaurer
                    Button("Restaurer les achats") {
                        Task { await storeKit.restore() }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    // Lien "Continuer sans"
                    Button("Continuer sans abonnement") {
                        dismiss()
                    }
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 20)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Patchi Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}

private struct PremiumFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.orange)
                .frame(width: 28)

            Text(text)
                .font(.subheadline)

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundStyle(.green)
        }
    }
}

// MARK: - Preview

#Preview("Premium Gate") {
    PremiumGate(feature: "Corrélations avancées") {
        Text("Contenu premium ici")
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
    }
    .environment(AppState())
}

#Preview("Premium View") {
    PremiumView()
}
