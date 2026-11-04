// Мечети и халяль из OpenStreetMap через Overpass, с кешем на сутки.
// Приложение обращается сюда, а не к Overpass напрямую: публичные серверы
// бывают перегружены или отвечают отказом, а здесь перебираются зеркала.

export const MIRRORS = [
  'https://overpass-api.de/api/interpreter',
  'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
];

/** Границы видимой области: округляем, чтобы соседние запросы попадали в кеш. */
export function parseBbox(params) {
  const v = ['s', 'w', 'n', 'e'].map((k) => Number(params.get(k)));
  if (v.some((x) => !Number.isFinite(x))) return null;
  let [s, w, n, e] = v;
  if (s < -90 || n > 90 || w < -180 || e > 180 || s >= n || w >= e) return null;
  // Не больше ~1.5° по стороне: иначе ответ огромный, а Overpass медленный.
  if (n - s > 1.5 || e - w > 1.5) return null;
  s = Math.floor(s * 50) / 50; w = Math.floor(w * 50) / 50;
  n = Math.ceil(n * 50) / 50; e = Math.ceil(e * 50) / 50;
  return [s, w, n, e].map((x) => +x.toFixed(2));
}

export function overpassQuery([s, w, n, e]) {
  const b = `${s},${w},${n},${e}`;
  return `[out:json][timeout:25];
(
  nwr["amenity"="place_of_worship"]["religion"="muslim"](${b});
  nwr["diet:halal"~"^(yes|only)$"](${b});
  nwr["cuisine"~"halal"](${b});
  nwr["halal"="yes"](${b});
);
out center tags 300;`;
}

/** Перебирает зеркала, пока одно не ответит JSON. */
export async function fetchOverpass(query, fetchImpl = fetch, mirrors = MIRRORS) {
  const errors = [];
  for (const url of mirrors) {
    try {
      const r = await fetchImpl(url, {
        method: 'POST',
        headers: {
          'content-type': 'application/x-www-form-urlencoded',
          'user-agent': 'imam-app/1.0 (+https://github.com/VladFlutt/imam)',
        },
        body: new URLSearchParams({ data: query }),
        signal: AbortSignal.timeout(20000),
      });
      if (!r.ok) { errors.push(`${new URL(url).host} ${r.status}`); continue; }
      const data = await r.json();
      if (!Array.isArray(data.elements)) { errors.push(`${new URL(url).host} bad`); continue; }
      return { elements: data.elements, source: new URL(url).host };
    } catch (e) {
      errors.push(`${new URL(url).host} ${e.name}`);
    }
  }
  const err = new Error('all mirrors failed');
  err.details = errors;
  throw err;
}

export async function places(request, cors, fetchImpl = fetch) {
  const url = new URL(request.url);
  const bbox = parseBbox(url.searchParams);
  const headers = { ...cors, 'content-type': 'application/json; charset=utf-8' };
  if (!bbox) return new Response(JSON.stringify({ error: 'bbox' }), { status: 400, headers });
  const key = new Request(`https://cache.imam/places?b=${bbox.join(',')}`);
  const cache = globalThis.caches?.default;
  const hit = cache && (await cache.match(key));
  if (hit) return new Response(hit.body, { headers: { ...headers, 'x-cache': 'hit' } });
  try {
    const { elements, source } = await fetchOverpass(overpassQuery(bbox), fetchImpl);
    const body = JSON.stringify({ elements });
    if (cache) {
      await cache.put(key, new Response(body, {
        headers: { 'content-type': 'application/json', 'cache-control': 'public, max-age=86400' },
      }));
    }
    return new Response(body, { headers: { ...headers, 'x-source': source } });
  } catch (e) {
    return new Response(JSON.stringify({ error: 'unavailable', details: e.details ?? [] }), {
      status: 503,
      headers,
    });
  }
}
