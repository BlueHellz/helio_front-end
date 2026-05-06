import 'package:flutter/material.dart';

import 'package:kooyoh_app/core/content/content_registry.dart';
import 'package:kooyoh_app/core/ui/app_feedback.dart';
import 'package:kooyoh_app/theme/kooyoh_theme.dart';

/// Authenticated homeowner hub: project summary, staged progress, installers,
/// funding, inspection, documents, and mock messaging.
///
/// Shown from [ProjectTrackingPage] when the homeowner session is active.
class HomeownerDashboardPage extends StatefulWidget {
  const HomeownerDashboardPage({super.key});

  @override
  State<HomeownerDashboardPage> createState() => _HomeownerDashboardPageState();
}

class _InstallerOption {
  const _InstallerOption({
    required this.id,
    required this.name,
    required this.rating,
    required this.years,
    required this.license,
    required this.contact,
  });

  final String id;
  final String name;
  final String rating;
  final String years;
  final String license;
  final String contact;
}

class _FundingOption {
  const _FundingOption({
    required this.id,
    required this.title,
    required this.body,
    required this.rateLine,
    required this.termLine,
    required this.noteLine,
  });

  final String id;
  final String title;
  final String body;
  final String rateLine;
  final String termLine;
  final String noteLine;
}

class _HomeownerDashboardPageState extends State<HomeownerDashboardPage> {
  String? _installerId;
  String? _fundingId;
  String? _inspectionSlotLabel;
  bool _inspectionConfirmedView = false;

  /// 0 design … 3 complete. Mirrors visual progress (permitting baseline).
  int _stageIndex = 1;

  late final List<(String date, String title, String detail)> _timeline;

  static List<_InstallerOption> get _installers => const [
        _InstallerOption(
          id: 'i1',
          name: HomeownerProjectDashboardContent.installer1Name,
          rating: HomeownerProjectDashboardContent.installer1Rating,
          years: HomeownerProjectDashboardContent.installer1Years,
          license: HomeownerProjectDashboardContent.installer1License,
          contact: HomeownerProjectDashboardContent.installer1Contact,
        ),
        _InstallerOption(
          id: 'i2',
          name: HomeownerProjectDashboardContent.installer2Name,
          rating: HomeownerProjectDashboardContent.installer2Rating,
          years: HomeownerProjectDashboardContent.installer2Years,
          license: HomeownerProjectDashboardContent.installer2License,
          contact: HomeownerProjectDashboardContent.installer2Contact,
        ),
        _InstallerOption(
          id: 'i3',
          name: HomeownerProjectDashboardContent.installer3Name,
          rating: HomeownerProjectDashboardContent.installer3Rating,
          years: HomeownerProjectDashboardContent.installer3Years,
          license: HomeownerProjectDashboardContent.installer3License,
          contact: HomeownerProjectDashboardContent.installer3Contact,
        ),
      ];

  static List<_FundingOption> get _fundingOptions => const [
        _FundingOption(
          id: 'pool',
          title: HomeownerProjectDashboardContent.fundingPoolTitle,
          body: HomeownerProjectDashboardContent.fundingPoolBody,
          rateLine: HomeownerProjectDashboardContent.fundingPoolRate,
          termLine: HomeownerProjectDashboardContent.fundingPoolTerm,
          noteLine: HomeownerProjectDashboardContent.fundingPoolNote,
        ),
        _FundingOption(
          id: 'green',
          title: HomeownerProjectDashboardContent.fundingGreenTitle,
          body: HomeownerProjectDashboardContent.fundingGreenBody,
          rateLine: HomeownerProjectDashboardContent.fundingGreenRate,
          termLine: HomeownerProjectDashboardContent.fundingGreenTerm,
          noteLine: HomeownerProjectDashboardContent.fundingGreenNote,
        ),
      ];

  bool get _installerReady => _installerId != null;

  String get _statusLine {
    if (_inspectionSlotLabel != null) {
      return HomeownerProjectDashboardContent.statusInstallationScheduled;
    }
    return HomeownerProjectDashboardContent.statusAwaitingPermit;
  }

  @override
  void initState() {
    super.initState();
    _timeline = [
      (
        HomeownerProjectDashboardContent.dateTimelineDesign,
        HomeownerProjectDashboardContent.timelineDesignComplete,
        HomeownerProjectDashboardContent.timelineDesignCompleteDetail,
      ),
      (
        HomeownerProjectDashboardContent.dateTimelinePermit,
        HomeownerProjectDashboardContent.timelinePermitFiled,
        HomeownerProjectDashboardContent.timelinePermitFiledDetail,
      ),
    ];
  }

