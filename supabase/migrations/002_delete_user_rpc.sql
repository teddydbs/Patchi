-- ============================================================================
-- Kokora — RPC pour self-delete du compte
-- Migration: 002_delete_user_rpc
-- ============================================================================
-- Expose une fonction `delete_account()` que le client peut appeler via RPC.
-- Supprime l'entrée `auth.users` → cascade delete sur profiles + toutes les
-- tables user-owned (checkins, decisions, letters, accountability).
-- SECURITY DEFINER pour bypasser les restrictions RLS sur auth.users.
-- RGPD : l'utilisateur peut effacer toutes ses données en une seule action.
-- ============================================================================

create or replace function public.delete_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
    uid uuid;
begin
    -- Récupère l'ID de l'utilisateur authentifié qui appelle la fonction
    uid := auth.uid();

    if uid is null then
        raise exception 'Not authenticated';
    end if;

    -- Supprime l'user de auth.users. Tous les ON DELETE CASCADE en aval
    -- (profiles, checkins, decisions, letters, accountability_entries) feront
    -- le reste automatiquement.
    delete from auth.users where id = uid;
end;
$$;

-- Seuls les utilisateurs authentifiés peuvent appeler cette fonction
revoke all on function public.delete_account() from public;
grant execute on function public.delete_account() to authenticated;
