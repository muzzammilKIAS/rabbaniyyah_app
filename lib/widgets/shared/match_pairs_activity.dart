import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Generic two-column matching exercise: tap an item on the right, then its
/// pair on the left; re-tap a paired item to undo. Persistence and scoring
/// stay with the caller (via [initialPairs]/[onChanged]) so this widget has
/// no lesson-specific storage of its own — reused across lessons 2 and 3.
class MatchPairsActivity extends StatefulWidget {
  const MatchPairsActivity({
    super.key,
    required this.leftItems,
    required this.rightItems,
    required this.correctIndexForRight,
    this.leftHeader,
    this.rightHeader,
    this.initialPairs = const {},
    this.onChanged,
  });

  /// Right column: the "prompts" the student picks first (e.g. names).
  final List<String> rightItems;

  /// Left column: the "answers" the student matches to a prompt.
  final List<String> leftItems;

  /// For each index in [rightItems], the correct index into [leftItems].
  final List<int> correctIndexForRight;

  final String? leftHeader;
  final String? rightHeader;

  /// rightIndex -> leftIndex, restored on build.
  final Map<int, int> initialPairs;

  /// Called whenever the pairing changes, so the caller can persist it.
  final ValueChanged<Map<int, int>>? onChanged;

  @override
  State<MatchPairsActivity> createState() => MatchPairsActivityState();
}

class MatchPairsActivityState extends State<MatchPairsActivity> {
  int? _selectedRight;
  late Map<int, int> _pairs;
  Map<int, bool>? results;

  @override
  void initState() {
    super.initState();
    _pairs = Map.of(widget.initialPairs);
  }

  int get correctCount => results?.values.where((v) => v).length ?? 0;

  void check() {
    setState(() {
      results = {
        for (final e in _pairs.entries) e.key: e.value == widget.correctIndexForRight[e.key],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final usedLeft = _pairs.values.toSet();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.rightHeader != null) ...[
                Text(widget.rightHeader!, style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
              ],
              for (var i = 0; i < widget.rightItems.length; i++)
                _MatchChip(
                  label: '${i + 1}) ${widget.rightItems[i]}',
                  selected: _selectedRight == i,
                  done: _pairs.containsKey(i),
                  status: results?[i],
                  onTap: _pairs.containsKey(i)
                      ? () {
                          setState(() {
                            _pairs.remove(i);
                            results = null;
                          });
                          widget.onChanged?.call(_pairs);
                        }
                      : () => setState(() => _selectedRight = i),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.leftHeader != null) ...[
                Text(widget.leftHeader!, style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
              ],
              for (var i = 0; i < widget.leftItems.length; i++)
                _MatchChip(
                  label: widget.leftItems[i],
                  selected: false,
                  done: usedLeft.contains(i),
                  status: null,
                  onTap: (usedLeft.contains(i) || _selectedRight == null)
                      ? null
                      : () {
                          setState(() {
                            _pairs[_selectedRight!] = i;
                            _selectedRight = null;
                            results = null;
                          });
                          widget.onChanged?.call(_pairs);
                        },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchChip extends StatelessWidget {
  const _MatchChip({required this.label, required this.selected, required this.done, required this.status, required this.onTap});
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