  void _pickInstaller(String id) {
    if (_installerId == id) return;
    final opt = _installers.firstWhere((e) => e.id == id);
    setState(() {
      _installerId = id;
      _timeline.add((
        HomeownerProjectDashboardContent.dateRecentAction,
        '${HomeownerProjectDashboardContent.timelineInstallerPrefix}${opt.name}',
        '',
      ));
    });
  }

  void _pickFunding(String id) {
    if (_fundingId == id) return;
    final opt = _fundingOptions.firstWhere((e) => e.id == id);
    setState(() {
      _fundingId = id;
      _timeline.add((
        HomeownerProjectDashboardContent.dateRecentAction,
        '${HomeownerProjectDashboardContent.timelineFundingPrefix}${opt.title}',
        '',
      ));
    });
  }

  void _pickSlot(String slot) {
    setState(() {
      _timeline.removeWhere(
        (e) => e.$2.startsWith(HomeownerProjectDashboardContent.timelineInspectionPrefix),
      );
      _inspectionSlotLabel = slot;
      _inspectionConfirmedView = false;
      _stageIndex = 2;
      _timeline.add((
        HomeownerProjectDashboardContent.dateRecentAction,
        '${HomeownerProjectDashboardContent.timelineInspectionPrefix}$slot',
        '',
      ));
    });
  }

  void _confirmInspectionUi() {
    setState(() {
      _inspectionConfirmedView = true;
    });
  }

  void _mockDownload(BuildContext context) {
    AppFeedback.snack(context, HomeownerProjectDashboardContent.snackDownloadDemo);
  }

