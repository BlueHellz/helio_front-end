// Central export for all static UI copy (laser-focused CMS).
//
// Screen → primary content file
// ─────────────────────────────────────────────────────────────────────────────
// Landing, hero, pillars, wallet teaser: landing.dart
// Pre-auth navbar, shared footer dialogs: shared/navigation.dart, shared/footer.dart
// Web + mobile auth, social stubs: auth.dart
// Homeowner dashboard, dashboard_page, quote, design summary, intake, chat, project detail:
//   homeowner/*.dart
// Org / installer: web projects, CRM board, new project, org project detail, mobile shells:
//   org/*.dart + installer flows reusing org copy where appropriate
// Settings hub + field library + intake builder + pipeline + roles:
//   org/settings/*.dart
// App router snackbars / edit dialogs: shared/router_strings.dart
// Shared feedback / snackbars / generic dialogs: shared/feedback_strings.dart
// Drone ops marketing + mobile: drone_ops/drone_ops.dart
// Pool marketing + investor mobile: investor/pool_funding.dart (exported via investor/investor.dart)
// EV hosts marketing: ev_host.dart
// Whitepaper placeholder: whitepaper.dart
// Design shell, CRM deal fallbacks: org/crm/board.dart, org/crm/deal_detail.dart
// Brand logo semantic: assets.dart
// ─────────────────────────────────────────────────────────────────────────────

export 'assets.dart';
export 'auth.dart';
export 'errors/api_errors.dart';
export 'errors/empty_states.dart';
export 'errors/field_validation.dart';
export 'drone_ops/drone_ops.dart';
export 'ev_host.dart';
export 'homeowner/chat.dart';
export 'homeowner/dashboard.dart';
export 'homeowner/design_summary.dart';
export 'homeowner/intake.dart';
export 'homeowner/project_detail.dart';
export 'homeowner/quote_request.dart';
export 'investor/investor.dart';
export 'landing.dart';
export 'org/chat_design.dart';
export 'org/crm/board.dart';
export 'org/crm/deal_detail.dart';
export 'org/dashboard.dart';
export 'org/premium_dashboard.dart';
export 'org/mobile_installer.dart';
export 'org/new_project.dart';
export 'org/project_detail.dart';
export 'org/projects_list.dart';
export 'org/org_settings_hub.dart';
export 'org/settings/ai_prefs.dart';
export 'org/settings/api_keys.dart';
export 'org/settings/billing.dart';
export 'org/settings/branding.dart';
export 'org/settings/field_library.dart';
export 'org/settings/intake_builder.dart';
export 'org/settings/phone.dart';
export 'org/settings/pipeline_builder.dart';
export 'org/settings/role_management.dart';
export 'org/settings/settings_hub.dart';
export 'shared/buttons.dart';
export 'shared/common.dart';
export 'shared/feedback_strings.dart';
export 'shared/footer.dart';
export 'shared/navigation.dart';
export 'shared/router_strings.dart';
export 'shared/wallet.dart';
export 'whitepaper.dart';
