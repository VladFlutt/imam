import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../services/assistant.dart';
import '../services/quran.dart';
import '../theme.dart';
import 'quran.dart';

class _Msg {
  _Msg.user(this.text) : fromUser = true, reply = null;
  _Msg.bot(this.reply) : fromUser = false, text = null;
  final bool fromUser;
  final String? text;
  final AssistantReply? reply;
}

/// Чат с ИИ-помощником. История живёт только в памяти устройства.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Msg>[];
  bool _busy = false;

  Future<void> _send() async {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final q = _input.text.trim();
    if (q.isEmpty || _busy) return;
    if (s.aiUsedToday >= AppState.aiDailyLimit) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.t('ai_limit'))));
      return;
    }
    _input.clear();
    setState(() {
      _msgs.add(_Msg.user(q));
      _busy = true;
    });
    await s.countAiQuestion();
    final reply = await AssistantService.ask(
      q,
      lang: l.lang,
      trCode: s.quranTr,
    );
    if (!mounted) return;
    setState(() {
      _msgs.add(_Msg.bot(reply));
      _busy = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (_scroll.hasClients)
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10nScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.t('assistant'))),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              children: [
                _Bubble(
                  fromUser: false,
                  child: Text(
                    l.t('ai_intro'),
                    style: const TextStyle(height: 1.45),
                  ),
                ),
                for (final m in _msgs)
                  m.fromUser
                      ? _Bubble(
                          fromUser: true,
                          child: Text(
                            m.text!,
                            style: TextStyle(color: scheme.onPrimary),
                          ),
                        )
                      : _Bubble(
                          fromUser: false,
                          child: _ReplyView(reply: m.reply!),
                        ),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: l.t('ask_placeholder'),
                        filled: true,
                        fillColor: scheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: scheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: scheme.outlineVariant),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.fromUser, required this.child});
  final bool fromUser;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: fromUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: fromUser ? scheme.primary : scheme.surface,
          border: fromUser ? null : Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(18),
            topEnd: const Radius.circular(18),
            bottomStart: Radius.circular(fromUser ? 18 : 4),
            bottomEnd: Radius.circular(fromUser ? 4 : 18),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _ReplyView extends StatelessWidget {
  const _ReplyView({required this.reply});
  final AssistantReply reply;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = L10nScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final repo = QuranRepo.instance;
    final lead = switch (reply.kind) {
      FilterAction.refuse => l.t('ai_refuse'),
      FilterAction.specialist => l.t('ai_specialist'),
      FilterAction.imam => l.t('ai_imam'),
      FilterAction.allow =>
        reply.text ??
            (reply.ayat.isEmpty ? l.t('ai_no_ayat') : l.t('ai_offline')),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lead, style: const TextStyle(height: 1.45)),
        for (final a in reply.ayat.take(reply.text == null ? 5 : 3))
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: () => openAyah(context, a),
              child: Container(
                padding: const EdgeInsetsDirectional.only(start: 10),
                decoration: const BoxDecoration(
                  border: BorderDirectional(
                    start: BorderSide(color: Palette.gold, width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${a.surah.title(l.lang)} · ${s.num(a.ref)}',
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.quranTr == 'ar'
                          ? a.arabic
                          : repo.translation(a.surah.id, a.number, s.quranTr),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (reply.kind == FilterAction.allow ||
            reply.kind == FilterAction.imam) ...[
          const SizedBox(height: 10),
          Text(
            l.t('ai_disclaimer'),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }
}
