import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/blacklight_theme.dart';
import 'providers/org_providers.dart';

/// Wraps sections that gain edit chrome when org design mode is enabled.
class DesignModeWrapper extends ConsumerWidget {
  const DesignModeWrapper({
    super.key,
    required this.sectionId,
    required this.child,
    this.onRemove,
  });

  final String sectionId;
  final Widget child;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(designModeProvider);
    final enabled = mode.valueOrNull ?? false;

    if (!enabled) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BlackLightRadius.md),
            border: Border.all(
              color: BlackLightColors.accent,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          padding: const EdgeInsets.all(BlackLightSpacing.sm),
          child: child,
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.drag_indicator,
                size: 20,
                color: BlackLightColors.textCaption,
              ),
              if (onRemove != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: BlackLightColors.textCaption,
                  ),
                  onPressed: onRemove,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
