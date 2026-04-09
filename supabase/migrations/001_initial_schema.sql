-- ============================================================================
-- Kokora — Initial database schema
-- Migration: 001_initial_schema
-- ============================================================================
-- 5 user-owned tables + profiles (linked to auth.users)
-- RLS activée partout, chaque user ne voit QUE ses données
-- Trigger on_auth_user_created auto-crée le profile à l'inscription
-- ============================================================================

-- ============================================================================
-- Helper: updated_at auto-refresh trigger function
-- ============================================================================
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

-- ============================================================================
-- 1. profiles — app-specific user data linked to auth.users
-- ============================================================================
create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    first_name text not null default '',
    selected_theme text not null default 'default',
    is_premium boolean not null default false,
    premium_expires_at timestamptz,
    onboarding_completed boolean not null default false,
    notification_start_hour smallint not null default 19 check (notification_start_hour between 0 and 23),
    notification_end_hour smallint not null default 22 check (notification_end_hour between 0 and 23),
    notification_count smallint not null default 1 check (notification_count between 0 and 10),
    biometric_lock_enabled boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users read own profile"
    on public.profiles for select
    using (auth.uid() = id);

create policy "Users update own profile"
    on public.profiles for update
    using (auth.uid() = id);

create policy "Users insert own profile"
    on public.profiles for insert
    with check (auth.uid() = id);

create trigger profiles_set_updated_at
    before update on public.profiles
    for each row execute function public.set_updated_at();

-- Auto-create profile on new auth user
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.profiles (id, first_name)
    values (new.id, coalesce(new.raw_user_meta_data ->> 'first_name', ''));
    return new;
end;
$$;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- ============================================================================
-- 2. checkins — emotional journaling entries
-- ============================================================================
create table public.checkins (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    date timestamptz not null default now(),
    mood_score smallint not null check (mood_score between 1 and 5),
    activities text[] not null default '{}',
    emotions text[] not null default '{}',
    title text,
    note text,
    photo_url text,
    is_voice_entry boolean not null default false,
    reformulation text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index checkins_user_id_date_idx on public.checkins(user_id, date desc);

alter table public.checkins enable row level security;

create policy "Users read own checkins"
    on public.checkins for select
    using (auth.uid() = user_id);

create policy "Users insert own checkins"
    on public.checkins for insert
    with check (auth.uid() = user_id);

create policy "Users update own checkins"
    on public.checkins for update
    using (auth.uid() = user_id);

create policy "Users delete own checkins"
    on public.checkins for delete
    using (auth.uid() = user_id);

create trigger checkins_set_updated_at
    before update on public.checkins
    for each row execute function public.set_updated_at();

-- ============================================================================
-- 3. accountability_entries — tracking of missed actions
-- ============================================================================
create table public.accountability_entries (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    date timestamptz not null default now(),
    missed_action text not null,
    reason text,
    is_reason_valid boolean,
    importance smallint not null check (importance between 1 and 5),
    heatmap_color text not null default 'red',
    is_skipped boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index accountability_user_id_date_idx on public.accountability_entries(user_id, date desc);

alter table public.accountability_entries enable row level security;

create policy "Users read own accountability"
    on public.accountability_entries for select
    using (auth.uid() = user_id);

create policy "Users insert own accountability"
    on public.accountability_entries for insert
    with check (auth.uid() = user_id);

create policy "Users update own accountability"
    on public.accountability_entries for update
    using (auth.uid() = user_id);

create policy "Users delete own accountability"
    on public.accountability_entries for delete
    using (auth.uid() = user_id);

create trigger accountability_set_updated_at
    before update on public.accountability_entries
    for each row execute function public.set_updated_at();

-- ============================================================================
-- 4. decisions — decision journal with 30d/90d retrospective
-- ============================================================================
create table public.decisions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    title text not null,
    context text not null,
    prediction text not null,
    decision text not null,
    importance smallint not null check (importance between 1 and 5),
    confidence smallint check (confidence between 1 and 10),
    status text not null default 'pending',
    created_at timestamptz not null default now(),
    review_at_30 timestamptz not null,
    review_at_90 timestamptz not null,
    verdict_30 text,
    verdict_90 text,
    what_happened_30 text,
    what_happened_90 text,
    updated_at timestamptz not null default now()
);

create index decisions_user_id_created_idx on public.decisions(user_id, created_at desc);

alter table public.decisions enable row level security;

create policy "Users read own decisions"
    on public.decisions for select
    using (auth.uid() = user_id);

create policy "Users insert own decisions"
    on public.decisions for insert
    with check (auth.uid() = user_id);

create policy "Users update own decisions"
    on public.decisions for update
    using (auth.uid() = user_id);

create policy "Users delete own decisions"
    on public.decisions for delete
    using (auth.uid() = user_id);

create trigger decisions_set_updated_at
    before update on public.decisions
    for each row execute function public.set_updated_at();

-- ============================================================================
-- 5. future_letters — letters to future self
-- ============================================================================
create table public.future_letters (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    content text not null,
    written_at timestamptz not null default now(),
    deliver_at timestamptz not null,
    is_delivered boolean not null default false,
    reply text,
    replied_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index future_letters_user_id_deliver_idx on public.future_letters(user_id, deliver_at);

alter table public.future_letters enable row level security;

create policy "Users read own letters"
    on public.future_letters for select
    using (auth.uid() = user_id);

create policy "Users insert own letters"
    on public.future_letters for insert
    with check (auth.uid() = user_id);

create policy "Users update own letters"
    on public.future_letters for update
    using (auth.uid() = user_id);

create policy "Users delete own letters"
    on public.future_letters for delete
    using (auth.uid() = user_id);

create trigger letters_set_updated_at
    before update on public.future_letters
    for each row execute function public.set_updated_at();
