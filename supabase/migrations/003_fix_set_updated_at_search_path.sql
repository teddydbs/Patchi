-- ============================================================================
-- Kokora — Fix function_search_path_mutable sur set_updated_at
-- Migration: 003_fix_set_updated_at_search_path
-- ============================================================================
-- Le linter sécurité Supabase signale que `set_updated_at` n'a pas de
-- `search_path` figé, ce qui peut permettre une attaque par search_path
-- hijacking si un attaquant crée un schéma avec une fonction homonyme.
-- Solution : figer search_path = public.
-- ============================================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
    new.updated_at := now();
    return new;
end;
$$;
