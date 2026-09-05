import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_text.dart';
import '../common.dart';

class TransformAndWordOrderCard extends StatefulWidget {
  const TransformAndWordOrderCard({super.key});

  @override
  State<TransformAndWordOrderCard> createState() => _TransformAndWordOrderCardState();
}

class _TransformAndWordOrderCardState extends State<TransformAndWordOrderCard> {
  late List<TextEditingController> _transformCtrls;
  List<bool?>? _transformResults;
  late List<List<String>> _selectedPills;
  late List<bool?> _woResults;
  final Set<int> _revealed = {};

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _transformCtrls = List.generate(
      Dars111.transformPairs.length,
      (i) => TextEditingController(text: app.dars111Get('transform$i', '')),
    );

    _selectedPills = List.generate(Dars111.wordOrder.length, (i) {
      final saved = app.dars111Get('wo$i', '');
      if (saved.isNotEmpty) {
        // if user previously saved, try to split
        final words = saved.replaceAll('.', '').split(' ').where((w) => w.trim().isNotEmpty).toList();
        if (words.length == Dars111.wordOrder[i].tokens.length) {
          return words;
        }
      }
      return <String>[];
    });

    _woResults = List.generate(Dars111.wordOrder.length, (_) => null);
  }

  @override
  void dispose() {
    for (final c in _transformCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _checkTransform() {
    setState(() {
      _transformResults = List.generate(Dars111.transformPairs.length, (i) {
        final v = _transformCtrls[i].text.trim();
        if (v.isEmpty) return null;
        return stripTashkeel(v) == stripTashkeel(Dars111.transformPairs[i].$2);
      });
    });
  }

  void _checkWo(int i) {
    final constructed = _selectedPills[i].join(' ');
    final target = Dars111.wordOrder[i].answer.replaceAll('.', '').trim();
    final isCorrect = stripTashkeel(constructed) == stripTashkeel(target);
    setState(() {
      _woResults[i] = isCorrect;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final correctCount = _transformResults?.where((v) => v == true).length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('النَّشَاطُ ٣: حَوِّلِ الاسْمَ بِدُونِ "الـ" إِلَى مَعَ "الـ"'),
          const CardInstruction('مِثَالٌ: رَحِيمٌ ← الرَّحِيمُ (اُكْتُبْ بِـ "الـ")'),
          const SizedBox(height: 14),
          Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1.2)},
            children: [
              for (var i = 0; i < Dars111.transformPairs.length; i++)
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: c.surface2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        Dars111.transformPairs[i].$1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.arabicFont,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: c.text,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: TextField(
                      controller: _transformCtrls[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.arabicFont,
                        fontSize: 17,
                        color: c.accent,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب هنا…',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _transformResults == null || _transformResults![i] == null
                                ? c.border
                                : (_transformResults![i] == true ? c.success : c.danger),
                            width: 1.6,
                          ),
                        ),
                      ),
                      onChanged: (_) => context.read<AppState>().dars111Set('transform$i', _transformCtrls[i].text),
                    ),
                  ),
                ]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _checkTransform,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('تحقق من التحويل'),
              ),
              ScoreBadge(correct: correctCount, total: correctCount != null ? Dars111.transformPairs.length : null),
            ],
          ),
          const SizedBox(height: 28),
          Divider(color: c.border),
          const SizedBox(height: 12),
          const CardHeading('النَّشَاطُ ٤: رَتِّبِ الكَلِمَاتِ لِتَكْوِينِ جُمْلَةٍ'),
          const CardInstruction('اُنْقُرِ الكَلِمَاتِ بِالتَّرْتِيبِ الصَّحِيحِ لِبِنَاءِ الجُمْلَةِ المفيدة:'),
          const SizedBox(height: 16),
          for (var i = 0; i < Dars111.wordOrder.length; i++) ...[
            _WordOrderInteractiveRow(
              index: i,
              item: Dars111.wordOrder[i],
              selectedPills: _selectedPills[i],
              result: _woResults[i],
              isRevealed: _revealed.contains(i),
              onToggleReveal: () => setState(() {
                if (_revealed.contains(i)) {
                  _revealed.remove(i);
                } else {
                  _revealed.add(i);
                }
              }),
              onPillsChanged: (newList) {
                setState(() {
                  _selectedPills[i] = newList;
                  _woResults[i] = null;
                });
                context.read<AppState>().dars111Set('wo$i', newList.join(' '));
                if (newList.length == Dars111.wordOrder[i].tokens.length) {
                  _checkWo(i);
                }
              },
            ),
            if (i != Dars111.wordOrder.length - 1) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class _WordOrderInteractiveRow extends StatelessWidget {
  const _WordOrderInteractiveRow({
    required this.index,
    required this.item,
    required this.selectedPills,
    required this.result,
    required this.isRevealed,
    required this.onToggleReveal,
    required this.onPillsChanged,
  });

  final int index;
  final WordOrderItem item;
  final List<String> selectedPills;
  final bool? result;
  final bool isRevealed;
  final VoidCallback onToggleReveal;
  final ValueChanged<List<String>> onPillsChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final availableTokens = List<String>.from(item.tokens);
    for (final s in selectedPills) {
      availableTokens.remove(s);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result == true
            ? c.successSoft.withValues(alpha: 0.4)
            : (result == false ? c.dangerSoft.withValues(alpha: 0.3) : c.surface2.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result == true
              ? c.success
              : (result == false ? c.danger : c.border),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'الجملة ${index + 1}',
                  style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              if (selectedPills.isNotEmpty)
                TextButton.icon(
                  onPressed: () => onPillsChanged([]),
                  icon: const Icon(Icons.clear_all_rounded, size: 14),
                  label: const Text('إعادة ضبط', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Constructed sentence target box
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedPills.isEmpty ? c.border : c.accent,
                width: 1.2,
              ),
            ),
            child: selectedPills.isEmpty
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'انقر الكلمات أدناه لوضعها هنا…',
                      style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 15, color: c.textMuted),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (var idx = 0; idx < selectedPills.length; idx++)
                        InkWell(
                          onTap: () {
                            final updated = List<String>.from(selectedPills)..removeAt(idx);
                            onPillsChanged(updated);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: c.accentSoft,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: c.accent),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedPills[idx],
                                  style: TextStyle(
                                    fontFamily: AppTheme.arabicFont,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: c.accent,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.cancel_rounded, size: 13, color: c.accent),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          // Available words bank
          Text(
            'بنك الكلمات المربعة:',
            style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 15.5, fontWeight: FontWeight.w700, color: c.textMuted),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: availableTokens.map((t) {
              return InkWell(
                onTap: () {
                  final updated = List<String>.from(selectedPills)..add(t);
                  onPillsChanged(updated);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.goldBorder, width: 1.4),
                    boxShadow: [
                      BoxShadow(color: c.cardShadow, blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        t,
                        style: TextStyle(
                          fontFamily: AppTheme.arabicFont,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: c.text,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (result == true)
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: c.success, size: 18),
                    const SizedBox(width: 6),
                    Text('صحيح! ممتاز', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.success)),
                  ],
                )
              else if (result == false)
                Row(
                  children: [
                    Icon(Icons.cancel_rounded, color: c.danger, size: 18),
                    const SizedBox(width: 6),
                    Text('حاول مرة أخرى', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.danger)),
                  ],
                ),
              const Spacer(),
              TextButton(
                onPressed: onToggleReveal,
                child: Text(
                  isRevealed ? 'إخفاء الحل' : 'إظهار الحل النموذجي',
                  style: TextStyle(fontSize: 12, color: c.gold, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (isRevealed)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.goldBorder),
              ),
              child: Text(
                'الحل: ${item.answer}',
                style: TextStyle(
                  fontFamily: AppTheme.arabicFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: c.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
