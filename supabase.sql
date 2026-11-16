-- Almacén de Materiales: tabla, bucket y permisos.
-- Pegar completo en Supabase → SQL Editor → Run. Se puede correr más de una vez.

-- 1) Quién es admin. Estar registrado NO alcanza: hay que figurar en esta tabla.
create table if not exists public.admins (
  user_id uuid primary key references auth.users (id) on delete cascade
);
alter table public.admins enable row level security;  -- sin políticas: nadie la lee ni la edita desde la web

create or replace function public.es_admin()
returns boolean
language sql stable security definer set search_path = ''
as $$ select exists (select 1 from public.admins where user_id = (select auth.uid())) $$;

-- 2) Publicaciones
create table if not exists public.publicaciones (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  titulo text not null check (char_length(titulo) between 1 and 80),
  precio text,
  imagen_path text not null
);
alter table public.publicaciones enable row level security;

drop policy if exists "publicaciones: lectura publica" on public.publicaciones;
create policy "publicaciones: lectura publica" on public.publicaciones
  for select using (true);

drop policy if exists "publicaciones: admin inserta" on public.publicaciones;
create policy "publicaciones: admin inserta" on public.publicaciones
  for insert to authenticated with check (public.es_admin());

drop policy if exists "publicaciones: admin borra" on public.publicaciones;
create policy "publicaciones: admin borra" on public.publicaciones
  for delete to authenticated using (public.es_admin());

-- 3) Bucket de imágenes: lectura pública por URL, solo JPG/PNG/WebP, máximo 5 MB
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('publicaciones', 'publicaciones', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "fotos: admin sube" on storage.objects;
create policy "fotos: admin sube" on storage.objects
  for insert to authenticated with check (bucket_id = 'publicaciones' and public.es_admin());

drop policy if exists "fotos: admin borra" on storage.objects;
create policy "fotos: admin borra" on storage.objects
  for delete to authenticated using (bucket_id = 'publicaciones' and public.es_admin());

-- 4) Después de crear el usuario admin en Authentication → Users, darle permiso
--    (cambiar el email por el real y correr solo esta línea):
-- insert into public.admins (user_id) select id from auth.users where email = 'EMAIL_DEL_ADMIN';
