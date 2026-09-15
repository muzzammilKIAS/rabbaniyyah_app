import 'dart:html' as html;

/// True browser fullscreen (hides the address bar/tabs) — this is what
/// makes the app usable as a "projector mode": once toggled, only the
/// lesson content is visible on the classroom screen, no browser chrome.
bool get isFullscreenSupported => true;

bool get isFullscreen => html.document.fullscreenElement != null;

Future<void> enterFullscreen() async {
  await html.document.documentElement?.requestFullscreen();
}

Future<void> exitFullscreen() async {
  if (html.document.fullscreenElement != null) {
    html.document.exitFullscreen();
  }
}

/// Fires on every entry/exit, including the student pressing Esc — so a
/// toggle button relying on this stays in sync without polling.
Stream<bool> get fullscreenChanges =>
    html.document.onFullscreenChange.map((_) => html.document.fullscreenElement != null);
