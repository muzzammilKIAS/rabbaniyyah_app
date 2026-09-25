import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/exercise_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_text.dart';
import '../shared/match_pairs_activity.dart';
import 'exercise_frame.dart';

final _arabicRe = RegExp(r'[؀-ۿ]');
bool _isArabic(String s) => _arabicRe.hasMatch(s);

/// Stable shuffle of 0..n-1 (same order on every rebuild/visit, never the
/// answer order itself when n > 1).
List<int> seededShuffle(int n, String seed) {
  final s = seed.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0x7fffffff);
  final list = List<int>.generate(n, (i) => i)..shuffle(math.Random(s));
  var identity = true;
  for (var i = 0; i < n; i++) {
    if (list[i] != i) identity = false;
  }
  if (identity && n > 1) list.add(list.removeAt(0));
  return list;
}

/// A tappable, optionally draggable item chip.
class _ItemChip extends StatelessWidget {
  const _ItemChip({required this.text, this.selected = false, this.status, this.onTap, this.expand = false});
  final String text;
  final bool selected;
  final bool? status;
  final VoidCallback? onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    var border = c.border;
    var bg = c.surface;
    if (selected) {
      border = c.accent2;
      bg = c.accent2Soft;
    } else if (status == true) {
      border = c.success;
      bg = c.successSoft;
    } else if (status == false) {
      border = c.danger;
      bg = c.dangerSoft;
    }
    final arabic = _isArabic(text);
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: text,
      child: AnimatedContainer(
        duration: motion(context, 160),
        width: expand ? double.infinity : null,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: selected ? 1.8 : 1),
          boxShadow: selected ? [BoxShadow(color: c.accent2.withValues(alpha: 0.2), blurRadius: 8)] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 46),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    if (status != null) ...[
                      Icon(
                        status! ? Icons.check_rounded : Icons.close_rounded,
                        size: 16,
                        color: status! ? c.success : c.danger,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: ExText(text, arabic: arabic, size: arabic ? 18.5 : 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Drag an item into a category — or, touch/keyboard friendly, tap the item
/// then tap the category.
class CategorizeExerciseView extends StatefulWidget {
  const CategorizeExerciseView({super.key, required this.lesson, required this.spec});
  final int lesson;
  final CategorizeExercise spec;

  @override
  State<CategorizeExerciseView> createState() => _CategorizeExerciseViewState();
}

class _CategorizeExerciseViewState extends State<CategorizeExerciseView> {
  late final List<int> _order = seededShuffle(widget.spec.items.length, '${widget.lesson}${widget.spec.id}');
  final Map<int, int> _placed = {};
  int? _selected;
  Map<int, bool>? _checked;

  bool get _solved =>
      _checked != null && _checked!.length == widget.spec.items.length && _checked!.values.every((v) => v);

  void _place(int item, int cat) => setState(() {
    _placed[item] = cat;
    _selected = null;
    _checked = null;
  });

  void _check() {
    final checked = {for (final e in _placed.entries) e.key: widget.spec.items[e.key].category == e.value};
    setState(() => _checked = checked);
    context.read<AppState>().recordExercise(
      widget.lesson,
      widget.spec.id,
      score: checked.values.where((v) => v).length,
      total: widget.spec.items.length,
    );
  }

  void _retryWrong() => setState(() {
    _checked!.forEach((item, ok) {
      if (!ok) _placed.remove(item);
    });
    _checked = null;
  });

  void _resetAll() => setState(() {
    _placed.clear();
    _checked = null;
    _selected = null;
  });

  Widget _chipFor(int item, {required bool inPool}) {
    final chip = _ItemChip(
      text: widget.spec.items[item].text,
      selected: _selected == item,
      status: inPool ? null : _checked?[item],
      onTap: _solved
          ? null
          : inPool
          ? () => setState(() => _selected = _selected == item ? null : item)
          : () => setState(() {
              _placed.remove(item);
              _checked = null;
            }),
    );
    if (_solved) return chip;
    return LongPressDraggable<int>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.9, child: chip),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: chip),
      child: chip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final spec = widget.spec;
    final pool = _order.where((i) => !_placed.containsKey(i)).toList();
    final wrong = _checked?.values.where((v) => !v).length ?? 0;

    Widget box(int cat) {
      final items = _order.where((i) => _placed[i] == cat).toList();
      final label = spec.categories[cat];
      return DragTarget<int>(
        onAcceptWithDetails: (d) => _place(d.data, cat),
        builder: (context, candidate, _) {
          final hot = candidate.isNotEmpty || _selected != null;
          return Semantics(
            button: _selected != null,
            label: 'Kategori $label',
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _selected == null ? null : () => _place(_selected!, cat),
              child: AnimatedContainer(
                duration: motion(context, 160),
                constraints: const BoxConstraints(minHeight: 110),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: candidate.isNotEmpty ? c.accentSoft : c.surface2.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: hot ? c.accent : c.border, width: hot ? 1.6 : 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.inbox_outlined, size: 16, color: c.accent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ExText(
                            label,
                            arabic: _isArabic(label),
                            size: _isArabic(label) ? 18 : 14,
                            weight: FontWeight.w700,
                            color: c.accent,
                          ),
                        ),
                        Text(toArabicNumerals(items.length), style: TextStyle(color: c.textMuted, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [for (final i in items) _chipFor(i, inPool: false)]),
                    if (items.isEmpty && _selected != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Ketik di sini untuk meletakkan',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12, color: c.accent),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pool.isNotEmpty) ...[
          Text(
            _selected == null
                ? 'Ketik satu item, kemudian ketik kategorinya (atau tekan lama dan seret).'
                : 'Sekarang ketik kategori yang sesuai.',
            textDirection: TextDirection.ltr,
            style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12.5, color: c.textMuted),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final i in pool) _chipFor(i, inPool: true)]),
          const SizedBox(height: 14),
        ],
        LayoutBuilder(
          builder: (context, box0) {
            final n = spec.categories.length;
            final row = box0.maxWidth >= 520 && n <= 3;
            if (row) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var k = 0; k < n; k++) ...[if (k > 0) const SizedBox(width: 10), Expanded(child: box(k))],
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (var k = 0; k < n; k++)
                  Padding(
                    padding: EdgeInsets.only(top: k == 0 ? 0 : 10),
                    child: box(k),
                  ),
              ],
            );
          },
        ),
        if (_checked != null)
          ExerciseFeedback(
            correct: _solved,
            detail: _solved
                ? 'Semua ${spec.items.length} item di tempat yang betul.'
                : '$wrong item belum di tempat yang betul.',
          ),
        ExerciseActions(
          checkLabel: _solved ? '' : 'Semak jawapan',
          onCheck: (!_solved && pool.isEmpty && _checked == null) ? _check : null,
          onReset: _solved ? _resetAll : (_checked != null ? _retryWrong : null),
          resetLabel: _solved ? 'Ulang semula' : 'Alih yang salah',
        ),
      ],
    );
  }
}

