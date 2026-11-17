-- Run this in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  email text,
  role text not null check (role in ('student','tutor')),
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  tutor_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text not null default '',
  category text not null default 'General',
  thumbnail_url text,
  is_free boolean not null default true,
  price numeric(10,2) not null default 0 check (price >= 0),
  published boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  title text not null,
  video_url text,
  position integer not null default 1,
  created_at timestamptz not null default now()
);

create table if not exists public.enrollments (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  enrolled_at timestamptz not null default now(),
  unique(course_id, student_id)
);

create table if not exists public.lesson_progress (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  course_id uuid not null references public.courses(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  completed boolean not null default false,
  completed_at timestamptz,
  unique(lesson_id, student_id)
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  comment text default '',
  created_at timestamptz not null default now(),
  unique(course_id, student_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  course_id uuid not null references public.courses(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

-- Keep profile row in sync when a new Auth user is created.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id, full_name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name',''),
    new.email,
    coalesce(new.raw_user_meta_data->>'role','student')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.lessons enable row level security;
alter table public.enrollments enable row level security;
alter table public.lesson_progress enable row level security;
alter table public.reviews enable row level security;
alter table public.messages enable row level security;

create policy "profiles readable to authenticated" on public.profiles for select to authenticated using (true);
create policy "user updates own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy "user inserts own profile" on public.profiles for insert to authenticated with check (auth.uid() = id);

create policy "published courses visible" on public.courses for select to authenticated using (published = true or tutor_id = auth.uid());
create policy "tutors create own courses" on public.courses for insert to authenticated with check (tutor_id = auth.uid() and exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='tutor'));
create policy "tutors update own courses" on public.courses for update to authenticated using (tutor_id = auth.uid()) with check (tutor_id = auth.uid());
create policy "tutors delete own courses" on public.courses for delete to authenticated using (tutor_id = auth.uid());

create policy "lessons visible for published course" on public.lessons for select to authenticated using (
  exists(select 1 from public.courses c where c.id=course_id and (c.tutor_id=auth.uid() or c.is_free or exists(select 1 from public.enrollments e where e.course_id=c.id and e.student_id=auth.uid())))
);
create policy "tutor manages lessons" on public.lessons for all to authenticated using (
  exists(select 1 from public.courses c where c.id=course_id and c.tutor_id=auth.uid())
) with check (
  exists(select 1 from public.courses c where c.id=course_id and c.tutor_id=auth.uid())
);

create policy "enrollments visible to owner or tutor" on public.enrollments for select to authenticated using (
  student_id=auth.uid() or exists(select 1 from public.courses c where c.id=course_id and c.tutor_id=auth.uid())
);
create policy "students enroll themselves" on public.enrollments for insert to authenticated with check (
  student_id=auth.uid() and exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='student')
);
create policy "student progress readable" on public.lesson_progress for select to authenticated using (student_id=auth.uid());
create policy "student updates own progress" on public.lesson_progress for insert to authenticated with check (student_id=auth.uid());
create policy "student updates own progress row" on public.lesson_progress for update to authenticated using (student_id=auth.uid()) with check (student_id=auth.uid());

create policy "reviews readable" on public.reviews for select to authenticated using (true);
create policy "enrolled students write reviews" on public.reviews for insert to authenticated with check (
  student_id=auth.uid() and exists(select 1 from public.enrollments e where e.course_id=course_id and e.student_id=auth.uid())
);
create policy "students update own review" on public.reviews for update to authenticated using (student_id=auth.uid()) with check (student_id=auth.uid());

create policy "course participants read messages" on public.messages for select to authenticated using (
  exists(select 1 from public.courses c where c.id=course_id and (c.tutor_id=auth.uid() or exists(select 1 from public.enrollments e where e.course_id=c.id and e.student_id=auth.uid())))
);
create policy "course participants send messages" on public.messages for insert to authenticated with check (
  sender_id=auth.uid() and exists(select 1 from public.courses c where c.id=course_id and (c.tutor_id=auth.uid() or exists(select 1 from public.enrollments e where e.course_id=c.id and e.student_id=auth.uid())))
);

-- Storage: create a public bucket named course-images in Supabase Storage.
-- Restrict uploads to each user's own folder using the storage policies below.
insert into storage.buckets (id, name, public) values ('course-images','course-images',true)
on conflict (id) do nothing;
create policy "authenticated users upload own course images" on storage.objects
for insert to authenticated with check (bucket_id='course-images' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "public reads course images" on storage.objects
for select to public using (bucket_id='course-images');
create policy "users update own course images" on storage.objects
for update to authenticated using (bucket_id='course-images' and (storage.foldername(name))[1]=auth.uid()::text);
