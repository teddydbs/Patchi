import OSLog
import StoreKit
import SwiftData

private let logger = Logger(subsystem: "com.kokora.app", category: "StoreKit")

@Observable
final class StoreKitService {
    static let shared = StoreKitService()

    private(set) var premiumProduct: Product?
    private(set) var isPremium = false
    private(set) var purchaseState: PurchaseState = .idle

    /// Callback appelé quand le statut premium change — pour sync AppState + SwiftData
    var onPremiumChanged: ((Bool) -> Void)?

    private let productId = "com.kokora.premium.yearly"

    enum PurchaseState {
        case idle
        case purchasing
        case purchased
        case failed(String)
    }

    private init() {}

    /// Appeler une seule fois au lancement de l'app
    func start() {
        Task { await loadProducts() }
        Task { await refreshEntitlements() }
        Task { await listenForUpdates() }
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productId])
            await MainActor.run { premiumProduct = products.first }
        } catch {
            logger.error("Product load failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Purchase

    @MainActor
    func purchase() async {
        guard let product = premiumProduct else { return }
        purchaseState = .purchasing

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    setPremium(true)
                    purchaseState = .purchased
                case .unverified(_, let error):
                    purchaseState = .failed("Vérification échouée: \(error.localizedDescription)")
                }
            case .userCancelled:
                purchaseState = .idle
            case .pending:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }

    // MARK: - Restore

    @MainActor
    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    // MARK: - Entitlements

    func refreshEntitlements() async {
        var foundPremium = false
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productID == productId {
                    foundPremium = true
                }
            case .unverified:
                break
            }
        }
        // Swift 6 : on capture l'état final dans un `let` immuable avant
        // de le passer à une closure concurrente (sinon warning/erreur de
        // data race sur la var locale).
        let isPremium = foundPremium
        await MainActor.run { setPremium(isPremium) }
    }

    // MARK: - Listen for updates

    private func listenForUpdates() async {
        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                await transaction.finish()
                if transaction.productID == productId {
                    await MainActor.run { setPremium(true) }
                }
            case .unverified:
                break
            }
        }
    }

    // MARK: - Single source of truth

    private func setPremium(_ value: Bool) {
        isPremium = value
        onPremiumChanged?(value)
    }

    // MARK: - Helpers

    var priceString: String {
        premiumProduct?.displayPrice ?? "34,99 €"
    }

    var hasTrialOffer: Bool {
        premiumProduct?.subscription?.introductoryOffer != nil
    }
}
