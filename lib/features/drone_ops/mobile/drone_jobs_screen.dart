import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import '../../../theme/blacklight_theme.dart';
import 'drone_operator_shell.dart';

// ─────────────────────────────────────────────
// BLACK LIGHT — Drone Operator: Jobs (mobile)
// Empty by default; fills with backend-provided missions.
// ─────────────────────────────────────────────

class DroneJobsScreen extends StatelessWidget {
  /// Mission list — pure UI; data comes from backend.
  final List<DroneMission> missions;
  final ValueChanged<DroneMission>? onAcceptMission;

  const DroneJobsScreen({
    super.key,
    this.missions = const [],
    this.onAcceptMission,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const DroneOperatorAppBar(title: DroneOpsContent.mobileAppBarOperatorPortal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            BlackLightSpacing.sm, BlackLightSpacing.md, BlackLightSpacing.sm, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DroneOpsContent.jobsTitle, style: BlackLightTextStyles.mobileH1()),
            const SizedBox(height: 4),
            Text(DroneOpsContent.jobsSubtitle,
                style: BlackLightTextStyles.mobileBody(
                    color: BlackLightColors.textCaption)),
            const SizedBox(height: BlackLightSpacing.md),
            const _MapCard(),
            const SizedBox(height: BlackLightSpacing.md),
            Text(DroneOpsContent.missionQueueTitle,
                style: BlackLightTextStyles.mobileH3()),
            const SizedBox(height: BlackLightSpacing.sm),
            if (missions.isEmpty)
              const _EmptyMissions()
            else
              Column(
                children: missions
                    .map((m) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: BlackLightSpacing.sm),
                          child: _MissionCard(
                            mission: m,
                            onAccept: () => onAcceptMission?.call(m),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class DroneMission {
  final String id;
  final String address;
  final String distanceLabel;
  final double payoutHlio;
  final String roofTypeLabel;

  const DroneMission({
    required this.id,
    required this.address,
    required this.distanceLabel,
    required this.payoutHlio,
    required this.roofTypeLabel,
  });
}

// ─────────────────────────────────────────────
// MAP CARD — purely decorative, no live geo data
// ─────────────────────────────────────────────
class _MapCard extends StatelessWidget {
  const _MapCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BlackLightRadius.card),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: BlackLightColors.surface,
            border: Border.all(color: BlackLightColors.border),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: BlackLightColors.surface,
                    border: Border.all(color: BlackLightColors.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(DroneOpsContent.operatingArea,
                      style: BlackLightTextStyles.captionBold(
                          color: BlackLightColors.textBody)),
                ),
              ),
              Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: BlackLightColors.surface,
                    border: Border.all(color: BlackLightColors.accent),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: BlackLightColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BlackLightColors.border
      ..strokeWidth = 1.0;
    const step = 24.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// MISSION CARD
// ─────────────────────────────────────────────
class _MissionCard extends StatelessWidget {
  final DroneMission mission;
  final VoidCallback? onAccept;

  const _MissionCard({required this.mission, this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.sm),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(mission.address,
                    style: BlackLightTextStyles.mobileH3(),
                    overflow: TextOverflow.ellipsis),
              ),
              Text(
                  '${mission.payoutHlio.toStringAsFixed(2)}${DroneOpsContent.missionPayoutSuffix}',
                  style: BlackLightTextStyles.dataLarge()
                      .copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 14, color: BlackLightColors.textCaption),
              const SizedBox(width: 4),
              Text(mission.distanceLabel,
                  style: BlackLightTextStyles.mobileBody(
                      color: BlackLightColors.textBody)),
              const SizedBox(width: 12),
              const Icon(Icons.home_outlined,
                  size: 14, color: BlackLightColors.textCaption),
              const SizedBox(width: 4),
              Text(mission.roofTypeLabel,
                  style: BlackLightTextStyles.mobileBody(
                      color: BlackLightColors.textBody)),
            ],
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: BlackLightSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: BlackLightColors.accent,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Text(DroneOpsContent.acceptMission,
                  style: BlackLightTextStyles.mobileButton()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyMissions extends StatelessWidget {
  const _EmptyMissions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BlackLightSpacing.md),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: BlackLightColors.surface,
              border: Border.all(color: BlackLightColors.border),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.inbox_outlined,
                size: 26, color: BlackLightColors.textBody),
          ),
          const SizedBox(height: BlackLightSpacing.sm),
          Text(EmptyStatesContent.noMissionsTitle,
              style: BlackLightTextStyles.mobileH3(),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(EmptyStatesContent.noMissionsSubtitle,
              style: BlackLightTextStyles.mobileBody(
                  color: BlackLightColors.textCaption),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