/// Build the correct order by tapping items one by one.
class SequenceExerciseView extends StatefulWidget {
  const SequenceExerciseView({super.key, required this.lesson, required this.spec});
  final int lesson;
  final SequenceExercise spec;

  @override
  State<SequenceExerciseView> createState() => _SequenceExerciseViewState();
}

class _SequenceExerciseViewState extends State<SequenceExerciseView> {
  late final List<int> _shuffled = seededShuffle(widget.spec.correctOrder.length, '${widget.lesson}${widget.spec.id}');
  final List<int> _answer = [];
  List<bool>? _checked;

  int get _n => widget.spec.correctOrder.length;
  bool get _solved => _checked != null && _checked!.every((v) => v);

  void _check() {
    final checked = [for (var p = 0; p < _answer.length; p++) _answer[p] == p];
    setState(() => _checked = checked);
    context.read<AppState>().recordExercise(
      widget.lesson,
      widget.spec.id,
      score: checked.where((v) => v).length,
      total: _n,
    );
  }

  /// Keeps the correct opening run, returns the rest to the pool.
  void _retry() => setState(() {
    var keep = 0;
    while (keep < _answer.length && _checked![keep]) {
      keep++;
    }
    _answer.removeRange(keep, _answer.length);
    _checked = null;
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pool = _shuffled.where((i) => !_answer.contains(i)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var p = 0; p < _n; p++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p < _answer.length ? c.accent : c.surface2,
                    border: Border.all(color: p < _answer.length ? c.accent : c.border),
                  ),
                  child: Text(
                    toArabicNumerals(p + 1),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: p < _answer.length ? Colors.white : c.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: p < _answer.length
                      ? _ItemChip(
                          text: widget.spec.correctOrder[_answer[p]],
                          expand: true,
                          status: _checked?[p],
                          onTap: _solved
                              ? null
                              : () => setState(() {
                                  _answer.removeAt(p);
                                  _checked = null;
                                }),
                        )
                      : Container(
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: c.border.withValues(alpha: 0.8)),
                            color: c.surface2.withValues(alpha: 0.35),
                          ),
                        ),
                ),
              ],
            ),
          ),
        if (pool.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Ketik item mengikut urutan. Ketik item yang sudah disusun untuk mengalihnya.',
            textDirection: TextDirection.ltr,
            style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12.5, color: c.textMuted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in pool)
                _ItemChip(
                  text: widget.spec.correctOrder[i],
                  onTap: () => setState(() {
                    _answer.add(i);
                    _checked = null;
                  }),
                ),
            ],
          ),
        ],
        if (_checked != null)
          ExerciseFeedback(
            correct: _solved,
            detail: _solved ? 'Urutan tepat.' : 'Betul di kedudukan: ${_checked!.where((v) => v).length} / $_n',
          ),
        ExerciseActions(
          checkLabel: _solved ? '' : 'Semak urutan',
          onCheck: (!_solved && _answer.length == _n && _checked == null) ? _check : null,
          onReset: _solved
              ? () => setState(() {
                  _answer.clear();
                  _checked = null;
                })
              : (_checked != null ? _retry : null),
          resetLabel: _solved ? 'Ulang semula' : 'Cuba lagi',
        ),
      ],
    );
  }
}

