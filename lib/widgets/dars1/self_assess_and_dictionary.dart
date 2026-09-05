import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

import 'celebration_dialog.dart';
import '../../utils/arabic_text.dart';

class SelfAssessCard extends StatelessWidget {
  const SelfAssessCard({super.key});

  void _toggle(BuildContext context, int i, bool val, Map<String, bool> checks) {
    final app = context.read<AppState>();
    app.dars111SetSelfCheck(i, val);
    final copy = Map<String, bool>.from(checks);
    copy[i.toString()] = val;
    final checkedCount = copy.values.where((v) => v).length;
    if (checkedCount == Dars111.selfAssessItems.length && val) {
      CelebrationDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final checks = context.watch<AppState>().dars111SelfChecks();
    final checkedCount = checks.values.where((v) => v).length;
    final allDone = checkedCount == Dars111.selfAssessItems.length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: CardHeading('📋 التَّقْيِيمُ الذَّاتِيُّ لِأَهْدَافِ الدَّرْسِ')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: allDone ? c.successSoft : c.accentSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$checkedCount / ${Dars111.selfAssessItems.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: allDone ? c.success : c.accent,
                  ),
                ),
              ),
            ],
          ),
          const CardInstruction('قَائِمَةُ التَّقْيِيمِ الذَّاتِيِّ: اِسْتَطَعْتُ وَالْحَمْدُ لِلَّهِ أَنْ:'),
          const SizedBox(height: 14),
          for (var i = 0; i < Dars111.selfAssessItems.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: (checks[i.toString()] ?? false) ? c.accentSoft.withValues(alpha: 0.5) : c.surface2,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _toggle(context, i, !(checks[i.toString()] ?? false), checks),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: (checks[i.toString()] ?? false) ? c.accent.withValues(alpha: 0.5) : c.border,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: checks[i.toString()] ?? false,
                          onChanged: (v) => _toggle(context, i, v ?? false, checks),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              stripTashkeel(Dars111.selfAssessItems[i]),
                              style: TextStyle(
                                fontFamily: AppTheme.instructionFont,
                                fontSize: 16.5,
                                height: 1.6,
                                color: (checks[i.toString()] ?? false) ? c.accent : c.text,
                                fontWeight: (checks[i.toString()] ?? false) ? FontWeight.w700 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (allDone) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.accent, c.accentStrong],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: c.accent.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تهانينا! لقد حققت كل أهداف الدرس',
                          style: TextStyle(
                            fontFamily: AppTheme.uiFont,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'بارك الله في علمك وسعيك في تعلم لغة القرآن.',
                          style: TextStyle(fontSize: 12.5, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => CelebrationDialog.show(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: c.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('عرض الوسام 🏆', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DictionaryCard extends StatefulWidget {
  const DictionaryCard({super.key});

  @override
  State<DictionaryCard> createState() => _DictionaryCardState();
}

class _DictionaryCardState extends State<DictionaryCard> {
  late List<TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _ctrls = List.generate(20, (i) => TextEditingController(text: app.dars111Get('dict${i + 1}', '')));
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
              onChanged: (v) => context.read<AppState>().dars111Set('dict$n', v),
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
          const CardHeading('📖 كَلِمَاتٌ جَدِيدَةٌ تَعَلَّمْتُهَا الْيَوْمَ'),
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
