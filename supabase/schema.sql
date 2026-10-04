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
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "Les joueurs connectés voient la ligue" on public.profiles for select to authenticated using (true);
create policy "Chacun crée son profil" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "Chacun modifie son profil" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- Sauvegarde complète de la progression : privée, visible seulement par son propriétaire
create table if not exists public.saves (
  id uuid primary key references auth.users on delete cascade,
  data jsonb not null,
  updated_at bigint not null default 0
);
alter table public.saves enable row level security;
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
create policy "Voir ses défis" on public.challenges for select to authenticated using (auth.uid() in (from_id, to_id));
create policy "Envoyer un défi" on public.challenges for insert to authenticated with check (from_id = auth.uid() and to_id <> auth.uid());
create policy "Répondre à un défi reçu" on public.challenges for update to authenticated using (to_id = auth.uid()) with check (to_id = auth.uid());
