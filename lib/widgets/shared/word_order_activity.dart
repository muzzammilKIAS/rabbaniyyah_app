import 'package:flutter/material.dart';
import '../../data/curriculum.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_text.dart';

/// One "tap the word tiles in the right order" row, generalised from the
/// mechanic first built for Dars111 so lessons 2 and 3 can reuse it.
/// Persistence/scoring stay with the caller via [initialSelected]/[onChanged].
class WordOrderActivityRow extends StatefulWidget {
  const WordOrderActivityRow({
    super.key,
    required this.index,
    required this.item,
    this.initialSelected = const [],
    this.onChanged,
  });

  final int index;
  final WordOrderItem item;
  final List<String> initialSelected;
  final ValueChanged<List<String>>? onChanged;

  @override
  State<WordOrderActivityRow> createState() => WordOrderActivityRowState();
}

class WordOrderActivityRowState extends State<WordOrderActivityRow> {
  late List<String> _selected;
  bool? _result;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.initialSelected);
  }

  bool get isComplete => _selected.length == widget.item.tokens.length;

  void check() {
    final constructed = _selected.join(' ');
    final target = widget.item.answer.replaceAll('.', '').trim();
    setState(() => _result = stripTashkeel(constructed) == stripTashkeel(target));
  }

  void _update(List<String> next) {
    setState(() {
      _selected = next;
      _result = null;
    });
    widget.onChanged?.call(next);
    if (next.length == widget.item.tokens.length) check();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final available = List<String>.from(widget.item.tokens)..removeWhere(_selected.contains);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _result == true
            ? c.successSoft.withValues(alpha: 0.4)
            : (_result == false ? c.dangerSoft.withValues(alpha: 0.3) : c.surface2.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _result == true ? c.success : (_result == false ? c.danger : c.border), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(6)),
                child: Text('الجملة ${widget.index + 1}', style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              if (_selected.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _update([]),
                  icon: const Icon(Icons.clear_all_rounded, size: 14),
                  label: const Text('إعادة ضبط', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
            ],
          ),
          const SizedBox(height: 10),
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
                    child: Text('انقر الكلمات أدناه لوضعها هنا…',
                        style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 15, color: c.textMuted)),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (var idx = 0; idx < _selected.length; idx++)
                        InkWell(
                          onTap: () => _update(List<String>.from(_selected)..removeAt(idx)),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.accent)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_selected[idx], style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 17, fontWeight: FontWeight.bold, color: c.accent)),
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
                onTap: () => _update(List<String>.from(_selected)..add(t)),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.goldBorder, width: 1.4),
                    boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Text(t, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_result == true)
                Row(children: [
                  Icon(Icons.check_circle_rounded, color: c.success, size: 18),
                  const SizedBox(width: 6),
                  Text('صحيح! ممتاز', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.success)),
                ])
              else if (_result == false)
                Row(children: [
                  Icon(Icons.cancel_rounded, color: c.danger, size: 18),
                  const SizedBox(width: 6),
                  Text('حاول مرة أخرى', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.danger)),
                ]),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _revealed = !_revealed),
                child: Text(_revealed ? 'إخفاء الحل' : 'إظهار الحل النموذجي', style: TextStyle(fontSize: 12, color: c.gold, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (_revealed)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.goldBorder)),
              child: Text('الحل: ${widget.item.answer}',
                  style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, fontWeight: FontWeight.bold, color: c.accent)),
            ),
        ],
      ),
    );
  }
}
