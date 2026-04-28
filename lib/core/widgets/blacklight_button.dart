import 'package:flutter/material.dart';
import '../../theme/blacklight_theme.dart';

class BlackLightPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double height;

  const BlackLightPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
    this.height = BlackLightSpacing.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: BlackLightColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: BlackLightTextStyles.bodyBold(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class BlackLightSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double height;

  const BlackLightSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
    this.height = BlackLightSpacing.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: BlackLightColors.textPrimary,
          elevation: 0,
          side: const BorderSide(color: BlackLightColors.border),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: BlackLightColors.textBody),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: BlackLightTextStyles.bodyBold(
                  color: BlackLightColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class BlackLightMobilePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const BlackLightMobilePrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: BlackLightSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: BlackLightColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: BlackLightTextStyles.mobileButton()),
          ],
        ),
      ),
    );
  }
}