/// Vocabulary flip cards (active recall). Done once every card was turned.
class FlashcardExerciseView extends StatefulWidget {
  const FlashcardExerciseView({super.key, required this.lesson, required this.spec});
  final int lesson;
  final FlashcardExercise spec;

  @override
  State<FlashcardExerciseView> createState() => _FlashcardExerciseViewState();
}

class _FlashcardExerciseViewState extends State<FlashcardExerciseView> {
  int _index = 0;
  bool _back = false;
  final Set<int> _seen = {};

  void _flip() {
    setState(() {
      _back = !_back;
      if (_back) _seen.add(_index);
    });
    final n = widget.spec.cards.length;
    final app = context.read<AppState>();
    if (_seen.length == n && app.exerciseResult(widget.lesson, widget.spec.id) == null) {
      app.recordExercise(widget.lesson, widget.spec.id, score: n, total: n);
    }
  }

  void _go(int delta) => setState(() {
    final n = widget.spec.cards.length;
    _index = (_index + delta + n) % n;
    _back = false;
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cards = widget.spec.cards;
    final card = cards[_index];
    final reduce = reduceMotionOf(context);

    final face = Container(
      key: ValueKey('$_index-$_back'),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 170),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _back
            ? null
            : LinearGradient(colors: [c.accentSoft, c.surface2], begin: Alignment.topRight, end: Alignment.bottomLeft),
        color: _back ? c.goldSoft : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _back ? c.goldBorder : c.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_back) ...[
            ExText(card.meaning, arabic: false, size: 20, weight: FontWeight.w700, align: TextAlign.center),
            const SizedBox(height: 8),
            ExText(card.word, arabic: true, size: 18, color: c.textMuted, align: TextAlign.center),
          ] else ...[
            ExText(
              card.word,
              arabic: true,
              size: 32,
              weight: FontWeight.w700,
              color: c.accent,
              align: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ketik untuk melihat maksud',
              textDirection: TextDirection.ltr,
              style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12, color: c.textMuted),
            ),
          ],
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: _back ? 'Maksud: ${card.meaning}' : 'Kad ${card.word}. Ketik untuk melihat maksud.',
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _flip,
            child: AnimatedSwitcher(
              duration: reduce ? Duration.zero : const Duration(milliseconds: 320),
              transitionBuilder: (child, anim) {
                final rotate = Tween(begin: math.pi / 2, end: 0.0).animate(anim);
                return AnimatedBuilder(
                  animation: rotate,
                  child: child,
                  builder: (context, child) => Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(rotate.value),
                    child: child,
                  ),
                );
              },
              layoutBuilder: (current, previous) => Stack(alignment: Alignment.center, children: [?current]),
              child: face,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              IconButton.outlined(
                tooltip: 'Kad sebelumnya',
                onPressed: () => _go(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Kad ${_index + 1} / ${cards.length}',
                      style: TextStyle(fontFamily: AppTheme.uiFont, fontWeight: FontWeight.w700, color: c.text),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: _seen.length / cards.length,
                        minHeight: 5,
                        backgroundColor: c.border,
                        valueColor: AlwaysStoppedAnimation(c.gold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Diulang kaji: ${_seen.length} / ${cards.length}',
                      style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12, color: c.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                tooltip: 'Kad seterusnya',
                onPressed: () => _go(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
        if (_seen.length == cards.length)
          const ExerciseFeedback(correct: true, detail: 'Semua kad telah diulang kaji.'),
      ],
    );
  }
}

/// Arabic ↔ meaning matching, reusing the app's existing two-column
/// [MatchPairsActivity] with a check step on top.
class PairMatchExerciseView extends StatefulWidget {
  const PairMatchExerciseView({super.key, required this.lesson, required this.spec});
  final int lesson;
  final PairMatchExercise spec;

