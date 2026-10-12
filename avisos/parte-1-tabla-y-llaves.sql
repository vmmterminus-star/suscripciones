-- ═══════════════════════════════════════════════════════════════
-- SUSCRIPCIONES · PARTE 1 de 2 · se corre UNA sola vez
-- Dónde: Supabase → proyecto de tus agendas (suwhvvxihzsfbbrcocbx)
--        → SQL Editor → New query → pegar todo → Run.
-- Antes de darle Run, cambia las dos llaves de Pushover de hasta abajo.
-- Estos avisos van aparte de los de tus agendas: no se tocan entre sí.
-- ═══════════════════════════════════════════════════════════════

-- 1. La tabla donde la app guarda tus suscripciones (con tu código secreto)
create table if not exists public.suscripciones_sync (
  code       text primary key,          -- tu código (y "<código>__widget" para los avisos)
  data       jsonb,
  updated_at timestamptz default now()
);
alter table public.suscripciones_sync enable row level security;
drop policy if exists "suscripciones leer"   on public.suscripciones_sync;
drop policy if exists "suscripciones crear"  on public.suscripciones_sync;
drop policy if exists "suscripciones cambiar" on public.suscripciones_sync;
create policy "suscripciones leer"    on public.suscripciones_sync for select to anon using (true);
create policy "suscripciones crear"   on public.suscripciones_sync for insert to anon with check (true);
create policy "suscripciones cambiar" on public.suscripciones_sync for update to anon using (true) with check (true);

-- 2. Lo de los avisos, en un espacio aparte que la app no puede ver
create extension if not exists pg_cron;
create extension if not exists pg_net;

create schema if not exists avisos_suscripciones;
revoke all on schema avisos_suscripciones from public, anon, authenticated;

create table if not exists avisos_suscripciones.config (
  id          int primary key default 1 check (id = 1),
  token       text,
  usuario     text,
  hora_cobro  time    default '20:00',  -- la noche antes de cada cobro
  hora_prueba time    default '09:00',  -- fin de prueba: 3 días antes y 1 día antes
  hora_anual  time    default '09:00',  -- anuales: una semana antes
  hora_semana time    default '09:00',  -- resumen de la semana, los lunes
  hora_pesos  time    default '13:00',  -- el día del cobro en dólares: anotar los pesos
  activo      boolean default true      -- false = pausar todos los avisos
);

create table if not exists avisos_suscripciones.enviados (
  clave text primary key,
  en    timestamptz default now()
);

-- ▼▼▼ PEGA TUS LLAVES DE PUSHOVER AQUÍ, ENTRE LAS COMILLAS ▼▼▼
insert into avisos_suscripciones.config (id, token, usuario)
values (1, 'PEGA_AQUI_TU_API_TOKEN', 'PEGA_AQUI_TU_USER_KEY')
on conflict (id) do update set token = excluded.token, usuario = excluded.usuario;
