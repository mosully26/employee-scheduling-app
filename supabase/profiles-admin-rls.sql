-- Allow managers and administrators to load every profile for shift assignment
-- and for resolving assigned names in the admin calendar.
-- Run this in the Supabase SQL Editor for the project.

alter table public.profiles enable row level security;

drop policy if exists "Managers and admins can view all profiles" on public.profiles;

create policy "Managers and admins can view all profiles"
on public.profiles
for select
to authenticated
using (
  exists (
    select 1
    from public.profiles current_profile
    where current_profile.id = auth.uid()
      and current_profile.role in ('ADMIN', 'MANAGER')
  )
  or id = auth.uid()
);