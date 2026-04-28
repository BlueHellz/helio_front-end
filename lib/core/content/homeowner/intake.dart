// FILE: homeowner/intake.dart
// Homeowner intake / new residential project form.

class HomeownerIntakeContent {
  static const appBarTitle = 'New residential project';
  static const mapboxSetupHint =
      'Address suggestions require a local assets/env.json '
      '(copy env.json.example).';
  static const addressLabel = 'Address';
  static const addressPlaceholder = 'Start typing your street address';
  static const monthlyBillLabel = 'Monthly electricity bill (USD)';
  static const monthlyBillPrefix = r'$ ';
  static const homeownerNameLabel = 'Homeowner name';
  static const emailLabel = 'Email';
  static const phoneLabel = 'Phone';
  static const roofAgeLabel = 'Roof age';
  static const panelAmpsLabel = 'Main electrical panel amperage';
  static const goalLabel = 'Homeowner goal';
  static const hoaLabel = 'HOA restrictions';
  static const submitButton = 'Submit';

  static const roofAge0to5 = '0-5';
  static const roofAge5to10 = '5-10';
  static const roofAge10to15 = '10-15';
  static const roofAge15plus = '15+';

  static const panel100 = '100A';
  static const panel150 = '150A';
  static const panel200 = '200A';
  static const panel400 = '400A';
  static const panelUnknown = 'Unknown';

  static const goalMaxSavings = 'Max savings';
  static const goalMaxOffset = 'Max offset';
  static const goalBatteryBackup = 'Battery backup';

  static const projectSubmittedSnack = 'Project submitted.';
}
