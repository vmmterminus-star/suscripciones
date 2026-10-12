# Suscripciones

App personal de Valen para llevar sus suscripciones: cuánto cuestan, cuándo se cobran, pruebas gratis y en qué se le va el dinero. Repo `vmmterminus-star/suscripciones`, rama `main`. Se va a usar sobre todo desde la pantalla de inicio del iPhone.

Publicada en https://vmmterminus-star.github.io/suscripciones/ (GitHub Pages, rama `main`). Ícono: `icono.png` (180 px); versiones 512 px y .ico en `C:\Users\Valen\Apps\iconos\suscripciones.*`.

## Cómo está hecha
- Todo en un solo `index.html` (HTML+CSS+JS vanilla, sin build). Fuentes externas: Outfit (texto) y Fraunces (títulos), de Google Fonts. Logos automáticos: servicio de favicons de Google (`s2/favicons?sz=128&domain=`).
- Datos: `localStorage` clave `suscripciones_v1` = `{v, subs, metodos, defMetodo, cats}`. Respaldo: descargar/cargar JSON desde Ajustes.
- Nube: Supabase del proyecto de las agendas (`suwhvvxihzsfbbrcocbx`), tabla `suscripciones_sync(code, data, updated_at)`. Fila `<código>` = datos partidos por llave (`v`, `metodos`, `def`, `cats`, `sub:<id>` con cada suscripción en JSON) para juntar cambios de dos dispositivos por suscripción (`blobLocal()` / `aplicarBlob()`). Lógica igual a la plantilla del plugin (subir solo al cambiar, revisar cada 15 s, juntar contra la base, no bajar con una hoja abierta). Llaves solo de este dispositivo: `suscripciones_code`, `suscripciones_remote_ts`, `suscripciones_base`. `avanzar()` guarda con `guardarLocal()` para que abrir la app no suba nada. El código secreto lo escribe Valen en Ajustes → Nube; nunca va en el repo.
- Fila `<código>__widget` = `widgetBlob()` → `av.ev`: cobros (`k:"c"`) y fines de prueba (`k:"p"`) de los próximos 370 días, `{s,t,k,f,m,v,mp,fr,a,u}` (`v` pesos numéricos o null, `a` anual, `u` dólares sin pesos).
- Avisos de Pushover: `avisos/parte-1-tabla-y-llaves.sql` (una vez: tabla, esquema `avisos_suscripciones`, llaves) y `avisos/parte-2-avisos.sql` (re-ejecutable; cron `avisos-suscripciones` cada minuto). Horas en `avisos_suscripciones.config`: cobro de mañana 20:00, fin de prueba (3 y 1 día antes) 09:00, anuales una semana antes 09:00, resumen de la semana los lunes 09:00, anotar pesos el día de un cobro en USD 13:00. App de Pushover propia «Suscripciones». Probado con PGlite (net/cron simulados). En plpgsql no nombrar `e` a una variable si hay alias `e`; anidar los `if` con `mandar()`.
- Suscripción: `{id, creada, estado ('activa'|'cancelada'), cancelada, nombre, precio, moneda ('MXN'|'USD'), pesos (lo que cobran en pesos si es USD; es lo que se suma), freq ('mensual'|'anual'|'semanal'|'otro'), cada, unidad ('dias'|'semanas'|'meses'), prox (YYYY-MM-DD), primero, ancla (día del mes), metodo, cat, nec (1–5), web (dominio para el logo), img (dataURL JPEG 160 px), prueba, pruebaIni, pruebaDias, notas}`.
- `prox` se recorre solo al abrir (`avanzar()`). Si es prueba, `prox` = fin de la prueba.
- Totales: las pruebas activas no se suman al total (salen aparte). Las de USD sin `pesos` tampoco (se avisa abajo del total).

## Decisiones de Valen (no cambiar sin preguntar)
- Pantalla principal con calendario (opción B de los wireframes), lista de próximos 30 días, resumen por categoría y por necesidad, filtros por categoría.
- Dólares: ella anota cuánto le cobraron en pesos; nada de tipo de cambio automático.
- Métodos de pago: Klar (predeterminado), Pago de papá, PayPal, Banorte Platino, Plata Card. Editables.
- Categorías iniciales: Juegos, Escolar, Tecnología, Comida, Ropa, Belleza. Editables.
- Necesidad como puntitos del 1 al 5.
- Diseño «Pastillas» (elegido 2026-10-12, inspiración Pinterest): fondo `#F1ECE4`, tarjetas blancas muy redondeadas, café `#4A3530` como acento, total en durazno `#F6D9C8`, días de cobro camel `#B98E7C`, resumen con barras de pastilla sobre rayitas. Colores de categorías: café, camel, olivo `#9C9A6E`, blush `#E8B9B0`, greige `#C9C1AE`. Botón + redondo abajo a la derecha. Título «Suscripciones» (no saludo).
- Excepción a su regla de Alexandria: títulos y números grandes en **Fraunces** (serif, la letra «editorial» que eligió) y todo lo demás en **Outfit** (lo pidió ella). Nada de Alexandria en esta app.
- Canceladas no se borran: van a la sección «Canceladas».
- Las contraseñas NO van en esta app (será otra app, cifrada).

## Cómo trabajar con Valen
- No programa: español sencillo y conciso. Antes de cambios visuales, wireframes con opciones A/B/C.
- Reglas de sus apps: cabe en iPhone, inputs ≥16px, ícono embebido + PNG e ICO aparte, sin mensajes de regaño.
- Probar con el servidor `suscripciones` de `C:\Users\Valen\.claude\code\.claude\launch.json` (puerto 8736) a 375 px, cero errores de consola.
- El repo es público: nada de datos personales ni llaves.
