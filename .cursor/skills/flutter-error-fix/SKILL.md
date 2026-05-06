---
name: flutter-error-fix
description: Responds to Flutter errors by pinning the offending widget file and line, moving user-facing strings into lib/core/content/, replacing hardcoded colors with theme tokens (context.colors / Theme.colorScheme), running flutter analyze, and committing with a descriptive message. Use when stack traces reference widget code, analyzer errors point at UI files, or the user asks to fix a Flutter error using the full content/theme/analyze/commit checklist.
disable-model-invocation: true
---

# Flutter error fix workflow

When a Flutter error occurs:

1. Find the exact widget file and line.
2. Ensure all strings come from the content registry.
3. Replace any hardcoded colors with theme references.
4. Run flutter analyze.
5. Commit with a descriptive message.

## How to execute each step (Helios conventions)

**1.** Read the stack trace or analyzer diagnostic; open the cited path at the cited line and follow `build()` / callbacks if the failure is upstream.

**2.** Put user-facing strings in `lib/core/content/` (wire through `lib/core/content/content_registry.dart` and existing domain files—no new literals in widgets).

**3.** Prefer `context.colors`; otherwise `Theme.of(context).colorScheme`. No `Color(0xFF…)`, gradients, or shadows that violate brand theming unless already established in shared design code.

**4.** Repo root: `flutter analyze`; resolve new issues before finishing.

**5.** Git commit summarizes the defect, the touchpoints, and the fix; use repo commit-style if one exists.

## Verification

Only mark the task done after `flutter analyze` passes and the git commit includes the substantive fix (not unrelated refactors).

## Scope discipline

Stay on the minimal change set tied to the error: do not refactor unrelated widgets or broaden string/theme cleanups beyond what the failure path touches unless the error demands it.
