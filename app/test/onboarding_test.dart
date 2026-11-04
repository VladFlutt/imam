import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imam/app_state.dart';
import 'package:imam/l10n.dart';
import 'package:imam/l10n_onboarding.dart';
import 'package:imam/screens/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('тексты знакомства есть на всех языках', () {
    final keys = onboardingStrings['ru']!.keys.toSet();
    for (final lang in L10n.supported) {
      final m = onboardingStrings[lang];
      expect(m, isNotNull, reason: lang);
      expect(m!.keys.toSet(), keys, reason: lang);
      for (final v in m.values) {
        expect(v.trim(), isNotEmpty, reason: lang);
      }
    }
    expect(L10n('ar').t('onb_start'), 'ابدأ');
    expect(L10n('kk').t('onb_next'), 'Келесі');
  });

  testWidgets('выбор языка → знакомство на этом языке → флаг сохранён', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'lang': 'ru'});
    final state = await AppState.load();
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: Builder(
          builder: (context) {
            final l = AppScope.of(context).l10n;
            return L10nScope(
              l10n: l,
              child: MaterialApp(
                builder: (context, child) => Directionality(
                  textDirection: l.isRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: child!,
                ),
                home: AppScope.of(context).onboarded
                    ? const Text('home')
                    : const OnboardingScreen(),
              ),
            );
          },
        ),
      ),
    );
    expect(find.text('Выберите язык'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(state.lang, 'ar');
    expect(find.text('اختر اللغة'), findsOneWidget);

    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(find.text('السلام عليكم!'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('السلام عليكم!'))),
      TextDirection.rtl,
    );
    expect(state.onboarded, isFalse);

    await tester.tap(find.text('تخطٍّ'));
    await tester.pumpAndSettle();
    expect(state.onboarded, isTrue);
    expect(find.text('home'), findsOneWidget);
  });
}
