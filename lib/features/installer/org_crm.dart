import 'package:blacklight_app/core/content/content_registry.dart';
import 'package:flutter/material.dart';
import '../../theme/blacklight_theme.dart';
import '../../core/models/project.dart';

class OrgCrm extends StatefulWidget {
  final List<Lead> leads;
  final void Function(Lead, LeadStage)? onMoveStage;
  final VoidCallback? onAddLead;

  const OrgCrm({
    super.key,
    required this.leads,
    this.onMoveStage,
    this.onAddLead,
  });

  @override
  State<OrgCrm> createState() => _OrgCrmState();
}

class _OrgCrmState extends State<OrgCrm> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.leads
        .where((l) =>
            _search.isEmpty ||
            l.name.toLowerCase().contains(_search.toLowerCase()) ||
            l.address.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(BlackLightSpacing.gutter),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(OrgCrmBoardContent.webPipelineHeader,
                      style: BlackLightTextStyles.sectionHeading()),
                  Text(OrgCrmBoardContent.webPipelineSubtitle,
                      style: BlackLightTextStyles.body()),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 240,
                height: 44,
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: BlackLightTextStyles.body(
                      color: BlackLightColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: OrgCrmBoardContent.searchLeadsHint,
                    hintStyle: BlackLightTextStyles.body(
                        color: BlackLightColors.textCaption),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: BlackLightColors.textCaption),
                    filled: true,
                    fillColor: BlackLightColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide:
                          const BorderSide(color: BlackLightColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide:
                          const BorderSide(color: BlackLightColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(
                          color: BlackLightColors.accent, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: widget.onAddLead,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(OrgCrmBoardContent.addLeadFab,
                      style: BlackLightTextStyles.caption(color: Colors.white)
                          .copyWith(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BlackLightColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 0),

        // Kanban board
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(BlackLightSpacing.gutter),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: LeadStage.values.map((stage) {
                final stageLeads =
                    filtered.where((l) => l.stage == stage).toList();
                return _KanbanColumn(
                  stage: stage,
                  leads: stageLeads,
                  onMoveTo: (lead, target) =>
                      widget.onMoveStage?.call(lead, target),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final LeadStage stage;
  final List<Lead> leads;
  final void Function(Lead, LeadStage)? onMoveTo;

  const _KanbanColumn({
    required this.stage,
    required this.leads,
    this.onMoveTo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: BlackLightSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ColumnHeader(stage: stage, count: leads.length),
          const SizedBox(height: BlackLightSpacing.sm),
          ...leads.map((l) => _LeadCard(lead: l, onMoveTo: onMoveTo)),
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final LeadStage stage;
  final int count;

  const _ColumnHeader({required this.stage, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: stage.stageColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(stage.label,
            style:
                BlackLightTextStyles.body(color: BlackLightColors.textPrimary)
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: BlackLightColors.background,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style:
                BlackLightTextStyles.caption(color: BlackLightColors.textBody)
                    .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _LeadCard extends StatelessWidget {
  final Lead lead;
  final void Function(Lead, LeadStage)? onMoveTo;

  const _LeadCard({required this.lead, this.onMoveTo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BlackLightSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BlackLightColors.surface,
        borderRadius: BorderRadius.circular(BlackLightRadius.card),
        border: Border.all(color: BlackLightColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(lead.name,
                    style: BlackLightTextStyles.body(
                            color: BlackLightColors.textPrimary)
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 12, color: BlackLightColors.textCaption),
              const SizedBox(width: 4),
              Expanded(
                child: Text(lead.address,
                    style: BlackLightTextStyles.caption(),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          if (lead.systemSizeKw != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.bolt_outlined,
                    size: 12, color: BlackLightColors.textCaption),
                const SizedBox(width: 4),
                Text('${lead.systemSizeKw}${OrgCrmBoardContent.kwSuffix}',
                    style: BlackLightTextStyles.caption()),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(lead.source,
                  style: BlackLightTextStyles.caption(
                          color: BlackLightColors.textCaption)
                      .copyWith(fontSize: 10)),
              const Spacer(),
              // Move left/right
              if (lead.stage.index > 0)
                GestureDetector(
                  onTap: () => onMoveTo?.call(
                      lead, LeadStage.values[lead.stage.index - 1]),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: BlackLightColors.textCaption),
                ),
              if (lead.stage.index < LeadStage.values.length - 1)
                GestureDetector(
                  onTap: () => onMoveTo?.call(
                      lead, LeadStage.values[lead.stage.index + 1]),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: BlackLightColors.textCaption),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
