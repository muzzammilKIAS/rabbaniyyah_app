import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';
import '../shared/match_pairs_activity.dart';
import '../shared/word_order_activity.dart';

/// أُفَكِّرُ وَأَكْتُبُ — أربعة أنشطة: طابق الملك بالعمل، طابق الكتاب
/// بالرسول، أكمل الجمل، رتب الكلمات.
class ThinkWriteCard2 extends StatefulWidget {
  const ThinkWriteCard2({super.key});

  @override
  State<ThinkWriteCard2> createState() => _ThinkWriteCard2State();
}

class _ThinkWriteCard2State extends State<ThinkWriteCard2> {
  final _angelKey = GlobalKey<MatchPairsActivityState>();
  final _bookKey = GlobalKey<MatchPairsActivityState>();
  late Map<int, int> _angelInitial;
  late Map<int, int> _bookInitial;

  late List<String?> _fillAnswers;
  List<bool?>? _fillResults;

  final List<GlobalKey<WordOrderActivityRowState>> _woKeys =
      List.generate(Dars112.wordOrder.length, (_) => GlobalKey<WordOrderActivityRowState>());
  late List<List<String>> _woInitial;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();

    Map<int, int> loadPairs(String key) =>
        app.dars112Get<Map<String, dynamic>>(key, {}).map((k, v) => MapEntry(int.parse(k), v as int));
    _angelInitial = loadPairs('angelPairs');
    _bookInitial = loadPairs('bookPairs');

    final savedFill = app.dars112Get<Map<String, dynamic>>('fillAnswers', {});
    _fillAnswers = List.generate(Dars112.fillItems.length, (i) => savedFill[i.toString()] as String?);

    _woInitial = List.generate(Dars112.wordOrder.length, (i) {
      final saved = app.dars112Get<String>('wo$i', '');
      return saved.isEmpty ? <String>[] : saved.split('|');
    });
  }

  void _checkFill() {
    setState(() {
      _fillResults = List.generate(Dars112.fillItems.length, (i) {
        if (_fillAnswers[i] == null) return null;
        return _fillAnswers[i] == Dars112.fillItems[i].answer;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fillCorrectCount = _fillResults?.where((v) => v == true).length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('✍️ النَّشَاطُ ١: طَابِقْ بَيْنَ الْمَلَكِ وَالْعَمَلِ'),
          const SizedBox(height: 14),
          MatchPairsActivity(
            key: _angelKey,
            rightItems: Dars112.angelNames,
            leftItems: Dars112.angelTasks,
            correctIndexForRight: Dars112.angelCorrectIndex,
            rightHeader: 'الْمَلَكُ',
            leftHeader: 'الْعَمَلُ',
            initialPairs: _angelInitial,
            onChanged: (pairs) => context.read<AppState>().dars112Set('angelPairs', pairs.map((k, v) => MapEntry(k.toString(), v))),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(_angelKey.currentState!.check),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('تحقق'),
              ),
              const SizedBox(width: 10),
              ScoreBadge(
                correct: _angelKey.currentState?.results != null ? _angelKey.currentState!.correctCount : null,
                total: _angelKey.currentState?.results != null ? Dars112.angelNames.length : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: c.border),
          const SizedBox(height: 14),
          const CardHeading('✍️ النَّشَاطُ الثَّانِي: طَابِقْ بَيْنَ الْكِتَابِ وَالرَّسُولِ'),
          const SizedBox(height: 14),
          MatchPairsActivity(
            key: _bookKey,
            rightItems: Dars112.bookProphets,
            leftItems: Dars112.bookNames,
            correctIndexForRight: Dars112.bookCorrectIndex,
            rightHeader: 'الرَّسُولُ',
            leftHeader: 'الْكِتَابُ',
            initialPairs: _bookInitial,
            onChanged: (pairs) => context.read<AppState>().dars112Set('bookPairs', pairs.map((k, v) => MapEntry(k.toString(), v))),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(_bookKey.currentState!.check),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('تحقق'),
              ),
              const SizedBox(width: 10),
              ScoreBadge(
                correct: _bookKey.currentState?.results != null ? _bookKey.currentState!.correctCount : null,
                total: _bookKey.currentState?.results != null ? Dars112.bookProphets.length : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: c.border),
          const SizedBox(height: 14),
          const CardHeading('✍️ النَّشَاطُ الثَّالِثُ: أَكْمِلِ الْجُمَلَ'),
          const CardInstruction('اِخْتَرِ الْكَلِمَةَ الْمُنَاسِبَةَ مِنَ الصُّنْدُوقِ وَاكْتُبْهَا فِي الْفَرَاغِ.'),
          const SizedBox(height: 14),
          for (var i = 0; i < Dars112.fillItems.length; i++)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: c.surface2.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _fillResults == null || _fillResults![i] == null ? c.border : (_fillResults![i] == true ? c.success : c.danger),
                  width: 1.4,
                ),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
                    child: Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c.accent)),
                  ),
                  Text(Dars112.fillItems[i].before, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 18, color: c.text)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _fillResults == null || _fillResults![i] == null
                            ? c.accent.withValues(alpha: 0.4)
                            : (_fillResults![i] == true ? c.success : c.danger),
                        width: 1.6,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: c.surface,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _fillAnswers[i],
                        hint: const Text('— اختر —', style: TextStyle(fontSize: 13.5)),
                        style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 17, color: c.accent, fontWeight: FontWeight.bold),
                        dropdownColor: c.surface,
                        items: Dars112.fillBank.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                        onChanged: (v) {
                          setState(() {
                            _fillAnswers[i] = v;
                            _fillResults = null;
                          });
                          context.read<AppState>().dars112Set('fillAnswers', {for (var j = 0; j < _fillAnswers.length; j++) j.toString(): _fillAnswers[j]});
                        },
                      ),
                    ),
                  ),
                  Text(Dars112.fillItems[i].after, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 18, color: c.text)),
                  if (_fillResults != null && _fillResults![i] != null)
                    Icon(_fillResults![i] == true ? Icons.check_circle_rounded : Icons.cancel_rounded, color: _fillResults![i] == true ? c.success : c.danger, size: 20),
                ],
              ),
            ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _checkFill,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('تحقق من الإجابات'),
              ),
              const SizedBox(width: 12),
              ScoreBadge(correct: fillCorrectCount, total: fillCorrectCount != null ? Dars112.fillItems.length : null),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: c.border),
          const SizedBox(height: 14),
          const CardHeading('✍️ النَّشَاطُ الرَّابِعُ: رَتِّبِ الْكَلِمَاتِ لِتَكْوِينِ جُمْلَةٍ'),
          const CardInstruction('اُنْقُرِ الكَلِمَاتِ بِالتَّرْتِيبِ الصَّحِيحِ لِبِنَاءِ الجُمْلَةِ المفيدة:'),
          const SizedBox(height: 16),
          for (var i = 0; i < Dars112.wordOrder.length; i++) ...[
            WordOrderActivityRow(
              key: _woKeys[i],
              index: i,
              item: Dars112.wordOrder[i],
              initialSelected: _woInitial[i],
              onChanged: (sel) => context.read<AppState>().dars112Set('wo$i', sel.join('|')),
            ),
            if (i != Dars112.wordOrder.length - 1) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
