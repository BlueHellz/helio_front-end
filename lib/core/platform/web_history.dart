import 'package:flutter/foundation.dart';

import 'web_history_stub.dart'
    if (dart.library.html) 'web_history_web.dart' as impl;

/// Updates the browser URL on web; no-op on other platforms.
void pushAppPath(String path) {
  if (kIsWeb) impl.pushWebPath(path);
}

/// Current pathname on web; `'/'` elsewhere.
String readAppPath() {
  if (kIsWeb) return impl.readWebPath();
  return '/';
}
