import 'package:flutter/material.dart';
import '../../theme/kooyoh_theme.dart';

class BlackLightInput extends StatelessWidget {
  final String? label;
  final String placeholder;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isMobile;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const BlackLightInput({
    super.key,
    this.label,
    required this.placeholder,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.isMobile = false,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final height = isMobile
        ? KooyohSpacing.inputHeightMobile
        : KooyohSpacing.inputHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: KooyohTextStyles.captionBold(
                color: KooyohColors.textCaption),
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: maxLines > 1 ? null : height,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            maxLines: maxLines,
            style: isMobile
                ? KooyohTextStyles.mobileBody(
                    color: KooyohColors.textPrimary)
                : KooyohTextStyles.body(
                    color: KooyohColors.textPrimary),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: isMobile
                  ? KooyohTextStyles.mobileBody(
                      color: KooyohColors.textCaption)
                  : KooyohTextStyles.body(
                      color: KooyohColors.textCaption),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: KooyohColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KooyohRadius.input),
                borderSide: const BorderSide(color: KooyohColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KooyohRadius.input),
                borderSide: const BorderSide(color: KooyohColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KooyohRadius.input),
                borderSide: const BorderSide(
                    color: KooyohColors.accent, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class BlackLightSearchBar extends StatelessWidget {
  final String placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const BlackLightSearchBar({
    super.key,
    this.placeholder = 'Search...',
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: KooyohTextStyles.mobileBody(
            color: KooyohColors.textPrimary),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: KooyohTextStyles.mobileBody(
              color: KooyohColors.textCaption),
          prefixIcon: const Icon(Icons.search,
              color: KooyohColors.textCaption, size: 20),
          filled: true,
          fillColor: KooyohColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: KooyohColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: KooyohColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide:
                const BorderSide(color: KooyohColors.accent, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
