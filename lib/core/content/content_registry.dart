// Central export for all static UI copy (laser-focused CMS).
//
// Screen → primary content file
// ─────────────────────────────────────────────────────────────────────────────
// Landing, hero, pillars, wallet teaser: landing.dart
// Pre-auth navbar, shared footer dialogs: shared/navigation.dart, shared/footer.dart
// Web + mobile auth, social stubs: auth.dart
// Homeowner dashboard, intake, AI design chat (homeowner/ai_chat.dart), messages
//   keys (homeowner/chat.dart), quote, design summary, project detail: homeowner/*.dart
// App router snackbars / edit dialogs: shared/router_strings.dart
// Shared feedback / snackbars / generic dialogs: shared/feedback_strings.dart
// Drone ops marketing: drone_ops/drone_ops.dart
// Pool marketing: investor/pool_funding.dart (exported via investor/investor.dart)
// EV hosts marketing: ev_host.dart
// Business solutions (`/enterprise`) page copy: enterprise/business_solutions.dart
// Whitepaper placeholder: whitepaper.dart
// Brand logo semantic: assets.dart
// ─────────────────────────────────────────────────────────────────────────────

export 'assets.dart';
export 'auth.dart';
export 'errors/api_errors.dart';
export 'errors/empty_states.dart';
export 'errors/field_validation.dart';
export 'enterprise.dart';
export 'enterprise/business_solutions.dart';
export 'drone_ops/drone_ops.dart';
export 'ev_host.dart';
export 'homeowner/chat.dart';
export 'homeowner/ai_chat.dart';
export 'homeowner/dashboard.dart';
export 'homeowner/design_summary.dart';
export 'homeowner/intake.dart';
export 'homeowner/project_detail.dart';
export 'homeowner/quote_request.dart';
export 'homeowner/settings_copy.dart';
export 'investor/investor.dart';
export 'landing.dart';
export 'org/projects_list.dart';
export 'shared/buttons.dart';
export 'shared/common.dart';
export 'shared/feedback_strings.dart';
export 'shared/footer.dart';
export 'shared/navigation.dart';
export 'shared/router_strings.dart';
export 'shared/wallet.dart';
export 'whitepaper.dart';
