create table if not exists public.contact_messages (
 id uuid primary key default gen_random_uuid(),
 name text not null check (char_length(name) between 2 and 100),
 email text not null check (email ~ '^[^\s@]+@[^\s@]+\.[^\s@]+$'),
 message text not null check (char_length(message) between 10 and 5000),
 created_at timestamptz not null default now()
);
create index if not exists contact_messages_created_idx on public.contact_messages (created_at desc);
alter table public.contact_messages enable row level security;
revoke all on public.contact_messages from anon, authenticated;
