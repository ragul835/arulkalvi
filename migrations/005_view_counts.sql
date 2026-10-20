alter table public.documents add column if not exists view_count bigint not null default 0 check (view_count >= 0);
create or replace function public.increment_view_count(document_id uuid) returns void language sql security definer set search_path=public as $$ update public.documents set view_count=view_count+1 where id=document_id and is_published=true; $$;
revoke all on function public.increment_view_count(uuid) from public, anon, authenticated;
