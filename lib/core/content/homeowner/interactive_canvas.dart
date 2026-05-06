// Interactive solar design canvas (homeowner AI chat, right rail / sheet).

class InteractiveCanvasContent {
  InteractiveCanvasContent._();

  /// Shown while [SolarDesignViewState.data] is null (no error).
  static const waitingBody = 'Your solar design will appear here.';

  static const noRoofDataBody = 'No roof data available for this address.';

  static const backendErrorBody =
      'We couldn\'t generate a design. Please try again.';

  static const toolbarReset = 'Reset';
  static const toolbarZoomIn = 'Zoom in';
  static const toolbarZoomOut = 'Zoom out';
  static const toolbarFit = 'Fit to screen';

  static const fabAddPanel = 'Add solar panel';

  static const placementModeHint =
      'Tap a roof plane to place a panel. Tap again to cancel.';
  static const placementExit = 'Done';

  static const contextDelete = 'Delete panel';
  static const contextRotate = 'Rotate orientation';

  static const metricPanels = 'Panels';
  static const metricSystemKw = 'System size (kW)';
  static const metricAnnualProduction = 'Annual production (kWh)';
  static const metricSavings25 = '25-year savings (est.)';
  static const metricPayback = 'Payback (years)';
  static const metricTotalCost = 'Total system cost';
  static const metricIncentivesHeading = 'Incentives';

  static const incentiveFederalItc = 'Federal ITC (30%)';

  static const paybackUnavailable = '—';

  /// System line shown in chat when layout or financials change.
  static String designChangeSummary({
    required int panelCount,
    required String systemKw,
    required String savings25Usd,
    required String annualKwh,
  }) {
    final dollars = savings25Usd;
    return 'Design updated: $panelCount panels, $systemKw kW system, '
        '$annualKwh kWh/year production estimate, '
        '${'\$'}$dollars cumulative savings over 25 years.';
  }

  /// Roof orientation legend rows (maps to orientation score tiers).
  static const legendTierExcellent = 'Excellent (south bias)';
  static const legendTierGood = 'Good';
  static const legendTierFair = 'Fair';
  static const legendTierLow = 'Lower yield';
}
