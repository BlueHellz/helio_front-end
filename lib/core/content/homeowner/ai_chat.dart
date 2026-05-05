// AI conversational design chat (split panel desktop, full-screen mobile).

class AiChatContent {
  AiChatContent._();

  static const pageTitle = 'Design with LIMYÈ AI';
  static const messagesTabTitle = 'Messages';

  // Chat chrome — desktop panel header / mobile top bar
  static const headerBrand = 'LIMYÈ AI';
  static const headerAddressDemo = '1248 Oakwood Ave, Austin, TX';

  /// Composer
  static const inputPlaceholderDesktop =
      'Ask about savings or panels...';
  static const inputPlaceholderMobile = 'Type your message...';
  static const preferGuidedFormCta = 'Prefer a quick guided form?';

  // Seeded conversation — desktop (split view)
  static const seedAiWelcomeDesktop =
      'Welcome back, Sarah. I\'ve analyzed your roof\'s solar potential. Based on '
      'your 1,200 sq ft south-facing plane, we can maximize efficiency with 18 panels.';
  static const seedUserQuestionDesktop =
      'That sounds great. What would my estimated savings be over 20 years?';

  // Seeded conversation — mobile
  static const seedAiWelcomeMobile =
      'Hello! I\'m LIMYÈ AI. I\'ve analyzed the satellite imagery for 123 Main St. '
      'I found a suitable roof area of 850 sq ft facing South-West. Would you like '
      'to proceed with a preliminary design?';
  static const seedUserConfirmMobile =
      'Yes, please show me the layout options.';
  static const seedAiLayoutsLeadMobile =
      'Great. I\'ve generated two preliminary layouts based on optimal sun '
      'exposure and local setback regulations.';

  static const layoutOptionMaxProductionTitle = 'Max Production';
  static const layoutOptionMaxProductionSubtitle = '12.4 kW system';
  static const layoutOptionAestheticTitle = 'Aesthetic Focus';
  static const layoutOptionAestheticSubtitle = '9.8 kW system';

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

  // Visualization
  static const vizEmptyTitle = 'Your solar design will appear here.';
  static const vizMetricSystemSize = 'System Size';
  static const vizMetricPanels = 'Panels';
  static const vizMetricSavings = 'Savings';
  static const vizDemoSystemSize = '7.2 kW';
  static const vizDemoPanels = '18';
  static const vizDemoSavings = '\$34,200';
  static const vizLegendIdeal = 'Ideal';
  static const vizLegendGood = 'Good';
  static const vizLegendUnused = 'Unused';

  // Guided form modal
  static const modalTitle = 'Quick Intake Form';
  static const modalAddressLabel = 'Address';
  static const modalBillLabel = 'Average Monthly Bill (\$)';
  static const modalBillHint = 'e.g. 150';
  static const modalNameLabel = 'Name';
  static const modalNameHint = 'Jane Doe';
  static const modalEmailLabel = 'Email';
  static const modalEmailHint = 'jane@example.com';
  static const modalPhoneLabel = 'Phone';
  static const modalPhoneHint = '(555) 000-0000';
  static const modalRoofAgeLabel = 'Roof age (years)';
  static const modalRoofAgeHint = 'e.g. 8';
  static const modalPanelAmpsLabel = 'Main panel (amps)';
  static const modalPanelAmpsHint = 'e.g. 200';
  static const modalGoalSectionLabel = 'Primary Goal';
  static const modalGoalSavingsTitle = 'Maximum Savings';
  static const modalGoalOffsetTitle = 'Maximum Offset';
  static const modalHoaLabel = 'Property is in an HOA';
  static const modalSubmitCta = 'Generate My Design';

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
