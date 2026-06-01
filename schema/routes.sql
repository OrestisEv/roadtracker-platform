-- RoadTracker canonical schema
-- This is the source of truth. Run migrations from this repo, never from app repos.
-- Current version: 1.0.0

create table public.routes (
  id               text primary key,
  user_id          uuid references auth.users on delete cascade not null,
  name             text not null default 'Untitled ride',
  date_ms          bigint not null,
  coordinates      jsonb not null,
  distance_km      numeric not null default 0,
  mode             text not null default 'gps' check (mode in ('gps','manual')),
  duration_seconds bigint not null default 0,
  max_speed        numeric not null default 0,
  avg_speed        numeric not null default 0,
  max_lean_angle   numeric not null default 0,
  max_g_force      numeric not null default 0,
  elevation_gain   numeric not null default 0,
  telemetry_json   text not null default '',
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);

create index routes_user_id_idx on public.routes(user_id);

alter table public.routes enable row level security;

create policy "own_select" on public.routes for select using (auth.uid() = user_id);
create policy "own_insert" on public.routes for insert with check (auth.uid() = user_id);
create policy "own_update" on public.routes for update using (auth.uid() = user_id);
create policy "own_delete" on public.routes for delete using (auth.uid() = user_id);

create function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

create trigger routes_touch_updated
  before update on public.routes
  for each row execute procedure public.touch_updated_at();

-- Realtime
alter publication supabase_realtime add table public.routes;
