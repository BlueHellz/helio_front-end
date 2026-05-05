import 'package:flutter/material.dart';

import '../models/project.dart';
import '../../services/api.dart';
import '../../theme/limye_theme.dart';

/// Status pill for project rows; supports both enum and raw API strings.
class ProjectStatusBadge extends StatelessWidget {
  const ProjectStatusBadge({
    super.key,
    this.status,
    this.statusRaw,
  }) : assert(
          status != null || statusRaw != null,
          'Provide status or statusRaw',
        );

  final ProjectStatus? status;
  final String? statusRaw;

  @override
  Widget build(BuildContext context) {
    final resolved = status ?? parseProjectStatusFromApi(statusRaw);
    final s = resolved ?? ProjectStatus.designing;
    final (bg, fg, bd) = s.resolveBadgeColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd, width: 1),
      ),
      child: Text(
        s.label.toUpperCase(),
        style: LimyeTextStyles.captionBold(color: fg),
      ),
    );
  }
}
