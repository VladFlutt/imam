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

// Названия мечетей на языках приложения и соседей: помогает найти мечети,
// у которых в OSM не указана религия. Флаг ,i в Overpass не всегда работает
// для кириллицы, поэтому первая буква указана в обоих регистрах.
export const MOSQUE_NAMES =
  '[Мм]ечет|[Мм]ечит|[Мм]әчет|[Мм]ешіт|[Мм]асджид|[Mm]osque|[Mm]osqu[ée]e|[Mm]asjid|[Mm]esjid|[Mm]oschee|[Cc]amii|[Mm]escit|مسجد|جامع';
export const HALAL_NAMES = '[Hh]alal|HALAL|[Хх]ал[яа]ль|ХАЛ[ЯА]ЛЬ|حلال';

/**
 * Мечети и халяль отдельными выдачами: раньше общий лимит 300 обрезал
 * мечети в больших городах. Кроме явных тегов ищем места, которые
 * сами называют себя халяль (частый случай в России и СНГ), и мечети
 * без тега religion; такие халяль-места приложение показывает
 * с пометкой «не подтверждено», как и остальные несертифицированные.
 */
export function overpassQuery([s, w, n, e]) {
  const b = `${s},${w},${n},${e}`;
  return `[out:json][timeout:25];
(
  nwr["amenity"="place_of_worship"]["religion"~"^(muslim|islam)$"](${b});
  nwr["building"="mosque"](${b});
  nwr["amenity"="place_of_worship"][!"religion"]["name"~"${MOSQUE_NAMES}"](${b});
)->.m;
(
  nwr["diet:halal"~"^(yes|only)$"](${b});
  nwr["cuisine"~"halal"](${b});
  nwr["halal"="yes"](${b});
  nwr["amenity"~"^(restaurant|cafe|fast_food|food_court|canteen)$"]["name"~"${HALAL_NAMES}"](${b});
  nwr["shop"]["name"~"${HALAL_NAMES}"](${b});
)->.h;
(.h; - .m;)->.h;
.m out center tags 500;
.h out center tags 500;`;
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

const PHOTON_QUERIES = [
  { q: 'mosque', tag: 'amenity:place_of_worship' },
  { q: 'мечеть', tag: 'amenity:place_of_worship' },
  { q: 'masjid', tag: 'amenity:place_of_worship' },
  { q: 'халяль', kind: 'halal' },
  { q: 'halal', kind: 'halal' },
];

/** Запасной источник — Photon (поиск по OSM): мечети и места с «халяль» в названии. */
export async function fetchPhoton([s, w, n, e], fetchImpl = fetch) {
  const seen = new Map();
  let ok = 0;
  for (const { q, tag, kind } of PHOTON_QUERIES) {
    const url = `https://photon.komoot.io/api/?q=${encodeURIComponent(q)}&bbox=${w},${s},${e},${n}` +
      (tag ? `&osm_tag=${tag}` : '') + '&limit=100';
    let r;
    try {
      r = await fetchImpl(url, {
        headers: { 'user-agent': 'imam-app/1.0 (+https://github.com/VladFlutt/imam)' },
        signal: AbortSignal.timeout(15000),
      });
    } catch {
      continue;
    }
    if (!r.ok) continue;
    ok++;
    const data = await r.json();
    for (const f of data.features ?? []) {
      const p = f.properties ?? {};
      const [lon, lat] = f.geometry?.coordinates ?? [];
      if (typeof lat !== 'number' || typeof lon !== 'number') continue;
      let tags;
      if (kind === 'halal') {
        // Только заведения и магазины, а не улицы или остановки с таким словом.
        if (!['amenity', 'shop'].includes(p.osm_key) || p.osm_value === 'place_of_worship') continue;
        if (!p.name || !new RegExp(HALAL_NAMES).test(p.name)) continue;
        tags = { [p.osm_key]: p.osm_value };
      } else {
        tags = { amenity: 'place_of_worship', religion: 'muslim' };
      }
      const type = { N: 'node', W: 'way', R: 'relation' }[p.osm_type] ?? 'node';
      if (p.name) tags.name = p.name;
      if (p.street) tags['addr:street'] = p.street;
      if (p.housenumber) tags['addr:housenumber'] = p.housenumber;
      const id = `${type}/${p.osm_id}`;
      if (!seen.has(id)) seen.set(id, { type, id: p.osm_id, lat, lon, tags });
    }
  }
  if (!ok) throw Object.assign(new Error('photon'), { name: 'PhotonError' });
  return [...seen.values()];
}

export async function places(request, cors, fetchImpl = fetch) {
  const url = new URL(request.url);
  const bbox = parseBbox(url.searchParams);
  const headers = { ...cors, 'content-type': 'application/json; charset=utf-8' };
  if (!bbox) return new Response(JSON.stringify({ error: 'bbox' }), { status: 400, headers });
  // v2: запрос расширен, старые ответы в кеше неполные.
  const key = new Request(`https://cache.imam/places/v2?b=${bbox.join(',')}`);
  const cache = globalThis.caches?.default;
  const hit = cache && (await cache.match(key));
  if (hit) return new Response(hit.body, { headers: { ...headers, 'x-cache': 'hit' } });
  let elements, source, partial = false, details;
  try {
    ({ elements, source } = await fetchOverpass(overpassQuery(bbox), fetchImpl));
  } catch (e) {
    details = e.details ?? [];
    try {
      elements = await fetchPhoton(bbox, fetchImpl);
      source = 'photon';
      partial = true;
    } catch (e2) {
      details.push(`photon ${e2.name}`);
    }
  }
  if (!elements) {
    return new Response(JSON.stringify({ error: 'unavailable', details }), { status: 503, headers });
  }
  const body = JSON.stringify(partial ? { elements, partial } : { elements });
  if (cache) {
    // Неполный ответ (из Photon) держим час, полный — сутки.
    await cache.put(key, new Response(body, {
      headers: { 'content-type': 'application/json', 'cache-control': `public, max-age=${partial ? 3600 : 86400}` },
    }));
  }
  return new Response(body, { headers: { ...headers, 'x-source': source } });
}
