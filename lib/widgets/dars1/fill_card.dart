import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

class FillCard extends StatefulWidget {
  const FillCard({super.key});

  @override
  State<FillCard> createState() => _FillCardState();
}

class _FillCardState extends State<FillCard> {
  late List<String?> _answers;
  List<bool?>? _results;
  late List<TextEditingController> _freeControllers;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    final saved = app.dars111Get<Map<String, dynamic>>('fillAnswers', {});
    _answers = List.generate(Dars111.fillItems.length, (i) => saved[i.toString()] as String?);
    _freeControllers = List.generate(3, (i) => TextEditingController(text: app.dars111Get('free${i + 1}', '')));
  }

  @override
  void dispose() {
    for (final c in _freeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final map = <String, dynamic>{};
    for (var i = 0; i < _answers.length; i++) {
      map[i.toString()] = _answers[i];
    }
    context.read<AppState>().dars111Set('fillAnswers', map);
  }

  void _check() {
    setState(() {
      _results = List.generate(Dars111.fillItems.length, (i) {
        if (_answers[i] == null) return null;
        return _answers[i] == Dars111.fillItems[i].answer;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final correctCount = _results?.where((v) => v == true).length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('النَّشَاطُ ٢: اِخْتَرِ الكَلِمَةَ الصَّحِيحَةَ'),
          const CardInstruction('اِخْتَرِ الاسْمَ المُنَاسِبَ مِنَ القَائِمَةِ لِكُلِّ جُمْلَةٍ.'),
          const SizedBox(height: 14),
          for (var i = 0; i < Dars111.fillItems.length; i++)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: c.surface2.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _results == null || _results![i] == null
                      ? c.border
                      : (_results![i] == true ? c.success : c.danger),
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
                    decoration: BoxDecoration(
                      color: c.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c.accent),
                    ),
                  ),
                  Text(Dars111.fillItems[i].before, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 18, color: c.text)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _results == null || _results![i] == null
                            ? c.accent.withValues(alpha: 0.4)
                            : (_results![i] == true ? c.success : c.danger),
                        width: 1.6,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: c.surface,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _answers[i],
                        hint: const Text('— اختر الاسم —', style: TextStyle(fontSize: 13.5)),
                        style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 17, color: c.accent, fontWeight: FontWeight.bold),
                        dropdownColor: c.surface,
                        items: Dars111.fillBank
                            .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                            .toList(),
                        onChanged: (v) {
                          setState(() { _answers[i] = v; _results = null; });
                          _save();
                        },
                      ),
                    ),
                  ),
                  Text(Dars111.fillItems[i].after, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 18, color: c.text)),
                  if (_results != null && _results![i] != null)
                    Icon(
                      _results![i] == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: _results![i] == true ? c.success : c.danger,
                      size: 20,
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _check,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('تحقق من الإجابات'),
              ),
              const SizedBox(width: 12),
              ScoreBadge(correct: correctCount, total: correctCount != null ? Dars111.fillItems.length : null),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: c.border),
          const SizedBox(height: 8),
          const CardInstruction('أَكْمِلِ الجُمَلَ بِاسْمٍ آخَرَ مِنْ أَسْمَاءِ اللهِ الحُسْنَى (إِجَابَةٌ مَفْتُوحَةٌ ✍️):'),
          const SizedBox(height: 12),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _freeControllers[i],
                style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 17),
                decoration: InputDecoration(
                  hintText: 'اللَّهُ …',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('(${i + 1})', style: TextStyle(fontSize: 12, color: c.textMuted)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                onChanged: (v) => context.read<AppState>().dars111Set('free${i + 1}', v),
              ),
            ),
        ],
      ),
    );
  }
}
