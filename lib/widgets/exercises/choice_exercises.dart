import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/exercise_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'exercise_frame.dart';

enum _OptState { idle, wrong, correct, disabled }

/// One answer button: large touch target, colour + icon (never colour
/// alone) for right/wrong.
class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.arabic, required this.state, this.onTap});
  final String label;
  final bool arabic;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, border, icon, fg) = switch (state) {
      _OptState.correct => (c.successSoft, c.success, Icons.check_circle_rounded, c.success),
      _OptState.wrong => (c.dangerSoft, c.danger.withValues(alpha: 0.6), Icons.cancel_rounded, c.danger),
      _OptState.disabled => (c.surface2.withValues(alpha: 0.5), c.border.withValues(alpha: 0.6), null, c.textMuted),
      _OptState.idle => (c.surface2, c.border, null, c.text),
    };
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      hint: state == _OptState.correct ? 'Betul' : (state == _OptState.wrong ? 'Salah' : null),
      child: AnimatedContainer(
        duration: motion(context, 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: state == _OptState.correct ? 1.8 : 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 8)],
                    Flexible(
                      child: ExText(
                        label,
                        arabic: arabic,
                        size: arabic ? 19 : 14.5,
                        color: fg,
                        align: TextAlign.center,
                      ),
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

/// Multiple choice with immediate feedback: a wrong pick is marked and
/// disabled so the student can try again; the score is the number of
/// questions answered right on the first try.
class McqExerciseView extends StatefulWidget {
  const McqExerciseView({super.key, required this.lesson, required this.spec});
  final int lesson;
  final McqExercise spec;

  @override
  State<McqExerciseView> createState() => _McqExerciseViewState();
}

class _McqExerciseViewState extends State<McqExerciseView> {
  late List<Set<int>> _wrong;
  late List<bool> _solved;
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _wrong = [for (final _ in widget.spec.questions) <int>{}];
    _solved = [for (final _ in widget.spec.questions) false];
    _recorded = false;
  }

  int get _firstTry =>
      [for (var i = 0; i < _solved.length; i++) _solved[i] && _wrong[i].isEmpty].where((v) => v).length;

  void _pick(int q, int opt) {
    setState(() {
      if (opt == widget.spec.questions[q].answer) {
        _solved[q] = true;
      } else {
        _wrong[q].add(opt);
      }
    });
    if (_solved.every((s) => s) && !_recorded) {
      _recorded = true;
      context.read<AppState>().recordExercise(
        widget.lesson,
        widget.spec.id,
        score: _firstTry,
        total: widget.spec.questions.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final qs = widget.spec.questions;
    final allDone = _solved.every((s) => s);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var q = 0; q < qs.length; q++)
          Padding(
            padding: EdgeInsets.only(top: q == 0 ? 0 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        _solved[q] ? Icons.check_circle_rounded : Icons.help_outline_rounded,
                        size: 18,
                        color: _solved[q] ? c.success : c.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: qs[q].promptIsArabic ? AlignmentDirectional.centerStart : Alignment.centerLeft,
                        child: ExText(qs[q].prompt, arabic: qs[q].promptIsArabic, size: qs[q].promptIsArabic ? 21 : 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Directionality(
                  textDirection: widget.spec.optionsAreArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var o = 0; o < qs[q].options.length; o++)
                        _OptionTile(
                          label: qs[q].options[o],
                          arabic: widget.spec.optionsAreArabic,
                          state: _solved[q] && o == qs[q].answer
                              ? _OptState.correct
                              : _wrong[q].contains(o)
                              ? _OptState.wrong
                              : _solved[q]
                              ? _OptState.disabled
                              : _OptState.idle,
                          onTap: (_solved[q] || _wrong[q].contains(o)) ? null : () => _pick(q, o),
                        ),
                    ],
                  ),
                ),
                if (!_solved[q] && _wrong[q].isNotEmpty) const ExerciseFeedback(correct: false),
              ],
            ),
          ),
        if (allDone) ...[
          ExerciseFeedback(correct: true, detail: 'Betul pada cubaan pertama: $_firstTry / ${qs.length}'),
          ExerciseActions(checkLabel: '', onReset: () => setState(_reset)),
        ],
      ],
    );
  }
}

/// Betul/Salah statements with immediate feedback.
class TrueFalseExerciseView extends StatefulWidget {
  const TrueFalseExerciseView({super.key, required this.lesson, required this.spec});
  final int lesson;
  final TrueFalseExercise spec;

  @override
  State<TrueFalseExerciseView> createState() => _TrueFalseExerciseViewState();
}

class _TrueFalseExerciseViewState extends State<TrueFalseExerciseView> {
  late List<bool?> _answer; // what the student chose last
  late List<bool> _missed; // got it wrong at least once
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _answer = List.filled(widget.spec.items.length, null);
    _missed = List.filled(widget.spec.items.length, false);
    _recorded = false;
  }

  bool _solved(int i) => _answer[i] == widget.spec.items[i].isTrue;

  void _choose(int i, bool v) {
    setState(() {
      _answer[i] = v;
      if (v != widget.spec.items[i].isTrue) _missed[i] = true;
    });
    final all = [for (var k = 0; k < _answer.length; k++) _solved(k)].every((s) => s);
    if (all && !_recorded) {
      _recorded = true;
      context.read<AppState>().recordExercise(
        widget.lesson,
        widget.spec.id,
        score: _missed.where((m) => !m).length,
        total: widget.spec.items.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = widget.spec.items;
    final allDone = [for (var k = 0; k < items.length; k++) _solved(k)].every((s) => s);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++)
          Container(
            margin: EdgeInsets.only(top: i == 0 ? 0 : 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.surface2.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _solved(i) ? c.success.withValues(alpha: 0.6) : c.border),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    ExText(items[i].term,
                        arabic: true, size: 21, weight: items[i].claim.isEmpty ? FontWeight.w500 : FontWeight.w700),
                    if (items[i].claim.isNotEmpty) ...[
                      Text('=', style: TextStyle(color: c.textMuted, fontSize: 18)),
                      ExText(items[i].claim, arabic: widget.spec.claimIsArabic),
                    ],
                  ],
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final v in [true, false]) ...[
                        _OptionTile(
                          label: v ? 'Betul' : 'Salah',
                          arabic: false,
                          state: _answer[i] == v
                              ? (_solved(i) ? _OptState.correct : _OptState.wrong)
                              : (_solved(i) ? _OptState.disabled : _OptState.idle),
                          onTap: _solved(i) ? null : () => _choose(i, v),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (allDone) ...[
          ExerciseFeedback(
            correct: true,
            detail: 'Betul pada cubaan pertama: ${_missed.where((m) => !m).length} / ${items.length}',
          ),
          ExerciseActions(checkLabel: '', onReset: () => setState(_reset)),
        ] else if (_answer.asMap().entries.any((e) => e.value != null && !_solved(e.key)))
          const ExerciseFeedback(correct: false),
        const SizedBox.shrink(),
      ],
    );
  }
}

/// Tiny helper so other files can style Malay helper captions alike.
TextStyle exCaption(BuildContext context) =>
    TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12.5, color: context.colors.textMuted);
