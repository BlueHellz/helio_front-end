import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:blacklight_app/core/models/project.dart';

/// Lightweight sizing/savings estimate for anonymous preview (no API).
Project buildLocalPreviewProject({
  required String address,
  required String clientName,
  String? clientEmail,
  String? clientPhone,
  double? monthlyBillUsd,
}) {
  final bill = monthlyBillUsd ?? 150.0;
  final yearOneSavings = bill * 12 * 0.28;
  final systemSizeKw = (bill / 18).clamp(4.0, 25.0);
  final panelCount = (systemSizeKw * 1000 / 400).round().clamp(8, 64);
  final annualProductionKwh = systemSizeKw * 1350;

  final name = clientName.trim();
  return Project(
    id: '',
    address: address,
    clientName: name.isEmpty ? CommonContent.emDash : name,
    clientEmail: clientEmail,
    clientPhone: clientPhone,
    status: ProjectStatus.designing,
    type: ProjectType.residential,
    date: DateTime.now(),
    systemSizeKw: systemSizeKw,
    panelCount: panelCount,
    annualProductionKwh: annualProductionKwh,
    yearOneSavings: yearOneSavings,
  );
}
