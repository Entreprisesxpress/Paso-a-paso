-- Paso a Paso : comptes, sauvegarde et ligue entre amis.
-- À coller une seule fois dans Supabase › SQL Editor › New query, puis « Run ».

-- Profils publics (ce que les amis voient dans la ligue)
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  name text not null check (char_length(name) between 1 and 24),
  xp int not null default 0,
  level int not null default 1,
  streak int not null default 0,
  lessons int not null default 0,
  arcade_best int not null default 0,
  week_xp int not null default 0,
  week_key text,
  units_done int not null default 0,
  lessons_today int not null default 0,
  today_key text,
  last_day text,
  week_days text,
  words int not null default 0,
  current_unit text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- Tableau « Ma famille » : colonnes ajoutées après coup. Sans effet si elles existent déjà,
-- donc on peut relancer tout ce fichier sans risque sur un projet déjà installé.
alter table public.profiles add column if not exists lessons_today int not null default 0;
alter table public.profiles add column if not exists today_key text;
alter table public.profiles add column if not exists last_day text;
alter table public.profiles add column if not exists week_days text;
alter table public.profiles add column if not exists words int not null default 0;
alter table public.profiles add column if not exists current_unit text;
alter table public.profiles add column if not exists created_at timestamptz not null default now();
alter table public.profiles enable row level security;
drop policy if exists "Les joueurs connectés voient la ligue" on public.profiles;
create policy "Les joueurs connectés voient la ligue" on public.profiles for select to authenticated using (true);
drop policy if exists "Chacun crée son profil" on public.profiles;
create policy "Chacun crée son profil" on public.profiles for insert to authenticated with check (id = auth.uid());
drop policy if exists "Chacun modifie son profil" on public.profiles;
create policy "Chacun modifie son profil" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Sauvegarde complète de la progression : privée, visible seulement par son propriétaire
create table if not exists public.saves (
  id uuid primary key references auth.users on delete cascade,
  data jsonb not null,
  updated_at bigint not null default 0
);
alter table public.saves enable row level security;
drop policy if exists "Sauvegarde privée" on public.saves;
create policy "Sauvegarde privée" on public.saves for all to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Défis entre amis au Défi éclair
create table if not exists public.challenges (
  id bigint generated always as identity primary key,
  from_id uuid not null references auth.users on delete cascade,
  to_id uuid not null references auth.users on delete cascade,
  from_name text not null,
  to_name text not null,
  score int not null check (score between 0 and 999),
  result int,
  status text not null default 'pending' check (status in ('pending', 'done')),
  created_at timestamptz not null default now()
);
alter table public.challenges enable row level security;
drop policy if exists "Voir ses défis" on public.challenges;
create policy "Voir ses défis" on public.challenges for select to authenticated using (auth.uid() in (from_id, to_id));
drop policy if exists "Envoyer un défi" on public.challenges;
create policy "Envoyer un défi" on public.challenges for insert to authenticated with check (from_id = auth.uid() and to_id <> auth.uid());
drop policy if exists "Répondre à un défi reçu" on public.challenges;
create policy "Répondre à un défi reçu" on public.challenges for update to authenticated using (to_id = auth.uid()) with check (to_id = auth.uid());

-- Compétitions entre membres (le plus de leçons, d'XP ou de mots en X jours)
create table if not exists public.competitions (
  id bigint generated always as identity primary key,
  created_by uuid not null references auth.users on delete cascade,
  creator_name text not null,
  title text not null check (char_length(title) between 1 and 80),
  metric text not null check (metric in ('xp', 'lessons', 'words')),
  ends_at timestamptz not null,
  created_at timestamptz not null default now()
);
alter table public.competitions enable row level security;
drop policy if exists "Voir les compétitions" on public.competitions;
create policy "Voir les compétitions" on public.competitions for select to authenticated using (true);
drop policy if exists "Lancer une compétition" on public.competitions;
create policy "Lancer une compétition" on public.competitions for insert to authenticated with check (created_by = auth.uid());
drop policy if exists "Supprimer sa compétition" on public.competitions;
create policy "Supprimer sa compétition" on public.competitions for delete to authenticated using (created_by = auth.uid());

-- Inscriptions : chacun part de son total au moment d'entrer (start_value)
create table if not exists public.comp_entries (
  comp_id bigint not null references public.competitions on delete cascade,
  user_id uuid not null references auth.users on delete cascade,
  name text not null,
  start_value int not null default 0,
  joined_at timestamptz not null default now(),
  primary key (comp_id, user_id)
);
alter table public.comp_entries enable row level security;
drop policy if exists "Voir les participants" on public.comp_entries;
create policy "Voir les participants" on public.comp_entries for select to authenticated using (true);
drop policy if exists "Rejoindre une compétition" on public.comp_entries;
create policy "Rejoindre une compétition" on public.comp_entries for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "Quitter une compétition" on public.comp_entries;
create policy "Quitter une compétition" on public.comp_entries for delete to authenticated using (user_id = auth.uid());
