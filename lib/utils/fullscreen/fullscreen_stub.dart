/// No-op on non-web platforms — there is no browser chrome to hide, so the
/// toggle button that uses this simply stays unavailable there.
bool get isFullscreenSupported => false;

bool get isFullscreen => false;

Future<void> enterFullscreen() async {}

Future<void> exitFullscreen() async {}

Stream<bool> get fullscreenChanges => const Stream.empty();
