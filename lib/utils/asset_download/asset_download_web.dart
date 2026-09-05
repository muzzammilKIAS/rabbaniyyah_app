import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;

/// Downloads a bundled asset through the browser's normal save flow — reads
/// the asset bytes already shipped with the app (no network fetch) and
/// triggers an `<a download>` click, same as saving any other web image.
Future<void> downloadAssetImage(String assetPath, String downloadName) async {
  final data = await rootBundle.load(assetPath);
  final blob = html.Blob([data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', downloadName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
