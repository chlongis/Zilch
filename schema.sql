-- Zilch — full database schema
-- Paste this whole file into the Supabase SQL Editor and run it once.
-- Safe to re-run: everything is guarded with "if not exists".

-- ---------------------------------------------------------------
-- Driver profiles — the core of the product
-- ---------------------------------------------------------------
create table if not exists drivers (
  id uuid primary key default gen_random_uuid(),
  handle text unique not null,          -- public URL slug, e.g. dmitri-k3f9
  name text not null,                   -- first name only
  area text,
  vehicle text,
  bio text,
  trips int,
  rating numeric,
  years int,
  platform text,
  contact_type text,                    -- text | call | signal | whatsapp | email
  contact_value text,
  proof_path text,                      -- storage path of the stats screenshot
  verified text default 'self',         -- self | screenshot | email
  owner_key text,                       -- anonymous browser key that created it
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------
-- Job board
-- Note: from / to / when are reserved words in Postgres.
-- ---------------------------------------------------------------
create table if not exists requests (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('ride','delivery')),
  name text,
  pickup text not null,
  dropoff text not null,
  when_text text,
  offer numeric not null,
  notes text,
  area text,
  contact text,                         -- revealed only to whoever claims
  status text not null default 'open' check (status in ('open','claimed')),
  claimed_by text,
  claimed_name text,
  posted_by text,
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------
-- Launch-area pledges
-- ---------------------------------------------------------------
create table if not exists pledges (
  id uuid primary key default gen_random_uuid(),
  role text not null check (role in ('driver','rider')),
  area text not null,
  name text,
  night text,
  current_platform text,
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------
-- Anonymous pay-check submissions
-- ---------------------------------------------------------------
create table if not exists datapoints (
  id uuid primary key default gen_random_uuid(),
  miles numeric,
  minutes numeric,
  trips int,
  paid numeric,
  required numeric,
  shortfall numeric,
  rates text,                           -- which jurisdiction was selected
  platform text,
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------
-- Row level security
-- The anon key is public by design. RLS is what actually protects data.
-- ---------------------------------------------------------------
alter table drivers    enable row level security;
alter table requests   enable row level security;
alter table pledges    enable row level security;
alter table datapoints enable row level security;

create policy "read drivers"    on drivers    for select using (true);
create policy "read requests"   on requests   for select using (true);
create policy "read pledges"    on pledges    for select using (true);
create policy "read datapoints" on datapoints for select using (true);

create policy "add drivers"    on drivers    for insert with check (true);
create policy "add requests"   on requests   for insert with check (true);
create policy "add pledges"    on pledges    for insert with check (true);
create policy "add datapoints" on datapoints for insert with check (true);

-- The claim lock. An update is only permitted on a row that is still open,
-- and only to set it claimed. Two drivers racing the same job: one wins,
-- the other is rejected by Postgres rather than by browser JavaScript.
create policy "claim requests" on requests for update
  using (status = 'open') with check (status = 'claimed');

-- ---------------------------------------------------------------
-- Realtime
-- ---------------------------------------------------------------
alter publication supabase_realtime add table drivers, requests, pledges, datapoints;

-- ---------------------------------------------------------------
-- Storage buckets — create these in the dashboard, then run these policies.
--   proof      : driver stats screenshots
--   insurance  : optional insurance uploads from the board
-- Both private, 5 MB cap, image/jpeg + image/png + application/pdf.
-- ---------------------------------------------------------------
create policy "upload proof" on storage.objects
  for insert with check (bucket_id = 'proof');
create policy "read proof" on storage.objects
  for select using (bucket_id = 'proof');

create policy "upload insurance" on storage.objects
  for insert with check (bucket_id = 'insurance');
create policy "read insurance" on storage.objects
  for select using (bucket_id = 'insurance');
