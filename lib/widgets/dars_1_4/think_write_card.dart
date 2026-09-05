import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_text.dart';
import '../common.dart';

/// أُفَكِّرُ وَأَكْتُبُ — ثلاثة أنشطة: رتب الخطوات، أكمل الجمل، اكتب بأسلوبك.
class ThinkWriteCard4 extends StatefulWidget {
  const ThinkWriteCard4({super.key});

  @override
  State<ThinkWriteCard4> createState() => _ThinkWriteCard4State();
}

class _ThinkWriteCard4State extends State<ThinkWriteCard4> {
  // النشاط ١: رتب الخطوات — كل خطوة مسبوقة بكلمة الترتيب الصحيحة، تُبنى
  // الجملة الكاملة بالنقر على القطع بالترتيب.
  late final List<String> _chunks;
  late List<String> _selected;
  bool? _orderResult;

  // النشاط ٢: أكمل الجمل
  late List<String?> _fillAnswers;
  List<bool?>? _fillResults;

  // النشاط ٣: اكتب بأسلوبك
  late List<TextEditingController> _freeCtrls;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();

    _chunks = List.generate(
      Dars114.orderSteps.length,
      (i) => '${Dars114.orderWords[i]} ${Dars114.orderSteps[i]}',
    );
    final saved = app.dars114Get<String>('orderSelected', '');
    _selected = saved.isEmpty ? [] : saved.split('|');

    final savedFill = app.dars114Get<Map<String, dynamic>>('fillAnswers', {});
    _fillAnswers = List.generate(Dars114.fillItems.length, (i) => savedFill[i.toString()] as String?);

    _freeCtrls = List.generate(3, (i) => TextEditingController(text: app.dars114Get('free${i + 1}', '')));
  }

  @override
  void dispose() {
    for (final c in _freeCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveOrder() {
    context.read<AppState>().dars114Set('orderSelected', _selected.join('|'));
  }

  void _checkOrder() {
    final constructed = _selected.join(' ');
    final target = _chunks.join(' ');
    setState(() => _orderResult = stripTashkeel(constructed) == stripTashkeel(target));
  }

  void _checkFill() {
    setState(() {
      _fillResults = List.generate(Dars114.fillItems.length, (i) {
        if (_fillAnswers[i] == null) return null;
        return _fillAnswers[i] == Dars114.fillItems[i].answer;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final available = List<String>.from(_chunks)..removeWhere(_selected.contains);
    final fillCorrectCount = _fillResults?.where((v) => v == true).length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('✍️ النَّشَاطُ ١: رَتِّبِ الخُطُوَاتِ'),
          const CardInstruction(
            'رَتِّبِ الخُطُوَاتِ الآتِيَةَ بِاسْتِخْدَامِ كَلِمَاتِ التَّرْتِيبِ (أَوَّلاً – ثُمَّ – بَعْدَ ذَلِكَ – أَخِيراً)، بِالنَّقْرِ عَلَى القِطَعِ أَدْنَاهُ بِالتَّرْتِيبِ الصَّحِيحِ:',
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _selected.isEmpty ? c.border : c.accent, width: 1.2),
            ),
            child: _selected.isEmpty
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Text('انقر القطع أدناه لبناء الترتيب هنا…',
                        style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 14.5, color: c.textMuted)),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (var i = 0; i < _selected.length; i++)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _selected = List.from(_selected)..removeAt(i);
                              _orderResult = null;
                            });
                            _saveOrder();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: c.accentSoft,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: c.accent),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_selected[i],
                                    style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, fontWeight: FontWeight.bold, color: c.accent)),
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
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: available.map((t) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _selected = List.from(_selected)..add(t);
                    _orderResult = null;
                  });
                  _saveOrder();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.goldBorder, width: 1.4),
                  ),
                  child: Text(t, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, fontWeight: FontWeight.w700, color: c.text)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _selected.length == _chunks.length ? _checkOrder : null,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('تحقق من الترتيب'),
              ),
              const SizedBox(width: 10),
              if (_orderResult == true)
                Text('صحيح! ممتاز', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.success))
              else if (_orderResult == false)
                Text('حاول مرة أخرى', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.danger)),
            ],
          ),
          const SizedBox(height: 28),
          Divider(color: c.border),
          const SizedBox(height: 14),
          const CardHeading('✍️ النَّشَاطُ ٢: أَكْمِلِ الْجُمَلَ'),
          const CardInstruction('اِخْتَرِ الْكَلِمَةَ الْمُنَاسِبَةَ مِنَ الصُّنْدُوقِ وَاكْتُبْهَا فِي الْفَرَاغِ.'),
          const SizedBox(height: 14),
          for (var i = 0; i < Dars114.fillItems.length; i++)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: c.surface2.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _fillResults == null || _fillResults![i] == null
                      ? c.border
                      : (_fillResults![i] == true ? c.success : c.danger),
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
                  if (Dars114.fillItems[i].before.isNotEmpty)
                    Text(Dars114.fillItems[i].before, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 18, color: c.text)),
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
                        items: Dars114.fillBank.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                        onChanged: (v) {
                          setState(() {
                            _fillAnswers[i] = v;
                            _fillResults = null;
                          });
                          context.read<AppState>().dars114Set(
                              'fillAnswers', {for (var j = 0; j < _fillAnswers.length; j++) j.toString(): _fillAnswers[j]});
                        },
                      ),
                    ),
                  ),
                  Text(Dars114.fillItems[i].after, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 18, color: c.text)),
                  if (_fillResults != null && _fillResults![i] != null)
                    Icon(_fillResults![i] == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: _fillResults![i] == true ? c.success : c.danger, size: 20),
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
              ScoreBadge(correct: fillCorrectCount, total: fillCorrectCount != null ? Dars114.fillItems.length : null),
            ],
          ),
          const SizedBox(height: 28),
          Divider(color: c.border),
          const SizedBox(height: 14),
          const CardHeading('✍️ النَّشَاطُ ٣: كِتَابَةُ الْجُمَلِ'),
          const CardInstruction('اُكْتُبْ ثَلَاثَ جُمَلٍ بِأُسْلُوبِكَ الْخَاصِّ تَصِفُ فِيهَا خُطُوَاتِ الوُضُوءِ، مُسْتَخْدِماً كَلِمَاتِ التَّرْتِيبِ:'),
          const SizedBox(height: 12),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _freeCtrls[i],
                style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 17),
                decoration: InputDecoration(
                  hintText: 'اكتب جملتك هنا…',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('(${i + 1})', style: TextStyle(fontSize: 12, color: c.textMuted)),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                onChanged: (v) => context.read<AppState>().dars114Set('free${i + 1}', v),
              ),
            ),
        ],
      ),
    );
  }
}
