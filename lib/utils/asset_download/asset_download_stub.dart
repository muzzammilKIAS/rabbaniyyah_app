/// Non-web platforms have no browser download flow to trigger — saving a
/// bundled asset to the device would need a file-picker/permission dance
/// that isn't built here yet, so this just no-ops rather than crash.
Future<void> downloadAssetImage(String assetPath, String downloadName) async {}
