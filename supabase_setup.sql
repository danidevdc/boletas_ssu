-- supabase_setup.sql
-- Ejecutar en Supabase > SQL Editor.
-- Configuración para PILOTO.

-- 1) Tabla de periodos disponibles en el selector.
create table if not exists public.periodos (
  periodo text primary key,
  nombre text not null,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

-- 2) Tabla principal de boletas.
create table if not exists public.boletas (
  id uuid primary key default gen_random_uuid(),
  empleado_id text not null,
  nombre text,
  periodo text not null,
  archivo_path text not null,
  fecha_expiracion timestamptz,
  abierto_en timestamptz,
  descargado_en timestamptz,
  created_at timestamptz not null default now(),
  unique (empleado_id, periodo)
);

-- 3) Activar Row Level Security.
alter table public.periodos enable row level security;
alter table public.boletas enable row level security;

-- 4) Políticas para periodos.
-- Lectura pública para que la página empleado muestre meses activos.
drop policy if exists "periodos_select_public" on public.periodos;
create policy "periodos_select_public"
on public.periodos
for select
to anon, authenticated
using (activo = true or auth.role() = 'authenticated');

-- Admin autenticado puede insertar/actualizar periodos.
drop policy if exists "periodos_admin_all" on public.periodos;
create policy "periodos_admin_all"
on public.periodos
for all
to authenticated
using (true)
with check (true);

-- 5) Políticas para boletas.
-- PILOTO: lectura anónima para que el empleado busque por CI y periodo.
-- No guarda PIN ni PDF legible.
drop policy if exists "boletas_select_public" on public.boletas;
create policy "boletas_select_public"
on public.boletas
for select
to anon, authenticated
using (true);

-- PILOTO: permitir update anónimo SOLO de campos de seguimiento es difícil limitar por columna en policies.
-- Para prueba se permite update; en producción conviene mover seguimiento a una API institucional o Edge Function.
drop policy if exists "boletas_update_public_tracking" on public.boletas;
create policy "boletas_update_public_tracking"
on public.boletas
for update
to anon, authenticated
using (true)
with check (true);

-- Admin autenticado puede insertar/upsert registros desde admin.html.
drop policy if exists "boletas_admin_insert" on public.boletas;
create policy "boletas_admin_insert"
on public.boletas
for insert
to authenticated
with check (true);

drop policy if exists "boletas_admin_delete" on public.boletas;
create policy "boletas_admin_delete"
on public.boletas
for delete
to authenticated
using (true);

-- 6) Crear bucket manualmente en Supabase Storage:
-- Storage > New bucket
-- Name: boletas
-- Public bucket: ON para piloto.
--
-- Si quiere hacerlo por SQL y su proyecto lo permite:
-- insert into storage.buckets (id, name, public)
-- values ('boletas', 'boletas', true)
-- on conflict (id) do update set public = true;

-- 7) Políticas de Storage para subir archivos desde admin.html.
-- Permite leer objetos del bucket boletas públicamente.
drop policy if exists "boletas_storage_public_read" on storage.objects;
create policy "boletas_storage_public_read"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'boletas');

-- Permite subir/actualizar archivos al admin autenticado.
drop policy if exists "boletas_storage_admin_insert" on storage.objects;
create policy "boletas_storage_admin_insert"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'boletas');

drop policy if exists "boletas_storage_admin_update" on storage.objects;
create policy "boletas_storage_admin_update"
on storage.objects
for update
to authenticated
using (bucket_id = 'boletas')
with check (bucket_id = 'boletas');

drop policy if exists "boletas_storage_admin_delete" on storage.objects;
create policy "boletas_storage_admin_delete"
on storage.objects
for delete
to authenticated
using (bucket_id = 'boletas');

-- Periodo de ejemplo.
insert into public.periodos (periodo, nombre, activo)
values ('2026-05', 'Mayo 2026', true)
on conflict (periodo) do update set nombre = excluded.nombre, activo = excluded.activo;
