import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

/// النشاط ١ (طابق السؤال بالحرف المناسب) والنشاط ٢ (كارد الحوار).
class SpeakingCard4 extends StatefulWidget {
  const SpeakingCard4({super.key});

  @override
  State<SpeakingCard4> createState() => _SpeakingCard4State();
}

class _SpeakingCard4State extends State<SpeakingCard4> {
  int? _selectedQuestion;
  final Map<int, int> _pairs = {}; // questionIndex -> answerIndex chosen
  Map<int, bool>? _results;

  @override
  void initState() {
    super.initState();
    final raw = context.read<AppState>().dars114Get<Map<String, dynamic>>('speakingPairs', {});
    raw.forEach((k, v) => _pairs[int.parse(k)] = v as int);
  }

  void _save() {
    context.read<AppState>().dars114Set('speakingPairs', _pairs.map((k, v) => MapEntry(k.toString(), v)));
  }

  void _check() {
    setState(() {
      _results = {
        for (final entry in _pairs.entries) entry.key: entry.value == Dars114.matchCorrectIndex[entry.key],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final usedAnswers = _pairs.values.toSet();
    final correctCount = _results?.values.where((v) => v).length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('🗣️ النَّشَاطُ ١: طَابِقِ السُّؤَالَ بِالْحَرْفِ الْمُنَاسِبِ'),
          const CardInstruction('اِقْرَأِ الْأَسْئِلَةَ وَالْأَجْوِبَةَ، ثُمَّ اُنْقُرْ سُؤَالاً ثُمَّ الْجَوَابَ الْمُنَاسِبَ لَهُ، مَعَ زَمِيلِكَ شَفَهِيًّا.'),
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
                        Icon(Icons.help_outline_rounded, size: 14, color: c.accent),
                        const SizedBox(width: 4),
                        Text('الأَسْئِلَةُ', style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < Dars114.matchQuestions.length; i++)
                      _Chip4(
                        label: '${i + 1}) ${Dars114.matchQuestions[i]}',
                        selected: _selectedQuestion == i,
                        done: _pairs.containsKey(i),
                        status: _results?[i],
                        onTap: _pairs.containsKey(i)
                            ? () {
                                setState(() {
                                  _pairs.remove(i);
                                  _results = null;
                                });
                                _save();
                              }
                            : () => setState(() => _selectedQuestion = i),
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
                        Icon(Icons.chat_bubble_outline_rounded, size: 14, color: c.gold),
                        const SizedBox(width: 4),
                        Text('الأَجْوِبَةُ', style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < Dars114.matchAnswers.length; i++)
                      _Chip4(
                        label: '${Dars114.matchAnswerLetters[i]}) ${Dars114.matchAnswers[i]}',
                        selected: false,
                        done: usedAnswers.contains(i),
                        status: null,
                        onTap: (usedAnswers.contains(i) || _selectedQuestion == null)
                            ? null
                            : () {
                                setState(() {
                                  _pairs[_selectedQuestion!] = i;
                                  _selectedQuestion = null;
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
          const SizedBox(height: 14),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pairs.isEmpty ? null : _check,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('تحقق من الإجابات'),
              ),
              const SizedBox(width: 10),
              ScoreBadge(correct: correctCount, total: correctCount != null ? Dars114.matchQuestions.length : null),
            ],
          ),
          const SizedBox(height: 28),
          Divider(color: c.border),
          const SizedBox(height: 14),
          const CardHeading('👥 النَّشَاطُ ٢: كَارْدُ الحِوَارِ'),
          const CardInstruction('اِسْأَلْ زَمِيلَكَ وَأَجِبْ. ثُمَّ تَبَادَلَا الدَّوْرَ.'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: c.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: c.surface2, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('الطَّالِبُ (ب) 👤', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.textMuted)),
                      ),
                      Expanded(
                        child: Text('الطَّالِبُ (أ) 👤', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.textMuted)),
                      ),
                    ],
                  ),
                ),
                for (var i = 0; i < Dars114.dialogue.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: c.border.withValues(alpha: 0.6))),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(Dars114.dialogue[i].studentB,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15.5, height: 1.7, color: c.text)),
                        ),
                        Container(width: 1, height: 40, color: c.border),
                        Expanded(
                          child: Text(Dars114.dialogue[i].studentA,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15.5, height: 1.7, fontWeight: FontWeight.w600, color: c.accent)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text('الآنَ: بَدِّلِ الدَّوْرَ وَاسْتَخْدِمْ كَلِمَاتٍ أُخْرَى مِنَ الْجَدْوَلِ. 🔄',
              style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 14, color: c.textMuted)),
        ],
      ),
    );
  }
}

class _Chip4 extends StatelessWidget {
  const _Chip4({required this.label, required this.selected, required this.done, required this.status, required this.onTap});
  final String label;
  final bool selected;
  final bool done;
  final bool? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Color border = c.border;
    Color? bg = c.surface2;
    if (selected) {
      border = c.accent2;
      bg = c.accent2Soft;
    }
    if (status == true) {
      border = c.success;
      bg = c.successSoft;
    }
    if (status == false) {
      border = c.danger;
      bg = c.dangerSoft;
    }

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
            constraints: const BoxConstraints(minHeight: 46),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: border), borderRadius: BorderRadius.circular(9)),
            child: Opacity(
              opacity: done && !selected && status == null ? 0.55 : 1,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 14.5, color: c.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
