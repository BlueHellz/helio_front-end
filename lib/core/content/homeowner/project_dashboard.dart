// FILE: homeowner/project_dashboard.dart
// Authenticated homeowner project hub (post-login dashboard).

class HomeownerProjectDashboardContent {
  static const pageTitle = 'Project Dashboard';
  static const headerSubtitle =
      'Your installation is moving forward. Review each step below.';

  static const labelAddress = 'Address';
  static const labelSystemSize = 'System size';
  static const labelProjectStatus = 'Status';
  static const statusAwaitingPermit = 'Awaiting Permit';
  static const statusInstallationScheduled = 'Installation Scheduled';

  static const stageDesign = 'Design';
  static const stagePermitting = 'Permitting';
  static const stageInstallation = 'Installation';
  static const stageComplete = 'Complete';

  static const sectionInstallers = 'Select Installer';
  static const sectionFunding = 'Choose Funding';
  static const sectionInspection = 'Schedule Inspection';
  static const sectionTimeline = 'Timeline & Updates';
  static const sectionDocuments = 'Documents';
  static const sectionCommunication = 'Messages';

  static const ratingLabel = 'Rating';
  static const yearsInBusinessLabel = 'Years in business';
  static const licenseLabel = 'License';
  static const contactLabel = 'Contact';
  static const selectCta = 'Select';
  static const selectedBadge = 'Selected';
  static const viewContractCta = 'View Contract';
  static const downloadCta = 'Download';
  static const sendCta = 'Send';
  static const messageInstallerCta = 'Message Your Installer';
  static const messageInspectorCta = 'Message Inspector';

  static const installer1Name = 'SolarPro Cooperative';
  static const installer1Rating = '4.9';
  static const installer1Years = '12';
  static const installer1License = 'HT-77821';
  static const installer1Contact = '(509) 555-0142 · install@solarpro.demo';

  static const installer2Name = 'SunPeak Energy';
  static const installer2Rating = '4.7';
  static const installer2Years = '8';
  static const installer2License = 'HT-44102';
  static const installer2Contact = '(509) 555-0198 · crew@sunpeak.demo';

  static const installer3Name = 'Kooyoh Clearwater Installers';
  static const installer3Rating = '4.8';
  static const installer3Years = '15';
  static const installer3License = 'HT-22019';
  static const installer3Contact = '(509) 555-0161 · jobs@kooyohclear.demo';

  static const fundingPoolTitle = 'KOOYOH Pool Funding';
  static const fundingPoolBody =
      'Community-backed pool participating in your project. Competitive collective rate with flexible draw schedule aligned to construction milestones.';
  static const fundingPoolRate = 'Estimated blended rate: 5.2% APR';
  static const fundingPoolTerm = 'Repayment: up to 20 years';
  static const fundingPoolNote = 'Early payoff without penalty when noted in your agreement.';

  static const fundingGreenTitle = 'Green Bank Loan';
  static const fundingGreenBody =
      'Institutional green-lending product with fixed schedule and standard disclosures.';
  static const fundingGreenRate = 'Fixed rate: 6.1% APR';
  static const fundingGreenTerm = 'Repayment: 12 or 15 years';
  static const fundingGreenNote =
      'Credit check required; funds disbursed directly to your installer of record.';

  static const inspectionIntro =
      'Pick a time for the site inspection. Availability is shown for the next two weeks.';
  static const inspectionSlot1 = 'Monday, May 12, 2026 — 9:00 a.m.';
  static const inspectionSlot2 = 'Tuesday, May 13, 2026 — 1:30 p.m.';
  static const inspectionSlot3 = 'Thursday, May 15, 2026 — 10:00 a.m.';
  static const inspectionConfirmedTitle = 'Inspection confirmed';
  static const inspectionConfirmedBody =
      'Inspector Maria Chen (badge INS-9021) will arrive at the scheduled time. '
      'Reach her at (555) 010-4421 if you need to reschedule.';

  static const timelineDesignComplete = 'Design completed';
  static const timelineDesignCompleteDetail =
      'Plans and production model are ready for permitting.';
  static const timelinePermitFiled = 'Permit application submitted';
  static const timelinePermitFiledDetail =
      'Your jurisdiction received the package and is reviewing.';

  static const timelineInstallerPrefix = 'Installer selected: ';
  static const timelineFundingPrefix = 'Funding preference: ';
  static const timelineInspectionPrefix = 'Inspection scheduled — ';

  static const docPermitTitle = 'Building permit';
  static const docPermitSubtitle = 'Stamped permit application (PDF)';
  static const docContractTitle = 'Installation contract';
  static const docContractSubtitleReady =
      'Signed agreement with your installer of record.';
  static const docContractSubtitlePending =
      'Available after you select an installer.';
  static const docInspectionTitle = 'Inspection report';
  static const docInspectionSubtitleReady = 'Post-installation sign-off.';
  static const docInspectionSubtitlePending =
      'Available after inspection is completed.';

  static const snackDownloadDemo =
      'Download will open when file storage is connected. This is a demo.';

  static const snackContractDemo =
      'Contract preview is mock data for this MVP.';

  static const contractDialogTitle = 'Installation contract (preview)';
  static const contractMockBody =
      'This agreement summarizes scope, equipment, warranty period, and milestone payments. '
      'A countersigned copy will appear here once your installer finalizes terms.';

  static const chatComposerHint = 'Write a message…';
  static const chatDummyFromInstaller =
      'Thanks for choosing us. We will file the permit checklist this week and keep you posted.';
  static const chatDummyFromYou =
      'Sounds good. Please confirm if you need anything from me before filing.';

  static const mockProjectAddress = '1842 Riverside Dr, Spokane, WA 99201';
  static const mockSystemSize = '8.4 kW DC';

  static const dateTimelineDesign = 'Apr 22, 2026';
  static const dateTimelinePermit = 'May 2, 2026';

  /// Shorthand date for MVP demo events keyed to the in-app demo timeline.
  static const dateRecentAction = 'May 6, 2026';
}
