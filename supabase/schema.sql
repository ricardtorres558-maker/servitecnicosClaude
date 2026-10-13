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
create or replace function tocar_actualizado() returns trigger language plpgsql as $$
begin new.actualizado = now(); return new; end $$;
drop trigger if exists productos_actualizado on productos;
create trigger productos_actualizado before update on productos
  for each row execute function tocar_actualizado();

-- Seguridad: cualquiera puede VER lo visible; solo usuarios con sesión pueden EDITAR
alter table colecciones enable row level security;
alter table marcas      enable row level security;
alter table productos   enable row level security;

drop policy if exists "ver colecciones" on colecciones;
create policy "ver colecciones" on colecciones for select using (visible);
drop policy if exists "ver marcas" on marcas;
create policy "ver marcas" on marcas for select using (true);
drop policy if exists "ver productos" on productos;
create policy "ver productos" on productos for select using (visible);

drop policy if exists "editar colecciones" on colecciones;
create policy "editar colecciones" on colecciones for all to authenticated using (true) with check (true);
drop policy if exists "editar marcas" on marcas;
create policy "editar marcas" on marcas for all to authenticated using (true) with check (true);
drop policy if exists "editar productos" on productos;
create policy "editar productos" on productos for all to authenticated using (true) with check (true);

-- Carpeta pública para las fotos de productos
insert into storage.buckets (id, name, public) values ('productos', 'productos', true)
  on conflict (id) do nothing;
drop policy if exists "ver fotos" on storage.objects;
create policy "ver fotos" on storage.objects for select using (bucket_id = 'productos');
drop policy if exists "subir fotos" on storage.objects;
create policy "subir fotos" on storage.objects for all to authenticated
  using (bucket_id = 'productos') with check (bucket_id = 'productos');
