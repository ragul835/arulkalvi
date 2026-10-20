create table if not exists public.updates (
 id uuid primary key default gen_random_uuid(),
 title text not null check (char_length(title) between 2 and 180),
 content text not null check (char_length(content) between 2 and 5000),
 kind text not null check (kind in ('news','update','exam_tip')),
 is_published boolean not null default false,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index if not exists updates_public_created_idx on public.updates (is_published, created_at desc);
alter table public.updates enable row level security;
revoke all on public.updates from anon, authenticated;
