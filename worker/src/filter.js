// Тот же словарь, что и в приложении: app/assets/ai/blocklist.json.
import blocklist from '../../app/assets/ai/blocklist.json' with { type: 'json' };

const normalize = (s) => s.toLowerCase().replaceAll('ё', 'е').replace(/\s+/g, ' ');

const categories = Object.values(blocklist.categories).map((c) => ({
  action: c.action,
  stems: c.stems.map(normalize),
}));

/**
 * Возвращает 'refuse' | 'imam' | 'specialist' | 'allow'.
 * Совпадение — по началу слова; отказ важнее отсылки к имаму.
 */
export function check(text) {
  const t = ' ' + normalize(text);
  let result = 'allow';
  for (const { action, stems } of categories) {
    for (const s of stems) {
      if (t.includes(' ' + s) || t.includes('«' + s) || t.includes('"' + s)) {
        if (action === 'refuse') return 'refuse';
        if (action === 'specialist' || result === 'allow') result = action;
      }
    }
  }
  return result;
}
