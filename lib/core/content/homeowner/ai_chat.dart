// AI conversational design chat (split panel desktop, full-screen mobile).

class AiChatContent {
  AiChatContent._();

  static const pageTitle = 'Design with LIMYÈ AI';
  static const messagesTabTitle = 'Messages';

  // Chat chrome — desktop panel header / mobile top bar
  static const headerBrand = 'LIMYÈ AI';
  /// Shown under the brand until an address exists on the design provider.
  static const headerSubtitlePending =
      'Use Quick Intake to generate your roof preview.';

  /// Composer
  static const inputPlaceholderDesktop = 'Ask about savings or panels...';
  static const inputPlaceholderMobile = 'Type your message...';

  /// Composer pill — opens guided intake modal (single entry point).
  static const quickIntakeFormButtonLabel = 'Quick Intake Form';

  // Seeded conversation — desktop (split view): generic copy without sample production metrics.
  static const seedAiWelcomeDesktop =
      'Welcome. I can walk you through savings and system sizing once we have '
      'your roof preview. Open Quick Intake whenever you are ready to add your address.';
  static const seedUserQuestionDesktop =
      'What information do you need from me to get started?';

  // Seeded conversation — mobile
  static const seedAiWelcomeMobile =
      'Hello! I am LIMYÈ AI. Share a few details about your home and electricity '
      'use, and I will help you explore solar. You can use Quick Intake to enter '
      'everything in one place.';
  static const seedUserConfirmMobile =
      'Sounds good—I will complete the intake form.';
  static const seedAiLayoutsLeadMobile =
      'Great. After your roof preview loads, we can compare layout priorities '
      'such as production versus curb appeal.';

  static const layoutOptionMaxProductionTitle = 'Max Production';
  static const layoutOptionMaxProductionSubtitle =
      'Prioritizes annual energy yield.';
  static const layoutOptionAestheticTitle = 'Aesthetic Focus';
  static const layoutOptionAestheticSubtitle =
      'Keeps panels less visible from the street.';

  // Live assistant replies (after user sends)
  static const aiReplyAfterAddress =
      'Thanks—I have that address. What is your typical monthly electricity bill '
      'in US dollars? A rough average is perfect.';
  static const aiReplyAfterBill =
      'Got it. If you have a goal in mind—max savings, backup power, or offsetting '
      'a target share of your usage—tell me in a sentence. Otherwise say '
      '“continue” and we will proceed.';
  static const aiReplyContinue =
      'Noted. Keep going: roof age, main panel size, or anything else about your '
      'home helps tighten the design.';

  // Visualization (legacy keys; AI chat rail uses [DesignDisplayWidget] + API data).
  static const vizEmptyTitle = 'Your solar design will appear here.';
  // Guided form modal
  static const modalTitle = quickIntakeFormButtonLabel;
  static const modalOwnerNameLabel = "Home Owner's Name";
  static const modalOwnerNameHint = 'Jane Doe';
  static const modalAddressLabel = 'Street address';
  static const modalAddressHint = '123 Main Street';
  static const modalCityLabel = 'City';
  static const modalCityHint = 'Austin';
  static const modalStateLabel = 'State';
  static const modalZipLabel = 'ZIP code';
  static const modalZipHint = '78701';
  static const modalBillLabel = 'Average Monthly Electric Bill (\$)';
  static const modalBillHint = 'e.g. 150';
  static const modalUsageKwhLabel = 'Monthly Usage (kWh)';
  static const modalUsageKwhHint = 'e.g. 850';
  static const modalEmailLabel = 'Email Address';
  static const modalEmailHint = 'jane@example.com';
  static const modalPhoneLabel = 'Phone Number';
  static const modalPhoneHint = '(555) 000-0000';
  static const modalRoofAgeLabel = 'Roof Age';
  static const modalPanelAmpsLabel = 'Main Electrical Panel Amperage';
  static const modalSelectHint = 'Select';
  static const modalRoofAge05 = '0–5 years';
  static const modalRoofAge510 = '5–10 years';
  static const modalRoofAge1015 = '10–15 years';
  static const modalRoofAge15Plus = '15+ years';
  static const modalPanel100 = '100A';
  static const modalPanel150 = '150A';
  static const modalPanel200 = '200A';
  static const modalPanel400 = '400A';
  static const modalPanelUnknown = 'Unknown';
  static const modalGoalSectionLabel = 'Primary Goal';
  static const modalGoalSavingsTitle = 'Maximum Savings';
  static const modalGoalOffsetTitle = 'Maximum Energy Offset';
  static const modalHoaSectionLabel = 'HOA Restrictions';
  static const modalHoaYes = 'Yes';
  static const modalHoaNo = 'No';
  static const modalLocateMeHint = 'Use my approximate location';
  static const modalSubmitCta = 'Generate My Design';
  static const modalErrorRequired = 'This field is required.';
  static const modalErrorInvalidNumber = 'Enter a valid number.';
  static const modalErrorInvalidEmail = 'Enter a valid email address.';
  static const modalErrorSelectDropdown = 'Please select an option.';
  static const modalErrorHoa =
      'Please indicate whether HOA restrictions apply.';
  static const modalErrorInvalidZip =
      'Enter a valid 5-digit ZIP code.';

  /// Shown after a successful guided form submit (fills chat timeline).
  static const aiReplyAfterGuidedForm =
      'Thank you—I captured your intake and refreshed the preview with those details.';

  /// Composer send control.
  static const sendButtonLabel = 'Send';

  // Accessibility / semantics
  static const sendMessageHint = 'Send message';
  static const openVisualizationHint = 'View solar design';
  static const attachHint = 'Add attachment';
  static const moreOptionsHint = 'More options';

  // Message bubble micro-label (AI)
  static const aiBubbleLabel = 'LIMYÈ';

  // Messages tab (non-design) placeholder copy
  static const messagesTabSystem =
      'Welcome to LIMYÈ. When design automation is enabled, your assistant will '
      'appear here.';
  static const messagesTabAiPlaceholder =
      'This channel is a placeholder until the assistant is connected.';
  static const composerDisabledHint =
      'Composer disabled until the assistant is connected.';
}
