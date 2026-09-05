import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';
import 'dalil_gallery.dart';

class _Frame extends StatefulWidget {
  const _Frame({required this.storeKey, this.hint, this.label});
  final String storeKey;
  final String? hint;
  final String? label;

  @override
  State<_Frame> createState() => _FrameState();
}

class _FrameState extends State<_Frame> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: context.read<AppState>().dars111Get(widget.storeKey, ''));
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
          Text(
            widget.label!,
            style: TextStyle(
              fontFamily: AppTheme.instructionFont,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: c.textMuted,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: _ctrl,
          maxLines: 3,
          minLines: 2,
          style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 17, height: 1.6),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 15),
          ),
          onChanged: (v) => context.read<AppState>().dars111Set(widget.storeKey, v),
        ),
      ],
    );
  }
}

class AnalyzeApplyCard extends StatelessWidget {
  const AnalyzeApplyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeading('👥 الدَّلِيلُ أَمَامَ عَيْنَيْكَ! فَكِّرْ مَعَ زَمِيلِكَ'),
          CardInstruction('اُنْظُرْ إِلَى هَذِهِ الصُّوَرِ. فَكِّرْ: مَاذَا يَدُلُّ عَلَيْهِ مَا تَرَاهُ مِنْ صِفَاتِ اللهِ؟ اُكْتُبْ جُمْلَةً بِاسْتِخْدَامِ الإِطَارِ أَدْنَاهُ 👇'),
          SizedBox(height: 14),
          DalilGallery(),
          SizedBox(height: 18),
          _Frame(
            storeKey: 'frame1',
            label: 'إطار الكتابة ✍️',
            hint: 'هذا / هذه ____ دليل على أن الله ____ لأنه / لأنها ____',
          ),
        ],
      ),
    );
  }
}

class ReflectionCard extends StatelessWidget {
  const ReflectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeading('💭 سُؤَالُ التَّفْكِيرِ'),
          CardInstruction('كَيْفَ يُغَيِّرُ الإِيمَانُ بِاللهِ حَيَاتَكَ اليَوْمِيَّةَ؟ اُذْكُرْ مِثَالاً مِنْ حَيَاتِكَ.'),
          SizedBox(height: 14),
          _Frame(storeKey: 'frame2', label: 'إطار الجواب', hint: 'عندما أؤمن بالله ____ وأنا، ____'),
          SizedBox(height: 18),
          CardHeading('🌟 تَأَمَّلْ: مَاذَا تَعَلَّمْتَ الْيَوْمَ عَنِ اللهِ؟'),
          SizedBox(height: 12),
          _Frame(storeKey: 'reflect1', label: 'سؤال عندي'),
          SizedBox(height: 10),
          _Frame(storeKey: 'reflect2', label: 'شيء تعلمته'),
        ],
      ),
    );
  }
}

class ExitTicketCard extends StatelessWidget {
  const ExitTicketCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeading('✍️ أَجِبْ عَنِ السُّؤَالَيْنِ التَّالِيَيْنِ قَبْلَ أَنْ تَخْرُجَ'),
          SizedBox(height: 14),
          _Frame(storeKey: 'exit1', label: 'السؤال الأول: اكتب ثلاثة أسماء من أسماء الله الحسنى مع معانيها'),
          SizedBox(height: 14),
          _Frame(storeKey: 'exit2', label: 'السؤال الثاني: اكتب جملة واحدة باستخدام القاعدة (اسم + خبر)'),
        ],
      ),
    );
  }
}
