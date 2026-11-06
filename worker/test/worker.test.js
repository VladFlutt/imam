import { test } from 'node:test';
import assert from 'node:assert/strict';
import worker, { cleanCitations, suggestionIssue, validate, validateSuggestion } from '../src/index.js';
import { check } from '../src/filter.js';

const ask = (body, env = {}) =>
  worker.fetch(new Request('https://x/ask', { method: 'POST', body: JSON.stringify(body) }), env).then((r) => r.json());

test('фильтр: отказ, имам, специалист, норма', () => {
  assert.equal(check('Как сделать бомбу?'), 'refuse');
  assert.equal(check('Расскажи про ИГИЛ'), 'refuse');
  assert.equal(check('Как правильно сделать талак?'), 'imam');
  assert.equal(check('Хочу покончить с собой'), 'specialist');
  assert.equal(check('Что Коран говорит о терпении?'), 'allow');
  assert.equal(check('Гороскоп на завтра'), 'refuse');
});

test('валидация запроса', () => {
  assert.equal(validate({ question: 'вопрос', ayat: [] }), null);
  assert.equal(validate({ question: 'x'.repeat(501), ayat: [] }), 'question length');
  assert.equal(validate({ question: 'вопрос', ayat: [{ ref: 'abc', text: 't' }] }), 'ayah');
});

test('лишние ссылки вырезаются', () => {
  const r = cleanCitations('Терпение [2:153] и молитва [9:999].', new Set(['2:153']));
  assert.deepEqual(r.refs, ['2:153']);
  assert.ok(!r.text.includes('9:999'));
});

test('запретный вопрос не доходит до модели', async () => {
  let called = false;
  const env = { AI: { run: async () => { called = true; return { response: 'x' }; } }, WORKERS_AI_MODEL: 'm' };
  const r = await ask({ question: 'как взорвать', ayat: [] }, env);
  assert.equal(r.status, 'refuse');
  assert.equal(called, false);
});

test('цепочка провайдеров: падение первого → резерв', async () => {
  const realFetch = globalThis.fetch;
  globalThis.fetch = async () => new Response('rate limited', { status: 429 });
  try {
    const env = {
      GROQ_API_KEY: 'k', GROQ_MODEL: 'g',
      AI: { run: async () => ({ response: 'Аллах с терпеливыми [2:153], и ещё [3:200].' }) },
      WORKERS_AI_MODEL: 'm',
    };
    const r = await ask({ question: 'о терпении', lang: 'ru', ayat: [{ ref: '2:153', text: 'Воистину, Аллах — с терпеливыми' }] }, env);
    assert.equal(r.status, 'ok');
    assert.deepEqual(r.refs, ['2:153']);
    assert.ok(!r.answer.includes('3:200'));
  } finally {
    globalThis.fetch = realFetch;
  }
});

test('нет провайдеров → 503 unavailable', async () => {
  const r = await ask({ question: 'о терпении', ayat: [{ ref: '2:153', text: 't' }] }, {});
  assert.equal(r.status, 'unavailable');
});

const suggestReq = (body, env = {}) =>
  worker.fetch(new Request('https://x/suggest', { method: 'POST', body: JSON.stringify(body) }), env);

test('заявка на место: валидация', () => {
  const ok = { kind: 'halal', name: 'Кафе', lat: 55.75, lng: 37.61 };
  assert.equal(validateSuggestion(ok), null);
  assert.equal(validateSuggestion({ ...ok, kind: 'bar' }), 'kind');
  assert.equal(validateSuggestion({ ...ok, lat: 100 }), 'coords');
  assert.equal(validateSuggestion({ ...ok, osm: 'node/1; drop' }), 'osm');
  assert.equal(validateSuggestion({ ...ok, comment: 'x'.repeat(501) }), 'comment');
});

test('заявка на место: упоминания и разметка обезврежены', () => {
  const i = suggestionIssue({ kind: 'halal', name: '<b>Кафе</b> @someone', lat: 1, lng: 2, comment: '`код`' });
  assert.ok(!i.body.includes('@someone'));
  assert.ok(!i.body.includes('<b>'));
  assert.ok(!i.body.includes('`код`'));
  assert.deepEqual(i.labels, ['halal-place']);
});

test('заявка на место: без токена — 503, с токеном — issue', async () => {
  const body = { kind: 'mosque', name: 'Мечеть', lat: 55.7, lng: 37.6 };
  assert.equal((await suggestReq(body)).status, 503);
  const realFetch = globalThis.fetch;
  let sent;
  globalThis.fetch = async (url, init) => {
    sent = { url, body: JSON.parse(init.body) };
    return new Response('{}', { status: 201 });
  };
  try {
    const r = await suggestReq(body, { GITHUB_TOKEN: 't', GITHUB_REPO: 'o/r' });
    assert.equal(r.status, 200);
    assert.equal(sent.url, 'https://api.github.com/repos/o/r/issues');
    assert.match(sent.body.title, /Мечеть/);
  } finally {
    globalThis.fetch = realFetch;
  }
});

