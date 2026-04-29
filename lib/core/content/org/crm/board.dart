// FILE: org/crm/board.dart
// CRM Kanban board, pipeline picker, lead dialogs.

class OrgCrmBoardContent {
  static const pageTitle = 'CRM';
  static const webPipelineHeader = 'CRM Pipeline';
  static const webPipelineSubtitle = 'Manage leads and deal stages.';
  static const searchLeadsHint = 'Search leads...';
  static const addLeadFab = 'Add Lead';
  static const createPipelineHint =
      'Create a pipeline under Organization settings.';
  static const leadSourceManual = 'Manual';
  static const addLeadTitle = 'Add lead';
  static const addLeadNameLabel = 'Name';
  static const addLeadAddressLabel = 'Address';
  static const kwSuffix = ' kW';

  static const emptyDealsTitle = 'No deals yet';
  static const emptyDealsSubtitle =
      'When leads enter your pipeline they appear as cards here.';
  static const emptyStageDeals = 'No deals in this stage';
  static const dealSizeLabel = 'Deal size';
  static const statusLabel = 'Status';
  static const designModeHint =
      'Adjust stage order with the header handles. Long-press a deal to move it between columns.';
  static const liveModeHint =
      'Long-press a deal card, then drop it on another stage to update the deal.';
  static const refreshBoard = 'Refresh';
  static const dealMovedFailedPrefix = 'Could not move deal: ';
  static const mockDataBanner =
      'Showing sample data — reconnect to sync your live pipeline.';
}

class OrgCrmDealContent {
  static const dealFallbackTitle = 'Deal';
}
