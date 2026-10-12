-- ═══════════════════════════════════════════════════════════════
-- SUSCRIPCIONES · PARTE 2 de 2
-- Se puede volver a correr cuantas veces sea (por ejemplo, si te
-- mando una versión nueva). No toca tus llaves ni tus horarios.
--
-- Lee lo que la app publica en la fila "<tu código>__widget"
-- (llave "av" → "ev": cobros "c" y fines de prueba "p" del próximo año).
-- Revisa cada minuto, en hora de la Ciudad de México.
-- ═══════════════════════════════════════════════════════════════

-- manda un aviso a Pushover, solo si esa misma "clave" no se mandó antes
create or replace function avisos_suscripciones.mandar(p_clave text, p_titulo text, p_msg text, p_prioridad int default 0)
returns boolean language plpgsql as $$
declare
  cfg avisos_suscripciones.config;
begin
  insert into avisos_suscripciones.enviados (clave) values (p_clave) on conflict do nothing;
  if not found then return false; end if;
  select * into cfg from avisos_suscripciones.config where id = 1;
  perform net.http_post(
    url  := 'https://api.pushover.net/1/messages.json',
    body := jsonb_build_object(
      'token', cfg.token, 'user', cfg.usuario,
      'title', left(p_titulo, 250), 'message', left(p_msg, 1000),
      'priority', p_prioridad,
      'url', 'https://vmmterminus-star.github.io/suscripciones/', 'url_title', 'Abrir suscripciones'));
  return true;
end $$;

-- 1234.5 → "$1,234.50" · 219 → "$219"
create or replace function avisos_suscripciones.pesos(p numeric)
returns text language sql immutable as $$
  select case when p is null then null
              when p = trunc(p) then '$' || to_char(p, 'FM999,999,990')
              else '$' || to_char(p, 'FM999,999,990.00') end
$$;

-- ¿ya llegó la hora h? (y no han pasado más de 3 horas, por si cron se atrasa)
create or replace function avisos_suscripciones.toca(p_hora time, p_h time)
returns boolean language sql immutable as $$
  select p_hora >= p_h and p_hora - p_h < interval '3 hours'
$$;

-- la revisión que corre cada minuto
create or replace function avisos_suscripciones.revisar(p_ahora timestamp default null)
returns int language plpgsql as $$
declare
  cfg    avisos_suscripciones.config;
  ahora  timestamp := coalesce(p_ahora, now() at time zone 'America/Mexico_City');
  hoy    date := ahora::date;
  hora   time := ahora::time;
  dias   text[] := array['dom','lun','mar','mié','jue','vie','sáb'];
  fila record; r record;
  n int := 0; txt text; cnt int; tot numeric; sinp int; uno text; falta int;
