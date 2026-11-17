-- Run this if an account was created but the profiles row is missing.
-- This copies the role/name metadata stored by Supabase Auth into public.profiles.
insert into public.profiles (id, full_name, email, role)
select
  u.id,
  coalesce(u.raw_user_meta_data->>'full_name', ''),
  u.email,
  case
    when u.raw_user_meta_data->>'role' in ('student', 'tutor')
      then u.raw_user_meta_data->>'role'
    else 'student'
  end
from auth.users u
on conflict (id) do update set
  full_name = excluded.full_name,
  email = excluded.email,
  role = case
    when public.profiles.role in ('student', 'tutor') then public.profiles.role
    else excluded.role
  end;
