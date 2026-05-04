import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';

import 'catalog_provider.dart';

/// Default surface id for LIMYÈ GenUI payloads from `/ai/configure` etc.
const String kLimyeGenUiSurfaceId = 'limye-main';

/// Queued A2UI v0.9 messages (JSON objects serialized as strings).
class GeneratedUiQueue extends StateNotifier<List<String>> {
  GeneratedUiQueue() : super(const []);

  void enqueue(String jsonLine) => state = [...state, jsonLine];

  void enqueueMap(Map<String, dynamic> message) =>
      enqueue(jsonEncode(message));

  void clear() => state = const [];
}

final generatedUiProvider =
    StateNotifierProvider<GeneratedUiQueue, List<String>>((ref) {
  return GeneratedUiQueue();
});

void ingestConfigureResponseIntoGenUi(WidgetRef ref, dynamic res) {
  if (res is! Map) return;
  final m = Map<String, dynamic>.from(res);
  final raw = m['a2ui_messages'] ?? m['messages'] ?? m['a2ui'];
  final q = ref.read(generatedUiProvider.notifier);
  if (raw is List) {
    for (final item in raw) {
      if (item is String) {
        q.enqueue(item);
      } else if (item is Map) {
        q.enqueueMap(Map<String, dynamic>.from(item));
      }
    }
    return;
  }
  final single = m['a2ui_json'];
  if (single is String) {
    q.enqueue(single);
  }
}

/// Wraps authenticated shell: shows [GenUiSurface] when A2UI has begun rendering.
class LimyeGenUiShell extends ConsumerStatefulWidget {
  const LimyeGenUiShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LimyeGenUiShell> createState() => _LimyeGenUiShellState();
}

class _LimyeGenUiShellState extends ConsumerState<LimyeGenUiShell> {
  A2uiMessageProcessor? _processor;

  @override
  void dispose() {
    _processor?.dispose();
    super.dispose();
  }

  void _drainQueue(List<String>? previous, List<String> next) {
    if (next.isEmpty) return;
    final cat = ref.read(limyeGenUiCatalogProvider).valueOrNull;
    if (cat == null) return;
    _processor ??= A2uiMessageProcessor(catalogs: [cat]);
    final p = _processor!;
    for (final line in next) {
      try {
        final map = jsonDecode(line) as Map<String, dynamic>;
        p.handleMessage(A2uiMessage.fromJson(map));
      } catch (_) {
        /* ignore malformed lines */
      }
    }
    Future.microtask(() {
      if (mounted) {
        ref.read(generatedUiProvider.notifier).clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(generatedUiProvider, _drainQueue);

    final asyncCatalog = ref.watch(limyeGenUiCatalogProvider);

    return asyncCatalog.when(
      data: (catalog) {
        _processor ??= A2uiMessageProcessor(catalogs: [catalog]);
        final notifier = _processor!.getSurfaceNotifier(kLimyeGenUiSurfaceId);
        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            ListenableBuilder(
              listenable: notifier,
              builder: (context, child) {
                final def = notifier.value;
                if (def?.rootComponentId == null) {
                  return const SizedBox.shrink();
                }
                final w = MediaQuery.sizeOf(context).width;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    elevation: 12,
                    color: Theme.of(context).colorScheme.surface,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Theme(
                      data: Theme.of(context),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          height: 320,
                          width: w > 960 ? 960 : w,
                          child: GenUiSurface(
                            host: _processor!,
                            surfaceId: kLimyeGenUiSurfaceId,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => widget.child,
      error: (_, __) => widget.child,
    );
  }
}