  void _showContractDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          HomeownerProjectDashboardContent.contractDialogTitle,
          style: KooyohTextStyles.cardHeading(),
        ),
        content: Text(
          HomeownerProjectDashboardContent.contractMockBody,
          style: KooyohTextStyles.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              ButtonsContent.close,
              style: KooyohTextStyles.bodyBold(color: KooyohColors.accent),
            ),
          ),
        ],
      ),
    );
    AppFeedback.snack(context, HomeownerProjectDashboardContent.snackContractDemo);
  }

  void _openMessagingSheet(BuildContext context) {
    final useInstallerCopy = _installerReady;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: KooyohColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KooyohRadius.card)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.65,
            minChildSize: 0.45,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return _MessagingSheet(
                scrollController: scrollController,
                title: useInstallerCopy
                    ? HomeownerProjectDashboardContent.messageInstallerCta
                    : HomeownerProjectDashboardContent.messageInspectorCta,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(KooyohSpacing.gutter),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                HomeownerProjectDashboardContent.pageTitle,
                style: KooyohTextStyles.sectionHeading(),
              ),
              const SizedBox(height: KooyohSpacing.xs),
              Text(
                HomeownerProjectDashboardContent.headerSubtitle,
                style: KooyohTextStyles.body(),
              ),
              const SizedBox(height: KooyohSpacing.md),
              _ProjectOverviewCard(
                address: HomeownerProjectDashboardContent.mockProjectAddress,
                systemSize: HomeownerProjectDashboardContent.mockSystemSize,
                status: _statusLine,
              ),
              const SizedBox(height: KooyohSpacing.md),
              _StageProgressBar(currentIndex: _stageIndex),
              const SizedBox(height: KooyohSpacing.lg),
              _SectionCard(
                title: HomeownerProjectDashboardContent.sectionInstallers,
                child: Column(
                  children: _installers
                      .map(
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: KooyohSpacing.sm),
                          child: _InstallerCard(
                            option: i,
                            selected: _installerId == i.id,
                            onSelect: () => _pickInstaller(i.id),
                            onViewContract: _installerReady && _installerId == i.id
                                ? () => _showContractDialog(context)
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              _SectionCard(
                title: HomeownerProjectDashboardContent.sectionFunding,
                child: Column(
                  children: _fundingOptions
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: KooyohSpacing.sm),
                          child: _FundingCard(
                            option: f,
                            selected: _fundingId == f.id,
                            onSelect: () => _pickFunding(f.id),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              _SectionCard(
                title: HomeownerProjectDashboardContent.sectionInspection,
                child: _InspectionBlock(
                  slotLabel: _inspectionSlotLabel,
                  showConfirmation: _inspectionConfirmedView,
                  onPickSlot: _pickSlot,
                  onConfirmUi: _confirmInspectionUi,
                ),
              ),
              _SectionCard(
                title: HomeownerProjectDashboardContent.sectionTimeline,
                child: Column(
                  children: _timeline
                      .map(
                        (e) => _TimelineRow(
                          date: e.$1,
                          title: e.$2,
                          detail: e.$3,
                        ),
                      )
                      .toList(),
                ),
              ),
              _SectionCard(
                title: HomeownerProjectDashboardContent.sectionDocuments,
                child: Column(
                  children: [
                    _DocumentRow(
                      title: HomeownerProjectDashboardContent.docPermitTitle,
                      subtitle: HomeownerProjectDashboardContent.docPermitSubtitle,
                      enabled: true,
                      onDownload: () => _mockDownload(context),
                    ),
                    const Divider(height: KooyohSpacing.md),
                    _DocumentRow(
                      title: HomeownerProjectDashboardContent.docContractTitle,
                      subtitle: _installerReady
                          ? HomeownerProjectDashboardContent.docContractSubtitleReady
                          : HomeownerProjectDashboardContent.docContractSubtitlePending,
                      enabled: _installerReady,
                      onDownload: () => _mockDownload(context),
                    ),
                    const Divider(height: KooyohSpacing.md),
                    _DocumentRow(
                      title: HomeownerProjectDashboardContent.docInspectionTitle,
                      subtitle: _inspectionSlotLabel != null
                          ? HomeownerProjectDashboardContent.docInspectionSubtitleReady
                          : HomeownerProjectDashboardContent.docInspectionSubtitlePending,
                      enabled: _inspectionSlotLabel != null,
                      onDownload: () => _mockDownload(context),
                    ),
                  ],
                ),
              ),
              _SectionCard(
                title: HomeownerProjectDashboardContent.sectionCommunication,
                child: OutlinedButton.icon(
                  onPressed: () => _openMessagingSheet(context),
                  icon: const Icon(Icons.chat_bubble_outline, color: KooyohColors.accent),
                  label: Text(
                    _installerReady
                        ? HomeownerProjectDashboardContent.messageInstallerCta
                        : HomeownerProjectDashboardContent.messageInspectorCta,
                    style: KooyohTextStyles.bodyBold(color: KooyohColors.accent),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(KooyohSpacing.buttonHeight),
                    side: const BorderSide(color: KooyohColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KooyohRadius.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KooyohSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectOverviewCard extends StatelessWidget {
  const _ProjectOverviewCard({
    required this.address,
    required this.systemSize,
    required this.status,
  });

  final String address;
  final String systemSize;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KooyohSpacing.cardPadding),
      decoration: BoxDecoration(
        color: KooyohColors.surface,
        borderRadius: BorderRadius.circular(KooyohRadius.card),
        border: Border.all(color: KooyohColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 560;
          final row = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _KVBlock(
                  label: HomeownerProjectDashboardContent.labelAddress,
                  value: address,
                ),
              ),
              SizedBox(width: wide ? KooyohSpacing.md : 0),
              Expanded(
                child: _KVBlock(
                  label: HomeownerProjectDashboardContent.labelSystemSize,
                  value: systemSize,
                ),
              ),
            ],
          );
          final statusBlock = _KVBlock(
            label: HomeownerProjectDashboardContent.labelProjectStatus,
            value: status,
            emphasize: true,
          );
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: row),
                SizedBox(width: KooyohSpacing.md),
                Expanded(child: statusBlock),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _KVBlock(
                label: HomeownerProjectDashboardContent.labelAddress,
                value: address,
              ),
              const SizedBox(height: KooyohSpacing.sm),
              _KVBlock(
                label: HomeownerProjectDashboardContent.labelSystemSize,
                value: systemSize,
              ),
              const SizedBox(height: KooyohSpacing.sm),
              statusBlock,
            ],
          );
        },
      ),
    );
  }
}

class _KVBlock extends StatelessWidget {
  const _KVBlock({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: KooyohTextStyles.captionBold().copyWith(fontSize: 10),
        ),
        const SizedBox(height: KooyohSpacing.xs),
        Text(
          value,
          style: emphasize
              ? KooyohTextStyles.bodyBold()
              : KooyohTextStyles.body(),
        ),
      ],
    );
  }
}

