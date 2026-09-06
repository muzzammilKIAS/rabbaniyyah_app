import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

class VocabCard6 extends StatefulWidget {
  const VocabCard6({super.key});

  @override
  State<VocabCard6> createState() => _VocabCard6State();
}

class _VocabCard6State extends State<VocabCard6> {
  late List<TextEditingController> _controllers;
  int? _speaking;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _controllers = List.generate(
      Dars116.vocab.length,
      (i) => TextEditingController(text: app.dars116Get('vocab$i', '')),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tts = context.read<AppState>().tts;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: CardHeading('📖 جَدْوَلُ الكَلِمَاتِ')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(999)),
                child: Text('٨ مفردات', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: c.accent)),
              ),
            ],
          ),
          const CardInstruction('اقرأ كل كلمة ومعناها، ثم جرب كتابة مثلها أو جملة في العمود الثالث:'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('الكَلِمَةُ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
                Expanded(flex: 3, child: Text('المَعْنَى', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
                Expanded(flex: 3, child: Text('كِتَابَتُكَ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3), 2: FlexColumnWidth(3)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (var i = 0; i < Dars116.vocab.length; i++)
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.6)))),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SpeakButton(
                            size: 26,
                            speaking: _speaking == i,
                            onTap: () async {
                              if (_speaking == i) {
                                await tts.stop();
                                if (mounted) setState(() => _speaking = null);
                                return;
                              }
                              if (!tts.ready) return;
                              setState(() => _speaking = i);
                              await tts.speak(Dars116.vocab[i].word);
                              if (mounted && _speaking == i) setState(() => _speaking = null);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              Dars116.vocab[i].word,
                              style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 17.5, fontWeight: FontWeight.w700, color: c.accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      child: Text(Dars116.vocab[i].meaning, style: TextStyle(fontSize: 13, color: c.textMuted, fontWeight: FontWeight.w500)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                      child: TextField(
                        controller: _controllers[i],
                        style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'اكتب هنا…',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (v) => context.read<AppState>().dars116Set('vocab$i', v),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
