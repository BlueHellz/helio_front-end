// FILE: org/settings/pipeline_builder.dart
// Pipeline and stage editor.

class OrgSettingsPipelineBuilderContent {
  static const appBarTitle = 'Pipeline Builder';
  static const pageSubtitle =
      'Create pipelines and stages. Changes sync to the CRM board.';
  static const dialogNewPipelineTitle = 'New pipeline';
  static const labelPipelineName = 'Name';
  static const fabPipelineLabel = 'Create Pipeline';
  static const fabCreatePipeline = 'Create Pipeline';
  static const defaultPipelineName = 'Pipeline';
  static const selectPipelineFirst = 'Select a pipeline to edit stages.';
  static const pipelinesLoadFailedHint =
      'Could not load pipelines from the server. You can still create one and open Flow Mesh locally.';
  static const stagesHeading = 'Stages';
  static const addStageDialogTitle = 'Add stage';
  static const labelStageName = 'Name';
  static const labelTriggerCondition = 'Trigger condition (optional)';
  static const addStageButton = 'Add Stage';
  static const dealCardFieldsTitle = 'Deal card fields';
  static const editPipeline = 'Edit';
  static const stageCountSuffix = ' stages';
  static const savePipeline = 'Save';
  static const labelStageColor = 'Column color';
  static const colorPrimary = 'Accent';
  static const colorGreen = 'Green';
  static const colorAmber = 'Amber';
  static const colorError = 'Alert';
  static const colorMuted = 'Muted';
  static const deleteStageTooltip = 'Remove stage';
  static const pipelineSavedSnack = 'Pipeline saved';
  static const pipelineSaveFailedPrefix = 'Could not save pipeline: ';

  // ─── Flow Mesh (visual node editor) ───────────────────────────
  static const flowMeshTitle = 'Flow Mesh';
  static const flowMeshCanvasHint =
      'Pan on the grid. Long-press a node to move it. Long-press an output port and drag to an input port to connect.';
  static const toolbarAddStage = 'Add Stage';
  static const toolbarAddTrigger = 'Add Trigger';
  static const toolbarAddAction = 'Add Action';
  static const toolbarZoomOut = 'Zoom out';
  static const toolbarZoomIn = 'Zoom in';
  static const toolbarZoomPercentSuffix = '%';
  static const toolbarFitToScreen = 'Fit to screen';
  static const panelTitle = 'Node properties';
  static const panelCloseA11y = 'Close panel';
  static const panelNodeNameLabel = 'Node name';
  static const panelEventTypeLabel = 'Event type';
  static const panelColorLabel = 'Node color';
  static const panelDeleteNode = 'Delete node';
  static const eventTypeWebhook = 'Webhook listener';
  static const eventTypeApi = 'API call';
  static const eventTypeManual = 'Manual trigger';
  static const newStageDefaultName = 'New Stage';
  static const newTriggerDefaultName = 'New Trigger';
  static const newActionDefaultName = 'New Action';
  static const nodeMetadataStage = 'Pipeline stage';
  static const nodeMetadataTrigger = 'Trigger';
  static const nodeMetadataAction = 'Action';
  static const wireDeleteA11y = 'Delete connection';
  static const wireDeleteConfirmTitle = 'Remove connection';
  static const wireDeleteConfirmBody =
      'Disconnect these stages? This does not delete the stages.';
  static const deleteNodeConfirmBody =
      'Delete this stage from the pipeline? Deals may need to be reassigned.';
  static const stageTypeStage = 'stage';
  static const stageTypeTrigger = 'trigger';
  static const stageTypeAction = 'action';
}