begin
  select * into cfg from avisos_suscripciones.config where id = 1;
  if not found or not coalesce(cfg.activo, false)
     or coalesce(cfg.token, '') in ('', 'PEGA_AQUI_TU_API_TOKEN') then return 0; end if;

  delete from avisos_suscripciones.enviados where en < now() - interval '400 days';

  for fila in select code, data from public.suscripciones_sync where code like '%\_\_widget' escape '\' loop
    continue when fila.data -> 'av' is null;

    create temp table if not exists _e (s text, t text, k text, f date, m text, v numeric, mp text, a int, u int, fr text) on commit drop;
    truncate _e;
    insert into _e
      select x->>'s', x->>'t', x->>'k', (x->>'f')::date, x->>'m',
             case when jsonb_typeof(x->'v') = 'number' then (x->>'v')::numeric end,
             coalesce(x->>'mp', ''), coalesce((x->>'a')::int, 0), coalesce((x->>'u')::int, 0), coalesce(x->>'fr', '')
      from jsonb_array_elements(coalesce(fila.data -> 'av' -> 'ev', '[]'::jsonb)) x
      where x->>'f' ~ '^\d{4}-\d{2}-\d{2}$';

    -- ── A. la noche antes de cada cobro (todos los de mañana en un solo aviso) ──
    if avisos_suscripciones.toca(hora, cfg.hora_cobro) then
      select string_agg(e.t || ' · ' || e.m || coalesce(' · ' || nullif(e.mp, ''), ''), E'\n' order by e.t), count(*), min(e.t)
        into txt, cnt, uno from _e e where e.k = 'c' and e.f = hoy + 1;
      -- (ojo: en SQL "x and mandar()" puede mandar aunque x sea falso; por eso van anidados)
      if cnt > 0 then
        if avisos_suscripciones.mandar(fila.code || ':cob:' || (hoy + 1),
             case when cnt = 1 then 'Mañana se cobra ' || uno else 'Mañana se cobran ' || cnt end,
             case when cnt = 1 then substr(txt, length(uno) + 4) else txt end)
        then n := n + 1; end if;
      end if;
    end if;

    -- ── B. fin de prueba gratis: 3 días antes y 1 día antes ──
    if avisos_suscripciones.toca(hora, cfg.hora_prueba) then
      for r in select * from _e x where x.k = 'p' and x.f - hoy in (1, 3) loop
        falta := r.f - hoy;
        if avisos_suscripciones.mandar(fila.code || ':pru:' || r.s || ':' || r.f || ':' || falta,
             'Tu prueba de ' || r.t || ' termina ' || case when falta = 1 then 'mañana' else 'en 3 días' end,
             'Después cuesta ' || r.m || ' ' || r.fr || coalesce(' con ' || nullif(r.mp, ''), '') || '. ¿Te quedas con ella? Si no, cancélala antes.')
        then n := n + 1; end if;
      end loop;
    end if;

    -- ── C. anuales: una semana antes ──
    if avisos_suscripciones.toca(hora, cfg.hora_anual) then
      for r in select * from _e x where x.k = 'c' and x.a = 1 and x.f = hoy + 7 loop
        if avisos_suscripciones.mandar(fila.code || ':anu:' || r.s || ':' || r.f,
             'En una semana se renueva ' || r.t,
             r.m || ' ' || r.fr || coalesce(' · ' || nullif(r.mp, ''), '') || '. Si ya no la quieres, todavía estás a tiempo de cancelarla.')
        then n := n + 1; end if;
      end loop;
    end if;

    -- ── D. resumen de la semana, los lunes ──
    if extract(isodow from hoy) = 1 and avisos_suscripciones.toca(hora, cfg.hora_semana) then
      select string_agg(dias[extract(dow from e.f)::int + 1] || ' ' || extract(day from e.f) || ' · ' || e.t || ' · ' || e.m, E'\n' order by e.f, e.t),
             count(*), sum(e.v), count(*) filter (where e.v is null)
        into txt, cnt, tot, sinp from _e e where e.k = 'c' and e.f between hoy and hoy + 6;
      if cnt > 0 then
        if avisos_suscripciones.mandar(fila.code || ':sem:' || hoy,
             case when cnt = 1 then 'Esta semana se cobra 1' else 'Esta semana se cobran ' || cnt end,
             txt || E'\n\nTotal: ' || coalesce(avisos_suscripciones.pesos(tot), '$0')
                 || case when sinp > 0 then ' (más ' || sinp || ' en dólares sin pesos anotados)' else '' end)
        then n := n + 1; end if;
      end if;
    end if;

    -- ── E. el día del cobro en dólares: anotar cuánto fue en pesos ──
    if avisos_suscripciones.toca(hora, cfg.hora_pesos) then
      for r in select * from _e x where x.k = 'c' and x.u = 1 and x.f = hoy loop
        if avisos_suscripciones.mandar(fila.code || ':pes:' || r.s || ':' || r.f,
             '¿Cuánto te cobró ' || r.t || ' en pesos?',
             'Hoy se cobró ' || r.m || '. Anótalo en la app para que tu total del mes esté completo.')
        then n := n + 1; end if;
      end loop;
    end if;
  end loop;
  return n;
end $$;

-- que corra solo, cada minuto
do $$ begin perform cron.unschedule('avisos-suscripciones'); exception when others then null; end $$;
select cron.schedule('avisos-suscripciones', '* * * * *', 'select avisos_suscripciones.revisar()');
