-- Servitecnicos: estructura de la base de datos (Supabase / PostgreSQL)
-- Pegar en Supabase > SQL Editor > New query > Run

create table if not exists colecciones (
  id          text primary key,              -- ej. 'toners'
  nombre      text not null,                 -- ej. 'Tóners'
  descripcion text,
  orden       int  not null default 0,
  visible     boolean not null default true
);

create table if not exists marcas (
  id      text primary key,                  -- ej. 'hp'
  nombre  text not null,                     -- ej. 'HP'
  logo    text,                              -- ruta de la imagen del logo
  orden   int  not null default 0
);

create table if not exists productos (
  codigo         text primary key,           -- referencia única, ej. 'TN-HP-85A'
  nombre         text not null,
  coleccion_id   text not null references colecciones(id),
  marca_id       text references marcas(id),
  tipo           text,                       -- ej. 'Original', 'Botella', 'Láser · Wi-Fi'
  precio         int  not null check (precio >= 0),   -- pesos colombianos
  precio_oferta  int  check (precio_oferta >= 0),
  cantidad       int  not null default 0 check (cantidad >= 0),
  tamano         text,                       -- tamaño o rendimiento, ej. '65 ml · 4.500 páginas'
  compatibilidad text,
  descripcion    text,
  fotos          text[] not null default '{}',  -- nombres de archivo en Storage
  visible        boolean not null default true,
  destacado      boolean not null default false,
  creado         timestamptz not null default now(),
  actualizado    timestamptz not null default now()
);

create index if not exists productos_coleccion_idx on productos(coleccion_id);
create index if not exists productos_marca_idx on productos(marca_id);

-- Fecha de actualización automática
create or replace function tocar_actualizado() returns trigger language plpgsql set search_path = '' as $$
begin new.actualizado = now(); return new; end $$;
drop trigger if exists productos_actualizado on productos;
create trigger productos_actualizado before update on productos
  for each row execute function tocar_actualizado();

-- Administradores: solo los correos de esta lista pueden editar (no basta con crear una cuenta)
-- Para agregar uno: insert into administradores (email) values ('correo@ejemplo.com');
create table if not exists administradores (
  email text primary key
);
alter table administradores enable row level security;  -- sin políticas: nadie la lee desde la página

create or replace function es_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.administradores a
    where lower(a.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke all on function es_admin() from public, anon;
grant execute on function es_admin() to authenticated;

-- Seguridad: cualquiera puede VER lo visible; solo administradores pueden EDITAR
alter table colecciones enable row level security;
alter table marcas      enable row level security;
alter table productos   enable row level security;

drop policy if exists "ver colecciones" on colecciones;
create policy "ver colecciones" on colecciones for select using (visible);
drop policy if exists "admin ve todas las colecciones" on colecciones;
create policy "admin ve todas las colecciones" on colecciones for select to authenticated using ((select es_admin()));
drop policy if exists "ver marcas" on marcas;
create policy "ver marcas" on marcas for select using (true);
drop policy if exists "ver productos" on productos;
create policy "ver productos" on productos for select using (visible);
drop policy if exists "admin ve todos los productos" on productos;
create policy "admin ve todos los productos" on productos for select to authenticated using ((select es_admin()));

drop policy if exists "editar colecciones" on colecciones;
create policy "editar colecciones" on colecciones for all to authenticated using ((select es_admin())) with check ((select es_admin()));
drop policy if exists "editar marcas" on marcas;
create policy "editar marcas" on marcas for all to authenticated using ((select es_admin())) with check ((select es_admin()));
drop policy if exists "editar productos" on productos;
create policy "editar productos" on productos for all to authenticated using ((select es_admin())) with check ((select es_admin()));

-- Carpeta pública para las fotos de productos (las fotos se ven por enlace directo; solo administradores suben o borran)
insert into storage.buckets (id, name, public) values ('productos', 'productos', true)
  on conflict (id) do nothing;
drop policy if exists "ver fotos" on storage.objects;
drop policy if exists "subir fotos" on storage.objects;
create policy "subir fotos" on storage.objects for all to authenticated
  using (bucket_id = 'productos' and (select public.es_admin()))
  with check (bucket_id = 'productos' and (select public.es_admin()));
