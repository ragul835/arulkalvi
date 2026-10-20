alter table public.contact_messages add column if not exists phone text not null default '' check (char_length(phone) between 7 and 30);
