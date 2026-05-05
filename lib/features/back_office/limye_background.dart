import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_gl/flutter_gl.dart';

import 'limye_gl_renderer.dart';

/// Full-screen non-interactive OpenGL backdrop (Limyè). Place as the first child of a [Stack].
///
/// Uses [Texture] + offscreen FBO via [flutter_gl]. On Web or unsupported platforms,
/// falls back to a solid `#13161a` fill (flutter_gl is not fully available everywhere).
class LimyeBackground extends StatefulWidget {
  const LimyeBackground({super.key});

  @override
  State<LimyeBackground> createState() => _LimyeBackgroundState();
}

class _LimyeBackgroundState extends State<LimyeBackground>
    with SingleTickerProviderStateMixin {
  FlutterGlPlugin? _plugin;
  LimyeGlRenderer? _renderer;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _time = 0;
  bool _initStarted = false;
  bool _glReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_last == Duration.zero) {
      _last = elapsed;
      return;
    }
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _time += dt;
    if (_renderer != null && _renderer!.ready) {
      _renderer!.render(time: _time, dt: dt);
    }
  }

  Future<void> _bootstrap(Size size, double dpr) async {
    if (_initStarted) return;
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }
    _initStarted = true;

    if (kIsWeb) {
      setState(() {
        _error = 'Web: use flutter_gl HtmlElementView separately; showing fallback.';
      });
      return;
    }

    try {
      final plugin = FlutterGlPlugin();
      await plugin.initialize(
        options: {
          'width': size.width.toInt(),
          'height': size.height.toInt(),
          'dpr': dpr,
          'antialias': true,
          'alpha': false,
        },
      );

      final renderer = LimyeGlRenderer(plugin);
      await renderer.init(width: size.width, height: size.height, dpr: dpr);

      if (!mounted) return;
      setState(() {
        _plugin = plugin;
        _renderer = renderer;
        _glReady = renderer.ready;
      });
    } catch (e, st) {
      debugPrint('LimyeBackground GL init failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _renderer?.dispose();
    try {
      if (_plugin?.textureId != null) {
        _plugin!.dispose();
      }
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context).clamp(0.5, 4.0);
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (!_initStarted &&
              size.width.isFinite &&
              size.height.isFinite &&
              size.width > 0 &&
              size.height > 0) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) _bootstrap(size, dpr);
            });
          }
          if (_glReady && _plugin?.textureId != null) {
            return SizedBox.expand(
              child: Texture(
                textureId: _plugin!.textureId!,
              ),
            );
          }
          return ColoredBox(
            color: const Color(0xFF13161A),
            child: _error != null && kDebugMode
                ? Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}
