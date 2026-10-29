-- Allow administrators and managers to create announcements as themselves.
-- Run this in the Supabase SQL Editor for the project.

alter table public.announcements enable row level security;

drop policy if exists "Managers and admins can insert announcements" on public.announcements;

create policy "Managers and admins can insert announcements"
on public.announcements
for insert
to authenticated
with check (
  created_by = auth.uid()
  and exists (
    select 1
    from public.profiles
    where profiles.id = auth.uid()
      and profiles.role in ('ADMIN', 'MANAGER')
  )
);

drop policy if exists "Managers and admins can delete announcements" on public.announcements;

create policy "Managers and admins can delete announcements"
on public.announcements
for delete
to authenticated
using (
  exists (
    select 1
    from public.profiles
    where profiles.id = auth.uid()
      and profiles.role in ('ADMIN', 'MANAGER')
  )
);
