import Foundation
import Supabase

/// Singleton client Supabase utilisé dans toute l'app.
///
/// URL + publishable key safe à committer : la publishable key est conçue pour
/// être embarquée dans le client, la sécurité est garantie côté serveur par les
/// Row Level Security (RLS) policies (voir `supabase/migrations/`).
///
/// Accès :
/// ```
/// let user = try await Supa.shared.client.auth.session.user
/// let checkins = try await Supa.shared.client.from("checkins").select().execute()
/// ```
enum Supa {
    /// URL du projet Supabase (région EU).
    static let projectURL: URL = URL(string: "https://nvvbcvuchdbxgspbpncf.supabase.co")!

    /// Publishable key (préfixe `sb_publishable_`).
    /// Safe à committer — protégée par les RLS policies.
    static let publishableKey: String = "sb_publishable_GZRhdVtsCt-xi2PYem8kvA_wVKr8FFf"

    /// Client partagé. Lazy-loadé au premier accès.
    static let shared: SupabaseClient = {
        SupabaseClient(
            supabaseURL: projectURL,
            supabaseKey: publishableKey
        )
    }()
}
