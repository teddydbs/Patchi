import StoreKit

@Observable
final class StoreKitService {
    static let shared = StoreKitService()

    private(set) var premiumProduct: Product?
    private(set) var isPremium = false
    private(set) var purchaseState: PurchaseState = .idle

    private let productId = "com.patchi.premium.yearly"

    enum PurchaseState {
        case idle
        case purchasing
        case purchased
        case failed(String)
    }

    private init() {
        Task { await loadProducts() }
        Task { await refreshEntitlements() }
        Task { await listenForUpdates() }
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productId])
            premiumProduct = products.first
        } catch {
            print("Erreur chargement produits: \(error)")
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
                    isPremium = true
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
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productID == productId {
                    await MainActor.run { isPremium = true }
                }
            case .unverified:
                break
            }
        }
    }

    // MARK: - Listen for updates

    private func listenForUpdates() async {
        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                await transaction.finish()
                if transaction.productID == productId {
                    await MainActor.run { isPremium = true }
                }
            case .unverified:
                break
            }
        }
    }

    // MARK: - Helpers

    var priceString: String {
        premiumProduct?.displayPrice ?? "34,99 €"
    }

    var hasTrialOffer: Bool {
        premiumProduct?.subscription?.introductoryOffer != nil
    }
}
