create extension if not exists pgcrypto;
create table if not exists public.documents (
 id uuid primary key default gen_random_uuid(), title text not null check (char_length(title) between 2 and 180), slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'), description text, class_name text not null, subject text not null, academic_year text not null, storage_key text not null unique, file_size bigint not null check (file_size > 0), download_count bigint not null default 0 check (download_count >= 0), is_published boolean not null default false, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists documents_published_created_idx on public.documents (is_published, created_at desc);
create index if not exists documents_class_idx on public.documents (class_name) where is_published;
create index if not exists documents_subject_idx on public.documents (subject) where is_published;
create index if not exists documents_year_idx on public.documents (academic_year) where is_published;
create index if not exists documents_title_idx on public.documents using gin (to_tsvector('simple', title));
alter table public.documents enable row level security;
revoke all on public.documents from anon, authenticated;
create or replace function public.increment_download_count(document_id uuid) returns void language sql security definer set search_path=public as $$ update public.documents set download_count=download_count+1 where id=document_id and is_published=true; $$;
revoke all on function public.increment_download_count(uuid) from public, anon, authenticated;