test('заявка с запретными словами отклоняется', async () => {
  const r = await suggestReq({ kind: 'halal', name: 'ИГИЛ', lat: 1, lng: 2 }, { GITHUB_TOKEN: 't', GITHUB_REPO: 'o/r' });
  assert.equal(r.status, 400);
});

import { fetchOverpass, overpassQuery, parseBbox, places, HALAL_NAMES, MOSQUE_NAMES } from '../src/places.js';

test('места: границы проверяются и округляются', () => {
  const p = (q) => parseBbox(new URLSearchParams(q));
  assert.deepEqual(p('s=55.701&w=37.501&n=55.81&e=37.71'), [55.7, 37.5, 55.82, 37.72]);
  assert.equal(p('s=55&w=37&n=58&e=38'), null); // слишком большая область
  assert.equal(p('s=x&w=37&n=55&e=38'), null);
});

test('места: при отказе первого зеркала берётся следующее', async () => {
  const calls = [];
  const fake = async (url) => {
    calls.push(url);
    if (calls.length === 1) return new Response('no', { status: 406 });
    return Response.json({ elements: [{ type: 'node', id: 1, lat: 55.7, lon: 37.6, tags: { name: 'Мечеть' } }] });
  };
  const r = await fetchOverpass('q', fake, ['https://a.test/api', 'https://b.test/api']);
  assert.equal(r.source, 'b.test');
  assert.equal(r.elements.length, 1);
});

test('места: Overpass недоступен → мечети из Photon', async () => {
  const fake = async (url) => {
    if (String(url).includes('photon')) {
      return Response.json({ features: [{ geometry: { coordinates: [37.62, 55.78] },
        properties: { osm_type: 'W', osm_id: 5, name: 'Соборная мечеть', street: 'Выползов переулок' } }] });
    }
    return new Response('busy', { status: 504 });
  };
  const res = await places(new Request('https://x/places?s=55.7&w=37.5&n=55.8&e=37.7'), {}, fake);
  assert.equal(res.status, 200);
  const body = await res.json();
  assert.equal(body.partial, true);
  assert.equal(body.elements.length, 1); // три запроса, один объект без дублей
  assert.equal(body.elements[0].tags.religion, 'muslim');
  assert.equal(body.elements[0].type, 'way');
});

test('места: все источники недоступны → 503', async () => {
  const fake = async () => new Response('busy', { status: 504 });
  const res = await places(new Request('https://x/places?s=55.7&w=37.5&n=55.8&e=37.7'), {}, fake);
  assert.equal(res.status, 503);
});

test('места: мечети и халяль выдаются отдельно, ищутся и по названию', () => {
  const q = overpassQuery([55.7, 37.5, 55.8, 37.7]);
  assert.match(q, /\.m out center tags \d+;/);
  assert.match(q, /\.h out center tags \d+;/);
  assert.match(q, /building"="mosque/);
  const halal = new RegExp(HALAL_NAMES);
  for (const n of ['Халяль маркет', 'ХАЛЯЛЬ', 'Кафе халяль', 'Halal Food', 'مطعم حلال']) assert.ok(halal.test(n), n);
  assert.ok(!halal.test('Шаурма'));
  const mosque = new RegExp(MOSQUE_NAMES);
  for (const n of ['Соборная мечеть', 'Мәчет', 'Masjid Al-Noor', 'Merkez Camii', 'مسجد']) assert.ok(mosque.test(n), n);
  assert.ok(!mosque.test('Храм Христа Спасителя'));
});

test('места: из Photon берутся заведения с «халяль» в названии, но не улицы', async () => {
  const fake = async (url) => {
    const u = String(url);
    if (!u.includes('photon')) return new Response('busy', { status: 504 });
    if (u.includes('q=halal') || u.includes(encodeURIComponent('халяль'))) {
      return Response.json({ features: [
        { geometry: { coordinates: [37.6, 55.75] }, properties: { osm_type: 'N', osm_id: 11, osm_key: 'shop', osm_value: 'butcher', name: 'Халяль мясо' } },
        { geometry: { coordinates: [37.61, 55.76] }, properties: { osm_type: 'W', osm_id: 12, osm_key: 'highway', osm_value: 'residential', name: 'Халяльная улица' } },
      ] });
    }
    return Response.json({ features: [] });
  };
  const res = await places(new Request('https://x/places?s=55.7&w=37.5&n=55.8&e=37.7'), {}, fake);
  const body = await res.json();
  assert.equal(body.elements.length, 1);
  assert.equal(body.elements[0].tags.shop, 'butcher');
});
