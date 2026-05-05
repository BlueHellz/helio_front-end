import 'package:flutter/material.dart';

import '../content/content_registry.dart';
import '../../theme/limye_theme.dart';

enum ProjectStatus {
  designing,
  ready,
  quoted,
  contracted,
  permitted,
  installed,
  completed,
  inProgress,
  pendingInspection
}

enum ProjectType { residential, commercial, industrial }

extension ProjectStatusLabel on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.designing:
        return OrgProjectsListContent.statusDesigning;
      case ProjectStatus.ready:
        return OrgProjectsListContent.statusReady;
      case ProjectStatus.quoted:
        return OrgProjectsListContent.statusQuoted;
      case ProjectStatus.contracted:
        return OrgProjectsListContent.statusContracted;
      case ProjectStatus.permitted:
        return OrgProjectsListContent.statusPermitted;
      case ProjectStatus.installed:
        return OrgProjectsListContent.statusInstalled;
      case ProjectStatus.completed:
        return OrgProjectsListContent.statusCompleted;
      case ProjectStatus.inProgress:
        return OrgProjectsListContent.statusInProgress;
      case ProjectStatus.pendingInspection:
        return OrgProjectsListContent.statusPendingInsp;
    }
  }

  (Color bg, Color fg, Color border) resolveBadgeColors(BuildContext context) {
    final c = context.colors;
    switch (this) {
      case ProjectStatus.designing:
      case ProjectStatus.ready:
      case ProjectStatus.inProgress:
      case ProjectStatus.completed:
        return (
          c.surfaceMuted,
          c.onSurface,
          c.outline,
        );
      case ProjectStatus.quoted:
      case ProjectStatus.pendingInspection:
        return (
          c.warning.withOpacity(0.2),
          c.warning,
          c.warning,
        );
      case ProjectStatus.contracted:
      case ProjectStatus.permitted:
      case ProjectStatus.installed:
        return (
          c.secondary.withOpacity(0.2),
          c.secondary,
          c.secondary,
        );
    }
  }
}

extension ProjectTypeLabel on ProjectType {
  String get label {
    switch (this) {
      case ProjectType.residential:
        return OrgProjectsListContent.typeResidential;
      case ProjectType.commercial:
        return OrgProjectsListContent.typeCommercial;
      case ProjectType.industrial:
        return OrgProjectsListContent.typeIndustrial;
    }
  }
}

class Project {
  final String id;
  final String address;
  final String clientName;
  final String? clientEmail;
  final String? clientPhone;
  final ProjectStatus status;
  final ProjectType type;
  final DateTime date;
  final double? systemSizeKw;
  final int? panelCount;
  final double? annualProductionKwh;
  final double? yearOneSavings;
  final String? assignee;
  final double? estimatedPaybackYears;
  final String? incentivesSummary;

  const Project({
    required this.id,
    required this.address,
    required this.clientName,
    this.clientEmail,
    this.clientPhone,
    required this.status,
    required this.type,
    required this.date,
    this.systemSizeKw,
    this.panelCount,
    this.annualProductionKwh,
    this.yearOneSavings,
    this.assignee,
    this.estimatedPaybackYears,
    this.incentivesSummary,
  });
}

class ActivityEntry {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;

  const ActivityEntry({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
  });
}

class Lead {
  final String id;
  final String name;
  final String address;
  final String? systemSizeKw;
  final String source;
  final DateTime addedAt;
  final LeadStage stage;
  final String? intent;

  const Lead({
    required this.id,
    required this.name,
    required this.address,
    this.systemSizeKw,
    required this.source,
    required this.addedAt,
    required this.stage,
    this.intent,
  });
}

enum LeadStage { newLead, contacted, quoted, negotiation, won, lost }

extension LeadStageLabel on LeadStage {
  String get label {
    switch (this) {
      case LeadStage.newLead:
        return OrgCrmLeadStagesContent.stageNew;
      case LeadStage.contacted:
        return OrgCrmLeadStagesContent.stageContacted;
      case LeadStage.quoted:
        return OrgCrmLeadStagesContent.stageQuoted;
      case LeadStage.negotiation:
        return OrgCrmLeadStagesContent.stageNegotiation;
      case LeadStage.won:
        return OrgCrmLeadStagesContent.stageWon;
      case LeadStage.lost:
        return OrgCrmLeadStagesContent.stageLost;
    }
  }

  Color stageColorIn(BuildContext context) {
    final c = context.colors;
    final cs = Theme.of(context).colorScheme;
    switch (this) {
      case LeadStage.newLead:
        return c.primary;
      case LeadStage.contacted:
        return cs.onSurfaceVariant;
      case LeadStage.quoted:
        return c.warning;
      case LeadStage.negotiation:
        return c.onSurface;
      case LeadStage.won:
        return c.secondary;
      case LeadStage.lost:
        return c.error;
    }
  }
}
