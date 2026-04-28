import 'package:flutter/material.dart';
import 'package:blacklight_app/core/content/content_registry.dart';

import '../../theme/blacklight_theme.dart';

// ─────────────────────────────────────────────
// BLACK LIGHT — official lockup (raster, theme-tinted)
// Source: assets/images/black_light_logo.png
// ─────────────────────────────────────────────

const String kBlackLightLogoAsset = 'assets/images/black_light_logo.png';

/// Tints a single-color+alpha brand asset to [BlackLightColors.textPrimary].
class _BlackLightAssetPaint extends StatelessWidget {
  const _BlackLightAssetPaint();

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(
        BlackLightColors.textPrimary,
        BlendMode.srcIn,
      ),
      child: Image.asset(
        kBlackLightLogoAsset,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        gaplessPlayback: true,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// Mark only (favicons, avatars, compact UI).
class BlackLightMark extends StatelessWidget {
  final double size;

  const BlackLightMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: CommonContent.brandWordmark,
      child: RepaintBoundary(
        child: SizedBox(
          width: size,
          height: size,
          child: const _BlackLightAssetPaint(),
        ),
      ),
    );
  }
}

/// Lockup: mark + optional “Black Light” wordmark. Constrained, scales as one unit.
class BlackLightLogo extends StatelessWidget {
  final double height;
  final double? maxWidth;
  final bool showWordmark;
  final double _markToRowHeight;

  const BlackLightLogo({
    super.key,
    this.height = 28,
    this.maxWidth,
    this.showWordmark = true,
  }) : _markToRowHeight = 0.92;

  @override
  Widget build(BuildContext context) {
    final cap = maxWidth ?? (showWordmark ? height * 5.2 : height * 1.05);
    final markSize = (height * _markToRowHeight).clamp(20.0, 56.0);
    final wordStyle = BlackLightTextStyles.cardHeading().copyWith(
      fontSize: (markSize * 0.44).clamp(12.0, 18.0),
      height: 1.0,
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RepaintBoundary(
          child: SizedBox(
            width: markSize,
            height: markSize,
            child: const _BlackLightAssetPaint(),
          ),
        ),
        if (showWordmark) ...[
          SizedBox(width: (height * 0.28).clamp(8.0, 12.0)),
          Text(
            CommonContent.brandWordmark,
            style: wordStyle,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ],
      ],
    );

    return Semantics(
      label: CommonContent.brandWordmark,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height, maxWidth: cap),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: row,
        ),
      ),
    );
  }
}
