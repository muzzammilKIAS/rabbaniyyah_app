import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

class _Frame10 extends StatefulWidget {
  const _Frame10({required this.storeKey, this.hint, this.label});
  final String storeKey;
  final String? hint;
  final String? label;

  @override
  State<_Frame10> createState() => _Frame10State();
}

class _Frame10State extends State<_Frame10> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: context.read<AppState>().dars1110Get(widget.storeKey, ''));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!,
              style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 15.5, fontWeight: FontWeight.w700, color: c.textMuted)),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: _ctrl,
          maxLines: 2,
          minLines: 1,
          style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 17, height: 1.6),
          decoration: InputDecoration(hintText: widget.hint, hintStyle: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 15)),
          onChanged: (v) => context.read<AppState>().dars1110Set(widget.storeKey, v),
        ),
      ],
    );
  }
}

class ReflectionCard10 extends StatelessWidget {
  const ReflectionCard10({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeading('💭 السِّيرَةُ وَالحَيَاةُ'),
          CardInstruction('سُؤَالٌ لِلتَّفْكِيرِ: مَاذَا تَعَلَّمْتَ مِنْ حَيَاةِ النَّبِيِّ فِي طُفُولَتِهِ وَشَبَابِهِ؟'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(10)),
            child: Text('١) ${Dars1110.thinkingFirstReason}',
                style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15.5, height: 1.7, color: c.text)),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Text('٢) ', style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, color: c.textMuted)),
            const Expanded(child: _Frame10(storeKey: 'reason2')),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Text('٣) ', style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, color: c.textMuted)),
            const Expanded(child: _Frame10(storeKey: 'reason3')),
          ]),
          const SizedBox(height: 20),
          CardHeading('📋 تَأَمَّلْ: مَاذَا تَعَلَّمْتَ الْيَوْمَ عَنْ مَوْلِدِ النَّبِيِّ وَحَيَاتِهِ الْأُولَى؟'),
          const SizedBox(height: 12),
          const _Frame10(storeKey: 'reflect1', label: 'سُؤَالٌ عِنْدِي'),
          const SizedBox(height: 10),
          const _Frame10(storeKey: 'reflect2', label: 'شَيْءٌ تَعَلَّمْتُهُ'),
        ],
      ),
    );
  }
}

class ExitTicketCard10 extends StatelessWidget {
  const ExitTicketCard10({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeading('✍️ بِطَاقَةُ الخُرُوجِ'),
          CardInstruction('أَجِبْ عَنِ السُّؤَالَيْنِ التَّالِيَيْنِ قَبْلَ أَنْ تَخْرُجَ:'),
          SizedBox(height: 14),
          _Frame10(storeKey: 'exit1', label: 'السُّؤَالُ الأَوَّلُ: اُحْكِ ثَلَاثَةَ أَحْدَاثٍ مِنْ حَيَاةِ النَّبِيِّ الْأُولَى بِاسْتِخْدَامِ الْفِعْلِ الْمَاضِي'),
          SizedBox(height: 14),
          _Frame10(storeKey: 'exit2', label: 'السُّؤَالُ الثَّانِي: اُذْكُرْ كَلِمَةَ ظَرْفٍ وَاحِدَةً تَعَلَّمْتَهَا فِي هَذَا الدَّرْسِ'),
        ],
      ),
    );
  }
}

class SelfAssessCard10 extends StatelessWidget {
  const SelfAssessCard10({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final checks = context.watch<AppState>().dars1110SelfChecks();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('📋 التَّقْيِيمُ الذَّاتِيُّ'),
          const CardInstruction('التَّقْيِيمُ الذَّاتِيُّ: اِسْتَطَعْتُ وَالْحَمْدُ لِلَّهِ أَنْ:'),
          const SizedBox(height: 12),
          for (var i = 0; i < Dars1110.selfAssessItems.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: c.surface2,
                borderRadius: BorderRadius.circular(9),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () => context.read<AppState>().dars1110SetSelfCheck(i, !(checks[i.toString()] ?? false)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(border: Border.all(color: c.border), borderRadius: BorderRadius.circular(9)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: checks[i.toString()] ?? false,
                          onChanged: (v) => context.read<AppState>().dars1110SetSelfCheck(i, v ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(Dars1110.selfAssessItems[i],
                                style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, height: 1.5, color: c.text)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DictionaryCard10 extends StatefulWidget {
  const DictionaryCard10({super.key});

  @override
  State<DictionaryCard10> createState() => _DictionaryCard10State();
}

class _DictionaryCard10State extends State<DictionaryCard10> {
  late List<TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _ctrls = List.generate(20, (i) => TextEditingController(text: app.dars1110Get('dict${i + 1}', '')));
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _row(int n) {
    final c = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 22, child: Text('$n.', style: const TextStyle(fontSize: 12))),
          Expanded(
            child: TextField(
              controller: _ctrls[n - 1],
              style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, color: c.colorScheme.onSurface),
              decoration: const InputDecoration(
                isDense: true,
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
              onChanged: (v) => context.read<AppState>().dars1110Set('dict$n', v),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('📖 قَامُوسِي الصَّغِيرُ'),
          const CardInstruction('كَلِمَاتٌ جَدِيدَةٌ تَعَلَّمْتُهَا الْيَوْمَ:'),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [for (var i = 1; i <= 10; i++) _row(i)])),
              const SizedBox(width: 16),
              Expanded(child: Column(children: [for (var i = 11; i <= 20; i++) _row(i)])),
            ],
          ),
        ],
      ),
    );
  }
}