class _StageProgressBar extends StatelessWidget {
  const _StageProgressBar({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    const labels = [
      HomeownerProjectDashboardContent.stageDesign,
      HomeownerProjectDashboardContent.stagePermitting,
      HomeownerProjectDashboardContent.stageInstallation,
      HomeownerProjectDashboardContent.stageComplete,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KooyohSpacing.md,
        vertical: KooyohSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: KooyohColors.surfaceMuted,
        borderRadius: BorderRadius.circular(KooyohRadius.card),
        border: Border.all(color: KooyohColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(labels.length * 2 - 1, (i) {
              if (i.isOdd) {
                final leftDone = currentIndex > i ~/ 2;
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 28),
                    color: leftDone ? KooyohColors.green : KooyohColors.border,
                  ),
                );
              }
              final stage = i ~/ 2;
              final done = currentIndex > stage;
              final active = currentIndex == stage;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? KooyohColors.green
                            : active
                                ? KooyohColors.accent
                                : KooyohColors.surface,
                        border: Border.all(
                          color: active || done
                              ? (done ? KooyohColors.green : KooyohColors.accent)
                              : KooyohColors.border,
                          width: 2,
                        ),
                      ),
                      child: done
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: KooyohSpacing.xs),
                    Text(
                      labels[stage],
                      textAlign: TextAlign.center,
                      style: KooyohTextStyles.caption(
                        color: active
                            ? KooyohColors.textPrimary
                            : KooyohColors.textCaption,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KooyohSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(KooyohSpacing.cardPadding),
        decoration: BoxDecoration(
          color: KooyohColors.surface,
          borderRadius: BorderRadius.circular(KooyohRadius.card),
          border: Border.all(color: KooyohColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: KooyohTextStyles.cardHeading()),
            const SizedBox(height: KooyohSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _InstallerCard extends StatelessWidget {
  const _InstallerCard({
    required this.option,
    required this.selected,
    required this.onSelect,
    this.onViewContract,
  });

  final _InstallerOption option;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback? onViewContract;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(KooyohSpacing.md),
      decoration: BoxDecoration(
        color: selected ? KooyohColors.sidebarActiveBg : KooyohColors.surfaceMuted,
        borderRadius: BorderRadius.circular(KooyohRadius.md),
        border: Border.all(
          color: selected ? KooyohColors.accent : KooyohColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(option.name, style: KooyohTextStyles.cardHeading()),
              ),
              if (selected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: KooyohColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(KooyohRadius.chip),
                    border: Border.all(color: KooyohColors.green.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    HomeownerProjectDashboardContent.selectedBadge,
                    style: KooyohTextStyles.captionBold(color: KooyohColors.green),
                  ),
                ),
            ],
          ),
          const SizedBox(height: KooyohSpacing.sm),
          Text(
            '${HomeownerProjectDashboardContent.ratingLabel}: ${option.rating}',
            style: KooyohTextStyles.body(),
          ),
          const SizedBox(height: KooyohSpacing.xs),
          Text(
            '${HomeownerProjectDashboardContent.yearsInBusinessLabel}: ${option.years}',
            style: KooyohTextStyles.body(),
          ),
          const SizedBox(height: KooyohSpacing.xs),
          Text(
            '${HomeownerProjectDashboardContent.licenseLabel}: ${option.license}',
            style: KooyohTextStyles.dataInline(),
          ),
          const SizedBox(height: KooyohSpacing.xs),
          Text(
            '${HomeownerProjectDashboardContent.contactLabel}: ${option.contact}',
            style: KooyohTextStyles.dataInline(),
          ),
          const SizedBox(height: KooyohSpacing.sm),
          Wrap(
            spacing: KooyohSpacing.sm,
            runSpacing: KooyohSpacing.xs,
            children: [
              SizedBox(
                height: KooyohSpacing.tapTarget,
                child: ElevatedButton(
                  onPressed: onSelect,
                  child: Text(
                    HomeownerProjectDashboardContent.selectCta,
                    style: KooyohTextStyles.bodyBold(color: Colors.white),
                  ),
                ),
              ),
              if (onViewContract != null)
                SizedBox(
                  height: KooyohSpacing.tapTarget,
                  child: OutlinedButton(
                    onPressed: onViewContract,
                    child: Text(
                      HomeownerProjectDashboardContent.viewContractCta,
                      style: KooyohTextStyles.bodyBold(color: KooyohColors.accent),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FundingCard extends StatelessWidget {
  const _FundingCard({
    required this.option,
    required this.selected,
    required this.onSelect,
  });

  final _FundingOption option;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(KooyohSpacing.md),
      decoration: BoxDecoration(
        color: selected ? KooyohColors.sidebarActiveBg : KooyohColors.surfaceMuted,
        borderRadius: BorderRadius.circular(KooyohRadius.md),
        border: Border.all(
          color: selected ? KooyohColors.accent : KooyohColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(option.title, style: KooyohTextStyles.cardHeading())),
              if (selected)
                Text(
                  HomeownerProjectDashboardContent.selectedBadge,
                  style: KooyohTextStyles.captionBold(color: KooyohColors.accent),
                ),
            ],
          ),
          const SizedBox(height: KooyohSpacing.sm),
          Text(option.body, style: KooyohTextStyles.body()),
          const SizedBox(height: KooyohSpacing.sm),
          Text(option.rateLine, style: KooyohTextStyles.dataInline()),
          const SizedBox(height: KooyohSpacing.xs),
          Text(option.termLine, style: KooyohTextStyles.dataInline()),
          const SizedBox(height: KooyohSpacing.xs),
          Text(option.noteLine, style: KooyohTextStyles.caption()),
          const SizedBox(height: KooyohSpacing.sm),
          SizedBox(
            height: KooyohSpacing.tapTarget,
            child: ElevatedButton(
              onPressed: onSelect,
              child: Text(
                HomeownerProjectDashboardContent.selectCta,
                style: KooyohTextStyles.bodyBold(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspectionBlock extends StatelessWidget {
  const _InspectionBlock({
    required this.slotLabel,
    required this.showConfirmation,
    required this.onPickSlot,
    required this.onConfirmUi,
  });

  final String? slotLabel;
  final bool showConfirmation;
  final ValueChanged<String> onPickSlot;
  final VoidCallback onConfirmUi;

  static const _slots = [
    HomeownerProjectDashboardContent.inspectionSlot1,
    HomeownerProjectDashboardContent.inspectionSlot2,
    HomeownerProjectDashboardContent.inspectionSlot3,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HomeownerProjectDashboardContent.inspectionIntro,
          style: KooyohTextStyles.body(),
        ),
        const SizedBox(height: KooyohSpacing.sm),
        ..._slots.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: KooyohSpacing.sm),
            child: Material(
              color: KooyohColors.surfaceMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KooyohRadius.md),
                side: const BorderSide(color: KooyohColors.border),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(KooyohRadius.md),
                onTap: () => onPickSlot(s),
                child: Padding(
                  padding: const EdgeInsets.all(KooyohSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        slotLabel == s ? Icons.event_available : Icons.event_outlined,
                        color:
                            slotLabel == s ? KooyohColors.accent : KooyohColors.textCaption,
                      ),
                      const SizedBox(width: KooyohSpacing.sm),
                      Expanded(
                        child: Text(s, style: KooyohTextStyles.bodyBold()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (slotLabel != null) ...[
          const SizedBox(height: KooyohSpacing.sm),
          Text(
            slotLabel!,
            style: KooyohTextStyles.dataLarge(color: KooyohColors.accent),
          ),
          const SizedBox(height: KooyohSpacing.sm),
          if (!showConfirmation)
            SizedBox(
              height: KooyohSpacing.tapTarget,
              child: ElevatedButton(
                onPressed: onConfirmUi,
                child: Text(
                  ButtonsContent.confirm,
                  style: KooyohTextStyles.bodyBold(color: Colors.white),
                ),
              ),
            ),
          if (showConfirmation) ...[
            const SizedBox(height: KooyohSpacing.sm),
            Container(
              padding: const EdgeInsets.all(KooyohSpacing.md),
              decoration: BoxDecoration(
                color: KooyohColors.sidebarActiveBg,
                borderRadius: BorderRadius.circular(KooyohRadius.md),
                border: Border.all(color: KooyohColors.accent.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    HomeownerProjectDashboardContent.inspectionConfirmedTitle,
                    style: KooyohTextStyles.bodyBold(),
                  ),
                  const SizedBox(height: KooyohSpacing.xs),
                  Text(
                    HomeownerProjectDashboardContent.inspectionConfirmedBody,
                    style: KooyohTextStyles.body(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.date,
    required this.title,
    required this.detail,
  });

  final String date;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KooyohSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(date, style: KooyohTextStyles.captionBold()),
          ),
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4, right: KooyohSpacing.sm),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: KooyohColors.accent,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: KooyohTextStyles.bodyBold()),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: KooyohSpacing.xs),
                  Text(detail, style: KooyohTextStyles.body()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onDownload,
  });

  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.description_outlined,
          color: enabled ? KooyohColors.accent : KooyohColors.textCaption,
        ),
        const SizedBox(width: KooyohSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: KooyohTextStyles.bodyBold()),
              const SizedBox(height: KooyohSpacing.xs),
              Text(subtitle, style: KooyohTextStyles.caption()),
            ],
          ),
        ),
        TextButton(
          onPressed: enabled ? onDownload : null,
          child: Text(
            HomeownerProjectDashboardContent.downloadCta,
            style: KooyohTextStyles.bodyBold(
              color: enabled ? KooyohColors.accent : KooyohColors.textCaption,
            ),
          ),
        ),
      ],
    );
  }
}

class _MessagingSheet extends StatefulWidget {
  const _MessagingSheet({
    required this.scrollController,
    required this.title,
  });

  final ScrollController scrollController;
  final String title;

  @override
  State<_MessagingSheet> createState() => _MessagingSheetState();
}

class _MessagingSheetState extends State<_MessagingSheet> {
  final _controller = TextEditingController();
  final List<_ChatLine> _lines = [
    _ChatLine(
      fromSelf: false,
      text: HomeownerProjectDashboardContent.chatDummyFromInstaller,
    ),
    _ChatLine(
      fromSelf: true,
      text: HomeownerProjectDashboardContent.chatDummyFromYou,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _lines.add(_ChatLine(fromSelf: true, text: t));
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: KooyohSpacing.sm),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: KooyohColors.border,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KooyohSpacing.md,
            KooyohSpacing.md,
            KooyohSpacing.md,
            KooyohSpacing.sm,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                color: KooyohColors.textBody,
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: KooyohTextStyles.cardHeading(),
                ),
              ),
              const SizedBox(width: KooyohSpacing.md),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: KooyohSpacing.md),
            itemCount: _lines.length,
            itemBuilder: (context, i) {
              final m = _lines[i];
              return _ChatBubble(fromSelf: m.fromSelf, text: m.text);
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.fromLTRB(
            KooyohSpacing.sm,
            KooyohSpacing.sm,
            KooyohSpacing.sm,
            KooyohSpacing.sm + MediaQuery.paddingOf(context).bottom,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: HomeownerProjectDashboardContent.chatComposerHint,
                    filled: true,
                    fillColor: KooyohColors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KooyohRadius.input),
                      borderSide: const BorderSide(color: KooyohColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KooyohRadius.input),
                      borderSide: const BorderSide(color: KooyohColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KooyohRadius.input),
                      borderSide: const BorderSide(color: KooyohColors.accent),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: KooyohSpacing.sm,
                      vertical: KooyohSpacing.sm,
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: KooyohSpacing.sm),
              SizedBox(
                height: KooyohSpacing.tapTarget,
                child: ElevatedButton(
                  onPressed: _send,
                  child: Text(
                    HomeownerProjectDashboardContent.sendCta,
                    style: KooyohTextStyles.bodyBold(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatLine {
  const _ChatLine({required this.fromSelf, required this.text});
  final bool fromSelf;
  final String text;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.fromSelf, required this.text});

  final bool fromSelf;
  final String text;

  @override
  Widget build(BuildContext context) {
    final bg = fromSelf ? KooyohColors.accent : KooyohColors.surfaceMuted;
    final fg = fromSelf ? Colors.white : KooyohColors.textPrimary;
    return Align(
      alignment: fromSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: KooyohSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: KooyohSpacing.sm,
          vertical: KooyohSpacing.sm,
        ),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(KooyohRadius.md).copyWith(
            bottomRight: fromSelf ? const Radius.circular(4) : null,
            bottomLeft: !fromSelf ? const Radius.circular(4) : null,
          ),
        ),
        child: Text(text, style: KooyohTextStyles.body(color: fg)),
      ),
    );
  }
}
