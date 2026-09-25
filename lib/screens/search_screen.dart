import 'package:flutter/material.dart';
import '../data/lesson_catalog.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_text.dart';
import '../utils/lesson_router.dart';
import '../widgets/atmosphere.dart';
import '../widgets/lesson/lesson_status.dart';

/// One searchable piece of original lesson text.
class _Entry {
  _Entry(this.lesson, this.kind, this.text, [this.meaning]) : key = _norm('$text ${meaning ?? ''}');
  final LessonMeta lesson;
  final String kind;
  final String text;
  final String? meaning;
  final String key;
}

/// Tashkeel-insensitive, case-insensitive, and alif/ya/ta-marbuta
/// forgiving — a student typing "الرحمن" or "rahman" still finds it.
String _norm(String s) => stripTashkeel(
  s,
).toLowerCase().replaceAll(RegExp('[أإآٱ]'), 'ا').replaceAll('ى', 'ي').replaceAll('ة', 'ه').replaceAll('ـ', '');

final List<_Entry> _index = [
  for (final l in kLessons) ...[
    _Entry(l, 'Tajuk', l.title),
    _Entry(l, 'Unit', '${l.unitInfo.title}: ${l.unitInfo.topic}'),
    for (final v in l.vocab) _Entry(l, 'Kosa kata', v.word, v.meaning),
    for (final r in l.readingLines) _Entry(l, 'Teks bacaan', r),
  ],
];

/// Client-side search over lesson titles, units, vocabulary (Arabic and
/// Malay meaning) and reading-text lines. No backend.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final q = _norm(_q.trim());
    final results = q.length < 2 ? <_Entry>[] : _index.where((e) => e.key.contains(q)).take(60).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('البحث · Carian')),
        body: PageBackdrop(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: (v) => setState(() => _q = v),
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 18),
                        decoration: InputDecoration(
                          labelText: 'Cari tajuk, kosa kata atau ayat',
                          hintText: 'مثال: الرَّحْمَنُ · wuduk · الهجرة',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _q.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Kosongkan',
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () => setState(() {
                                    _controller.clear();
                                    _q = '';
                                  }),
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: q.length < 2
                          ? _Hint(
                              text: 'Taip sekurang-kurangnya 2 huruf. Carian tidak mengambil kira baris (tashkeel).',
                            )
                          : results.isEmpty
                          ? _Hint(text: 'Tiada padanan untuk “$_q”.')
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                              itemCount: results.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final e = results[i];
                                return Material(
                                  color: c.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => openLesson(context, e.lesson.n),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: c.border),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(unitIcon(e.lesson.unit), color: c.accent, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e.text,
                                                  style: TextStyle(
                                                    fontFamily: AppTheme.arabicFont,
                                                    fontSize: 18,
                                                    height: 1.6,
                                                    color: c.text,
                                                  ),
                                                ),
                                                if (e.meaning != null)
                                                  Text(
                                                    e.meaning!,
                                                    textDirection: TextDirection.ltr,
                                                    style: TextStyle(fontSize: 13, color: c.textMuted),
                                                  ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${e.lesson.ordinal} · ${stripTashkeel(e.lesson.title)} — ${e.kind}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: c.accent,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.arrow_back_rounded, size: 18, color: c.textMuted),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
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

class _Hint extends StatelessWidget {
  const _Hint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: AppTheme.uiFont, color: context.colors.textMuted),
        ),
      ),
    );
  }
}
