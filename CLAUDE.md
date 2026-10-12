# Suscripciones

App personal de Valen para llevar sus suscripciones: cuánto cuestan, cuándo se cobran, pruebas gratis y en qué se le va el dinero. Repo `vmmterminus-star/suscripciones`, rama `main`. Se va a usar sobre todo desde la pantalla de inicio del iPhone.

**Todavía no se publica en GitHub Pages:** Valen quiere tener el diseño final antes (va a mandar inspiración de Pinterest).

## Cómo está hecha
- Todo en un solo `index.html` (HTML+CSS+JS vanilla, sin build). Única externa: Alexandria (Google Fonts). Logos automáticos: servicio de favicons de Google (`s2/favicons?sz=128&domain=`).
- Datos: `localStorage` clave `suscripciones_v1` = `{v, subs, metodos, defMetodo, cats}`. Respaldo: descargar/cargar JSON desde Ajustes. Supabase y avisos de Pushover van después.
- Suscripción: `{id, creada, estado ('activa'|'cancelada'), cancelada, nombre, precio, moneda ('MXN'|'USD'), pesos (lo que cobran en pesos si es USD; es lo que se suma), freq ('mensual'|'anual'|'semanal'|'otro'), cada, unidad ('dias'|'semanas'|'meses'), prox (YYYY-MM-DD), primero, ancla (día del mes), metodo, cat, nec (1–5), web (dominio para el logo), img (dataURL JPEG 160 px), prueba, pruebaIni, pruebaDias, notas}`.
- `prox` se recorre solo al abrir (`avanzar()`). Si es prueba, `prox` = fin de la prueba.
- Totales: las pruebas activas no se suman al total (salen aparte). Las de USD sin `pesos` tampoco (se avisa abajo del total).

## Decisiones de Valen (no cambiar sin preguntar)
- Pantalla principal con calendario (opción B de los wireframes), lista de próximos 30 días, resumen por categoría y por necesidad, filtros por categoría.
- Dólares: ella anota cuánto le cobraron en pesos; nada de tipo de cambio automático.
- Métodos de pago: Klar (predeterminado), Pago de papá, PayPal, Banorte Platino, Plata Card. Editables.
- Categorías iniciales: Juegos, Escolar, Tecnología, Comida, Ropa, Belleza. Editables.
- Necesidad como puntitos del 1 al 5.
- Canceladas no se borran: van a la sección «Canceladas».
- Las contraseñas NO van en esta app (será otra app, cifrada).

## Cómo trabajar con Valen
- No programa: español sencillo y conciso. Antes de cambios visuales, wireframes con opciones A/B/C.
- Reglas de sus apps: cabe en iPhone, inputs ≥16px, Alexandria, ícono embebido + PNG e ICO aparte, sin mensajes de regaño.
- Probar con el servidor `suscripciones` de `C:\Users\Valen\.claude\code\.claude\launch.json` (puerto 8736) a 375 px, cero errores de consola.
- El repo es público: nada de datos personales ni llaves.
