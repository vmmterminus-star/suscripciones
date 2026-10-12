# Suscripciones

App personal de Valen para llevar sus suscripciones: cuÃ¡nto cuestan, cuÃ¡ndo se cobran, pruebas gratis y en quÃ© se le va el dinero. Repo `vmmterminus-star/suscripciones`, rama `main`. Se va a usar sobre todo desde la pantalla de inicio del iPhone.

**TodavÃ­a no se publica en GitHub Pages:** Valen quiere tener el diseÃ±o final antes (va a mandar inspiraciÃ³n de Pinterest).

## CÃ³mo estÃ¡ hecha
- Todo en un solo `index.html` (HTML+CSS+JS vanilla, sin build). Fuentes externas: Outfit (texto) y Fraunces (tÃ­tulos), de Google Fonts. Logos automÃ¡ticos: servicio de favicons de Google (`s2/favicons?sz=128&domain=`).
- Datos: `localStorage` clave `suscripciones_v1` = `{v, subs, metodos, defMetodo, cats}`. Respaldo: descargar/cargar JSON desde Ajustes. Supabase y avisos de Pushover van despuÃ©s.
- SuscripciÃ³n: `{id, creada, estado ('activa'|'cancelada'), cancelada, nombre, precio, moneda ('MXN'|'USD'), pesos (lo que cobran en pesos si es USD; es lo que se suma), freq ('mensual'|'anual'|'semanal'|'otro'), cada, unidad ('dias'|'semanas'|'meses'), prox (YYYY-MM-DD), primero, ancla (dÃ­a del mes), metodo, cat, nec (1â€“5), web (dominio para el logo), img (dataURL JPEG 160 px), prueba, pruebaIni, pruebaDias, notas}`.
- `prox` se recorre solo al abrir (`avanzar()`). Si es prueba, `prox` = fin de la prueba.
- Totales: las pruebas activas no se suman al total (salen aparte). Las de USD sin `pesos` tampoco (se avisa abajo del total).

## Decisiones de Valen (no cambiar sin preguntar)
- Pantalla principal con calendario (opciÃ³n B de los wireframes), lista de prÃ³ximos 30 dÃ­as, resumen por categorÃ­a y por necesidad, filtros por categorÃ­a.
- DÃ³lares: ella anota cuÃ¡nto le cobraron en pesos; nada de tipo de cambio automÃ¡tico.
- MÃ©todos de pago: Klar (predeterminado), Pago de papÃ¡, PayPal, Banorte Platino, Plata Card. Editables.
- CategorÃ­as iniciales: Juegos, Escolar, TecnologÃ­a, Comida, Ropa, Belleza. Editables.
- Necesidad como puntitos del 1 al 5.
- DiseÃ±o Â«PastillasÂ» (elegido 2026-10-12, inspiraciÃ³n Pinterest): fondo `#F1ECE4`, tarjetas blancas muy redondeadas, cafÃ© `#4A3530` como acento, total en durazno `#F6D9C8`, dÃ­as de cobro camel `#B98E7C`, resumen con barras de pastilla sobre rayitas. Colores de categorÃ­as: cafÃ©, camel, olivo `#9C9A6E`, blush `#E8B9B0`, greige `#C9C1AE`. BotÃ³n + redondo abajo a la derecha. TÃ­tulo Â«SuscripcionesÂ» (no saludo).
- ExcepciÃ³n a su regla de Alexandria: tÃ­tulos y nÃºmeros grandes en **Fraunces** (serif, la letra Â«editorialÂ» que eligiÃ³) y todo lo demÃ¡s en **Outfit** (lo pidiÃ³ ella). Nada de Alexandria en esta app.
- Canceladas no se borran: van a la secciÃ³n Â«CanceladasÂ».
- Las contraseÃ±as NO van en esta app (serÃ¡ otra app, cifrada).

## CÃ³mo trabajar con Valen
- No programa: espaÃ±ol sencillo y conciso. Antes de cambios visuales, wireframes con opciones A/B/C.
- Reglas de sus apps: cabe en iPhone, inputs â‰¥16px, Ã­cono embebido + PNG e ICO aparte, sin mensajes de regaÃ±o.
- Probar con el servidor `suscripciones` de `C:\Users\Valen\.claude\code\.claude\launch.json` (puerto 8736) a 375 px, cero errores de consola.
- El repo es pÃºblico: nada de datos personales ni llaves.
