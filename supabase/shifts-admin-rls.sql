-- Allow managers and administrators to see every employee and admin shift.
-- Run this in the Supabase SQL Editor for the project.

alter table public.shifts enable row level security;

drop policy if exists "Managers and admins can view all shifts" on public.shifts;

create policy "Managers and admins can view all shifts"
on public.shifts
for select
to authenticated
using (
  exists (
    select 1
    from public.profiles
    where profiles.id = auth.uid()
      and profiles.role in ('ADMIN', 'MANAGER')
  )
);

drop policy if exists "Managers and admins can update all shifts" on public.shifts;

create policy "Managers and admins can update all shifts"
on public.shifts
for update
to authenticated
using (
  exists (
    select 1
    from public.profiles
    where profiles.id = auth.uid()
      and profiles.role in ('ADMIN', 'MANAGER')
  )
)
with check (
  exists (
    select 1
    from public.profiles
    where profiles.id = auth.uid()
      and profiles.role in ('ADMIN', 'MANAGER')
  )
);

drop policy if exists "Managers and admins can delete all shifts" on public.shifts;

create policy "Managers and admins can delete all shifts"
on public.shifts
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