// FILE: homeowner/chat.dart
// Homeowner Messages page and placeholder chat copy.
// Primary AI design chat strings: homeowner/ai_chat.dart (AiChatContent).

class HomeownerChatContent {
  static const pageTitle = 'Messages';
  static const pageTitleDesign = 'Design with LIMYÈ AI';

  /// Auth-free design assistant entry (replaces legacy placeholder stack).
  static const welcomeSystemDesign =
      'Welcome. I am your LIMYÈ design assistant. Share your home address '
      'to begin—we will walk through your bill and goals conversationally.';
  static const aiReplyAfterAddress =
      'Thanks—I have that address. What is your typical monthly electricity bill in US dollars? '
      'A rough average is perfect.';
  static const aiReplyAfterBill =
      'Got it. If you have a goal in mind—max savings, backup power, or offsetting a target share '
      'of your usage—tell me in a sentence. Otherwise say “continue” and we will proceed.';
  static const aiReplyContinue =
      'Noted. Keep going: roof age, main panel size, or anything else about your home '
      'helps tighten the design.';
  static const composerHint =
      'Message the assistant. No account needed to explore your design.';

  static const placeholderSystemMessage =
      'Welcome to LIMYÈ NOIR. When design automation is enabled, your assistant will appear here.';
  static const placeholderAiMessage =
      'For now, this chat is a visual placeholder. Messages are not sent to a model.';
  static const composerDisabledHint =
      'Composer disabled until the assistant is connected.';

  // Design studio (split layout)
  static const designAiTitle = 'LIMYÈ AI';
  static const designLiveChip = 'Live';
  static const designInputPlaceholder = 'Type a message...';
  static const designPreviewTitle = 'Design Preview';
  static const designViewSummary = 'View Summary';
  static const designStartTitle = 'Start your design';
  static const designStartBody =
      'Describe your home or paste your address. Our AI will guide you through the rest.';
  static const designAwaitingInput = 'Awaiting your input';
  static const metricSystemSize = 'System size';
  static const metricAnnualProduction = 'Annual production';
  static const metricYearOneSavings = 'Year-1 savings';
  static const metricPanels = 'Panels';
}
