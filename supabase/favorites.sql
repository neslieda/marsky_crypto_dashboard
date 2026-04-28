-- Marsky Crypto Dashboard — favorites cloud sync schema
-- Apply via: Supabase SQL editor or `supabase db push`

create table if not exists public.favorites (
  user_id   uuid        not null references auth.users(id) on delete cascade,
  uuid      text        not null,
  name      text        not null,
  symbol    text        not null,
  icon_url  text,
  added_at  timestamptz not null default now(),
  category  text,
  primary key (user_id, uuid)
);

alter table public.favorites enable row level security;

drop policy if exists "favorites_select_own" on public.favorites;
drop policy if exists "favorites_insert_own" on public.favorites;
drop policy if exists "favorites_update_own" on public.favorites;
drop policy if exists "favorites_delete_own" on public.favorites;

create policy "favorites_select_own" on public.favorites
  for select using (auth.uid() = user_id);
create policy "favorites_insert_own" on public.favorites
  for insert with check (auth.uid() = user_id);
create policy "favorites_update_own" on public.favorites
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "favorites_delete_own" on public.favorites
  for delete using (auth.uid() = user_id);

-- Enable realtime
alter publication supabase_realtime add table public.favorites;
