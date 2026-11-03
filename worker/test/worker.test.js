import { test } from 'node:test';
import assert from 'node:assert/strict';
import worker, { cleanCitations, validate } from '../src/index.js';
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
