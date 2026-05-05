// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void pushWebPath(String path) {
  if (path.isEmpty) return;
  final normalized = path.startsWith('/') ? path : '/$path';
  html.window.history.pushState(null, '', normalized);
}

String readWebPath() => html.window.location.pathname ?? '/';
