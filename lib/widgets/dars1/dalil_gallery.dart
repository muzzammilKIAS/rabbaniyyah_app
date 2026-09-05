import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/arabic_text.dart';
import '../../utils/asset_download.dart';

/// Flutter's default [ScrollBehavior] only drags via touch/stylus — a
/// desktop/web visitor's mouse can't swipe the gallery without this.
class _DragAnywhereScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

/// The 4 evidence/creation photos for "الدليل أمام عينيك" — swipeable,
/// each individually downloadable through the browser's normal save flow.
class DalilGallery extends StatefulWidget {
  const DalilGallery({super.key});

  @override
  State<DalilGallery> createState() => _DalilGalleryState();
}

class _DalilGalleryState extends State<DalilGallery> {
  static const _images = [
    'assets/images/dalil/dalil_1.jpg',
    'assets/images/dalil/dalil_2.jpg',
    'assets/images/dalil/dalil_3.jpg',
    'assets/images/dalil/dalil_4.jpg',
  ];

  final _controller = PageController();
  int _page = 0;
  int? _downloadingIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _download(int i) async {
    setState(() => _downloadingIndex = i);
    await downloadAssetImage(_images[i], 'دليل_${i + 1}.jpg');
    if (mounted) setState(() => _downloadingIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final downloading = _downloadingIndex == _page;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ScrollConfiguration(
                  behavior: _DragAnywhereScrollBehavior(),
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _images.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) => Image.asset(_images[i], fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${toArabicNumerals(_page + 1)} / ${toArabicNumerals(_images.length)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: InkWell(
                    onTap: downloading ? null : () => _download(_page),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
                      child: downloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? c.accent : c.border,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
