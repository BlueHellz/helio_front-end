import 'package:flutter/material.dart';
import '../../../theme/blacklight_theme.dart';

// ─────────────────────────────────────────────
// BLACK LIGHT — Drone Operator: Capture (mobile)
// Flat geometric viewfinder (design system: light, no gradients/shadows).
// ─────────────────────────────────────────────

class DroneCaptureScreen extends StatelessWidget {
  final String? activeMissionId;
  final VoidCallback? onClose;

  const DroneCaptureScreen({
    super.key,
    this.activeMissionId,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlackLightColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _ViewfinderPainter())),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _TopHud(
                missionId: activeMissionId,
                onClose: onClose,
              ),
            ),
            const Center(child: _Reticle()),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: const _CaptureControls(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = BlackLightColors.background;
    canvas.drawRect(Offset.zero & size, bg);

    final dot = Paint()..color = BlackLightColors.border;
    const step = 28.0;
    for (double y = step / 2; y < size.height; y += step) {
      for (double x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.0, dot);
      }
    }

    final line = Paint()
      ..color = BlackLightColors.textCaption
      ..strokeWidth = 1.0;
    final w3 = size.width / 3;
    final h3 = size.height / 3;
    canvas.drawLine(Offset(w3, 0), Offset(w3, size.height), line);
    canvas.drawLine(Offset(2 * w3, 0), Offset(2 * w3, size.height), line);
    canvas.drawLine(Offset(0, h3), Offset(size.width, h3), line);
    canvas.drawLine(Offset(0, 2 * h3), Offset(size.width, 2 * h3), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopHud extends StatelessWidget {
  final String? missionId;
  final VoidCallback? onClose;

  const _TopHud({this.missionId, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HudPill(
          icon: Icons.gps_fixed,
          label: missionId == null || missionId!.isEmpty
              ? 'NO ACTIVE MISSION'
              : 'MISSION · ${missionId!}',
        ),
        const Spacer(),
        const _HudPill(icon: Icons.battery_full_outlined, label: '— %'),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: BlackLightColors.surface,
              border: Border.all(color: BlackLightColors.border),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.close,
                color: BlackLightColors.textBody, size: 18),
          ),
        ),
      ],
    );
  }
}

class _HudPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HudPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        border: Border.all(color: BlackLightColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: BlackLightColors.textBody, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: BlackLightTextStyles.caption(color: BlackLightColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _Reticle extends StatelessWidget {
  const _Reticle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(painter: _ReticlePainter()),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = BlackLightColors.accent;
    canvas.drawCircle(centre, size.width * 0.42, ring);
    canvas.drawCircle(centre, size.width * 0.18, ring);

    final tick = Paint()
      ..color = BlackLightColors.accent
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(centre.dx - 16, centre.dy),
        Offset(centre.dx + 16, centre.dy), tick);
    canvas.drawLine(Offset(centre.dx, centre.dy - 16),
        Offset(centre.dx, centre.dy + 16), tick);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CaptureControls extends StatelessWidget {
  const _CaptureControls();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ControlButton(icon: Icons.layers_outlined, label: 'Layers'),
        _CaptureButton(),
        _ControlButton(icon: Icons.tune, label: 'Tune'),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ControlButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          child: Icon(icon, color: BlackLightColors.textBody, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: BlackLightTextStyles.caption(),
        ),
      ],
    );
  }
}

class _CaptureButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: BlackLightColors.accent,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BlackLightColors.accent,
              border: Border.all(color: Colors.white, width: 4),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'CAPTURE',
          style: BlackLightTextStyles.captionBold(
            color: BlackLightColors.textBody,
          ),
        ),
      ],
    );
  }
}
