import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

class MatchingCard extends StatefulWidget {
  const MatchingCard({super.key});

  @override
  State<MatchingCard> createState() => _MatchingCardState();
}

class _MatchingCardState extends State<MatchingCard> {
  String? _selectedName;
  Map<String, String> _pairs = {};
  Map<String, bool>? _results; // name -> correct?

  @override
  void initState() {
    super.initState();
    final raw = context.read<AppState>().dars111Get<Map<String, dynamic>>('matchPairs', {});
    _pairs = raw.map((k, v) => MapEntry(k, v.toString()));
  }

  void _save() => context.read<AppState>().dars111Set('matchPairs', _pairs);

  void _check() {
    final results = <String, bool>{};
    for (final n in Dars111.matchNames) {
      if (_pairs[n] != null) {
        results[n] = _pairs[n] == Dars111.matchAnswer[n];
      }
    }
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final usedMeanings = _pairs.values.toSet();
    final correctCount = _results?.values.where((v) => v).length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('النَّشَاطُ الأَوَّلُ: اِرْبِطِ الاسْمَ بِالمَعْنَى'),
          const CardInstruction('اُنْقُرِ اسْمًا ثُمَّ اُنْقُرْ مَعْنَاهُ المُنَاسِبَ مَعَ زَمِيلِكَ شَفَهِيًّا.'),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.label_outline_rounded, size: 14, color: c.accent),
                        const SizedBox(width: 4),
                        Text('الاسم الكريم', style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final n in Dars111.matchNames)
                      _Chip(
                        label: n,
                        arabic: true,
                        selected: _selectedName == n,
                        done: _pairs.containsKey(n),
                        status: _results?[n],
                        onTap: _pairs.containsKey(n)
                            ? () {
                                setState(() {
                                  _pairs.remove(n);
                                  _results = null;
                                });
                                _save();
                              }
                            : () => setState(() => _selectedName = n),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.translate_rounded, size: 14, color: c.gold),
                        const SizedBox(width: 4),
                        Text('المعنى (Makna)', style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final m in Dars111.matchMeanings)
                      _Chip(
                        label: m,
                        arabic: false,
                        selected: false,
                        done: usedMeanings.contains(m),
                        status: null,
                        onTap: (usedMeanings.contains(m) || _selectedName == null)
                            ? null
                            : () {
                                setState(() {
                                  _pairs[_selectedName!] = m;
                                  _selectedName = null;
                                  _results = null;
                                });
                                _save();
                              },
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_pairs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _pairs.entries.map((e) {
                final isCorrect = _results?[e.key];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isCorrect == true
                        ? c.successSoft
                        : (isCorrect == false ? c.dangerSoft : c.surface2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCorrect == true
                          ? c.success
                          : (isCorrect == false ? c.danger : c.border),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${e.key} : ${e.value}', style: TextStyle(fontSize: 12, color: c.text)),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _pairs.remove(e.key);
                            _results = null;
                          });
                          _save();
                        },
                        child: Icon(Icons.close_rounded, size: 14, color: c.textMuted),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _pairs.isEmpty ? null : _check,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('تحقق من الإجابات'),
              ),
              if (_pairs.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _pairs.clear();
                      _selectedName = null;
                      _results = null;
                    });
                    _save();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('إعادة البدء'),
                ),
              ScoreBadge(correct: correctCount, total: correctCount != null ? Dars111.matchNames.length : null),
              if (correctCount == Dars111.matchNames.length)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: c.successSoft, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: c.success),
                      const SizedBox(width: 4),
                      Text('إجابة كاملة ممتازة!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.success)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.arabic, required this.selected, required this.done, required this.status, required this.onTap});
  final String label;
  final bool arabic;
  final bool selected;
  final bool done;
  final bool? status; // null = unknown, true/false after check
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color border = c.border;
    Color? bg = c.surface2;
    if (selected) { border = c.accent2; bg = c.accent2Soft; }
    if (status == true) { border = c.success; bg = c.successSoft; }
    if (status == false) { border = c.danger; bg = c.dangerSoft; }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 46,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(border: Border.all(color: border), borderRadius: BorderRadius.circular(9)),
            child: Opacity(
              opacity: done && !selected && status == null ? 0.55 : 1,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: arabic ? AppTheme.arabicFont : null,
                  fontSize: arabic ? 16 : 13.5,
                  color: c.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