  @override
  State<PairMatchExerciseView> createState() => _PairMatchExerciseViewState();
}

class _PairMatchExerciseViewState extends State<PairMatchExerciseView> {
  // A fresh key per round, so "Ulang semula" starts a clean activity.
  var _key = GlobalKey<MatchPairsActivityState>();
  late final List<int> _leftOrder = seededShuffle(widget.spec.pairs.length, '${widget.lesson}${widget.spec.id}');
  int _pairedCount = 0;
  int? _score;

  void _check() {
    final st = _key.currentState;
    if (st == null) return;
    st.check();
    final score = st.correctCount;
    setState(() => _score = score);
    context.read<AppState>().recordExercise(
      widget.lesson,
      widget.spec.id,
      score: score,
      total: widget.spec.pairs.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pairs = widget.spec.pairs;
    final solved = _score == pairs.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MatchPairsActivity(
          key: _key,
          rightItems: [for (final p in pairs) p.$1],
          leftItems: [for (final i in _leftOrder) pairs[i].$2],
          correctIndexForRight: [for (var r = 0; r < pairs.length; r++) _leftOrder.indexOf(r)],
          onChanged: (m) => setState(() {
            _pairedCount = m.length;
            _score = null;
          }),
        ),
        if (_score != null)
          ExerciseFeedback(
            correct: solved,
            detail: solved
                ? 'Semua padanan betul.'
                : 'Betul: $_score / ${pairs.length}. Ketik padanan merah untuk membukanya.',
          ),
        ExerciseActions(
          checkLabel: solved ? '' : 'Semak padanan',
          onCheck: (!solved && _pairedCount == pairs.length && _score == null) ? _check : null,
          onReset: solved
              ? () => setState(() {
                  _key = GlobalKey<MatchPairsActivityState>();
                  _pairedCount = 0;
                  _score = null;
                })
              : null,
        ),
      ],
    );
  }
}
