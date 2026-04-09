-- ============================================================================
-- Kokora — Optimisation des policies RLS
-- Migration: 004_optimize_rls_policies
-- ============================================================================
-- Le linter perf Supabase signale que `auth.uid()` dans les policies se
-- ré-évalue pour CHAQUE row (auth_rls_initplan). En wrappant dans un
-- sous-select `(select auth.uid())`, Postgres peut cacher la valeur
-- et l'évaluer une seule fois par query. Impact : queries beaucoup plus
-- rapides à l'échelle (x10 à x100 sur des listes).
-- Ref: https://supabase.com/docs/guides/database/postgres/row-level-security#call-functions-with-select
-- ============================================================================

-- profiles
drop policy if exists "Users read own profile" on public.profiles;
drop policy if exists "Users insert own profile" on public.profiles;
drop policy if exists "Users update own profile" on public.profiles;

create policy "Users read own profile" on public.profiles
    for select using ((select auth.uid()) = id);
create policy "Users insert own profile" on public.profiles
    for insert with check ((select auth.uid()) = id);
create policy "Users update own profile" on public.profiles
    for update using ((select auth.uid()) = id);

-- checkins
drop policy if exists "Users read own checkins" on public.checkins;
drop policy if exists "Users insert own checkins" on public.checkins;
drop policy if exists "Users update own checkins" on public.checkins;
drop policy if exists "Users delete own checkins" on public.checkins;

create policy "Users read own checkins" on public.checkins
    for select using ((select auth.uid()) = user_id);
create policy "Users insert own checkins" on public.checkins
    for insert with check ((select auth.uid()) = user_id);
create policy "Users update own checkins" on public.checkins
    for update using ((select auth.uid()) = user_id);
create policy "Users delete own checkins" on public.checkins
    for delete using ((select auth.uid()) = user_id);

-- accountability_entries
drop policy if exists "Users read own accountability" on public.accountability_entries;
drop policy if exists "Users insert own accountability" on public.accountability_entries;
drop policy if exists "Users update own accountability" on public.accountability_entries;
drop policy if exists "Users delete own accountability" on public.accountability_entries;

create policy "Users read own accountability" on public.accountability_entries
    for select using ((select auth.uid()) = user_id);
create policy "Users insert own accountability" on public.accountability_entries
    for insert with check ((select auth.uid()) = user_id);
create policy "Users update own accountability" on public.accountability_entries
    for update using ((select auth.uid()) = user_id);
create policy "Users delete own accountability" on public.accountability_entries
    for delete using ((select auth.uid()) = user_id);

-- decisions
drop policy if exists "Users read own decisions" on public.decisions;
drop policy if exists "Users insert own decisions" on public.decisions;
drop policy if exists "Users update own decisions" on public.decisions;
drop policy if exists "Users delete own decisions" on public.decisions;

create policy "Users read own decisions" on public.decisions
    for select using ((select auth.uid()) = user_id);
create policy "Users insert own decisions" on public.decisions
    for insert with check ((select auth.uid()) = user_id);
create policy "Users update own decisions" on public.decisions
    for update using ((select auth.uid()) = user_id);
create policy "Users delete own decisions" on public.decisions
    for delete using ((select auth.uid()) = user_id);

-- future_letters
drop policy if exists "Users read own letters" on public.future_letters;
drop policy if exists "Users insert own letters" on public.future_letters;
drop policy if exists "Users update own letters" on public.future_letters;
drop policy if exists "Users delete own letters" on public.future_letters;

create policy "Users read own letters" on public.future_letters
    for select using ((select auth.uid()) = user_id);
create policy "Users insert own letters" on public.future_letters
    for insert with check ((select auth.uid()) = user_id);
create policy "Users update own letters" on public.future_letters
    for update using ((select auth.uid()) = user_id);
create policy "Users delete own letters" on public.future_letters
    for delete using ((select auth.uid()) = user_id);
