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
  static const dealSizeLabel = 'Deal size';
  static const statusLabel = 'Status';
  static const designModeHint =
      'Design mode: use handles to reorder stages. Deal cards stay read-only.';
  static const liveModeHint = 'Live mode: tap a card to open deal details.';
  static const refreshBoard = 'Refresh';
}

class OrgCrmDealContent {
  static const dealFallbackTitle = 'Deal';
}
