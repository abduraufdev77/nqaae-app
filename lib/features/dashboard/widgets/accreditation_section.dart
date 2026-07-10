import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nqaae_app/shared/widgets/metric_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card.dart';
import '../../../shared/widgets/cupertino_liquid_pressable.dart';
import 'dashboard_section_card.dart';

enum AccreditationStatus { pending, completed }

enum AccreditationType {
  complexStateAccreditation,
  specialStateAccreditation,
  internationalAccreditation,
}

class AccreditationStep {
  const AccreditationStep({required this.label, required this.value});

  final String label;
  final String value;
}

class AccreditationItem {
  const AccreditationItem({
    required this.type,
    required this.status,
    this.pendingSteps = const [],
    this.certificateNumber,
    this.givenDate,
    this.validUntil,
    this.accreditedProgramsCount = '0',
    this.statusText,
    this.certificateUrl,
    this.onCertificateDownload,
  });

  final AccreditationType type;
  final AccreditationStatus status;

  /// Used when status is pending.
  final List<AccreditationStep> pendingSteps;

  /// Used when status is completed.
  final String? certificateNumber;
  final String? givenDate;
  final String? validUntil;
  final String accreditedProgramsCount;
  final String? statusText;
  final String? certificateUrl;
  final VoidCallback? onCertificateDownload;
}

class AccreditationSection extends StatelessWidget {
  const AccreditationSection({
    super.key,
    this.title = 'Akkreditatsiya',
    this.items = defaultItems,
  });

  static const defaultItems = [
    AccreditationItem(
      type: AccreditationType.complexStateAccreditation,
      status: AccreditationStatus.pending,
      pendingSteps: [
        AccreditationStep(label: 'Holati:', value: 'Jarayonda'),
        AccreditationStep(label: 'Oxirgi tekshiruv:', value: '06.04.2021'),
        AccreditationStep(
          label: 'Ichki baholash tugash muddati:',
          value: '13.08.2026',
        ),
        AccreditationStep(
          label: 'Ekspertlar tomonidan hujjatlarni onlayn o‘rganish muddati:',
          value: '05.09.2026',
        ),
        AccreditationStep(
          label: 'Joyiga chiqish muddati boshlanishi*:',
          value: '12.10.2026',
        ),
        AccreditationStep(
          label: 'Joyiga chiqish muddati tugashi*:',
          value: '22.10.2026',
        ),
        AccreditationStep(
          label: 'Yakuniy xulosa tayyorlash muddati:',
          value: '12.11.2026',
        ),
        AccreditationStep(
          label: 'Akkreditatsiya komissiyasi qarori oxirgi muddati:',
          value: '12.12.2026',
        ),
      ],
    ),
    AccreditationItem(
      type: AccreditationType.specialStateAccreditation,
      status: AccreditationStatus.pending,
      accreditedProgramsCount: '0',
    ),
    AccreditationItem(
      type: AccreditationType.internationalAccreditation,
      status: AccreditationStatus.pending,
      accreditedProgramsCount: '0',
    ),
  ];

  final String title;
  final List<AccreditationItem> items;

  @override
  Widget build(BuildContext context) {
    return _AccreditationAccordionGroup(title: title, items: items);
  }
}

class _AccreditationAccordionGroup extends StatefulWidget {
  const _AccreditationAccordionGroup({
    required this.title,
    required this.items,
  });

  final String title;
  final List<AccreditationItem> items;

  @override
  State<_AccreditationAccordionGroup> createState() =>
      _AccreditationAccordionGroupState();
}

class _AccreditationAccordionGroupState
    extends State<_AccreditationAccordionGroup> {
  late final Set<AccreditationType> _openedTypes = {
    AccreditationType.complexStateAccreditation,
  };

  void _toggle(AccreditationType type) {
    setState(() {
      if (_openedTypes.contains(type)) {
        _openedTypes.remove(type);
      } else {
        _openedTypes.add(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(title: widget.title),
        const SizedBox(height: 18),
        for (var index = 0; index < widget.items.length; index++) ...[
          _AccreditationAccordionCard(
            item: widget.items[index],
            isOpen: _openedTypes.contains(widget.items[index].type),
            onToggle: () => _toggle(widget.items[index].type),
          ),
          if (index != widget.items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _AccreditationAccordionCard extends StatelessWidget {
  const _AccreditationAccordionCard({
    required this.item,
    required this.isOpen,
    required this.onToggle,
  });

  final AccreditationItem item;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      variant: DashboardCardVariant.flat,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          CupertinoListTile(
            padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
            title: Text(
              item.type.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: DashboardTextStyles.text(
                fontSize: 15,
                weight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            trailing: _AccordionChevron(isOpen: isOpen, onTap: onToggle),
            onTap: onToggle,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 2, 18, 20),
              child: _AccreditationContent(item: item),
            ),
            crossFadeState: isOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 240),
            reverseDuration: const Duration(milliseconds: 180),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class _AccordionChevron extends StatelessWidget {
  const _AccordionChevron({required this.isOpen, required this.onTap});

  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoLiquidPressable(
      onTap: onTap,
      scale: 0.94,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: AnimatedRotation(
          turns: isOpen ? 0.25 : 0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Icon(
            CupertinoIcons.chevron_right,
            color: Colors.white.withValues(alpha: 0.88),
            size: 16,
          ),
        ),
      ),
    );
  }
}

class _AccreditationContent extends StatelessWidget {
  const _AccreditationContent({required this.item});

  final AccreditationItem item;

  @override
  Widget build(BuildContext context) {
    if (item.type != AccreditationType.complexStateAccreditation) {
      return DashboardMetricTile(
        value: item.accreditedProgramsCount,
        label: 'Jami akkreditatsiyadan o‘tgan dasturlar',
        variant: DashboardCardVariant.solid,
        color: Colors.white.withValues(alpha: 0.055),
        height: 80,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        valueFontSize: 20,
        valueWeight: FontWeight.w800,
        labelFontSize: 11,
        labelWeight: FontWeight.w600,
        labelMaxLines: 2,
      );
    }

    if (item.status == AccreditationStatus.completed) {
      return _CompletedAccreditationContent(item: item);
    }

    return _PendingAccreditationTimeline(steps: item.pendingSteps);
  }
}

class _PendingAccreditationTimeline extends StatelessWidget {
  const _PendingAccreditationTimeline({required this.steps});

  final List<AccreditationStep> steps;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 17,
          top: 16,
          bottom: 16,
          child: Container(
            width: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        Column(
          children: [
            for (var index = 0; index < steps.length; index++) ...[
              _TimelineStepTile(
                step: steps[index],
                isFirst: index == 0,
                isCompleted: false,
              ),
              if (index != steps.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _CompletedAccreditationContent extends StatelessWidget {
  const _CompletedAccreditationContent({required this.item});

  final AccreditationItem item;

  @override
  Widget build(BuildContext context) {
    final steps = [
      AccreditationStep(
        label: 'Holati:',
        value: item.statusText ?? "Akkreditatsiyadan o'tgan",
      ),
      AccreditationStep(
        label: 'Sertifikat raqami:',
        value: item.certificateNumber ?? '—',
      ),
      AccreditationStep(label: 'Berilgan sana:', value: item.givenDate ?? '—'),
      AccreditationStep(
        label: 'Amal qilish muddati:',
        value: item.validUntil ?? '—',
      ),
    ];

    return Column(
      children: [
        Stack(
          children: [
            Positioned(
              left: 17,
              top: 16,
              bottom: 16,
              child: Container(
                width: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Column(
              children: [
                for (var index = 0; index < steps.length; index++) ...[
                  _TimelineStepTile(
                    step: steps[index],
                    isFirst: index == 0,
                    isCompleted: true,
                  ),
                  if (index != steps.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        _CertificateDownloadButton(
          onPressed:
              item.onCertificateDownload ??
              (item.certificateUrl == null
                  ? null
                  : () => launchUrl(
                      Uri.parse(item.certificateUrl!),
                      mode: LaunchMode.externalApplication,
                    )),
        ),
      ],
    );
  }
}

class _TimelineStepTile extends StatelessWidget {
  const _TimelineStepTile({
    required this.step,
    required this.isFirst,
    required this.isCompleted,
  });

  final AccreditationStep step;
  final bool isFirst;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final iconColor = isFirst
        ? isCompleted
              ? const Color(0xFF23C991)
              : const Color(0xFFE99A12)
        : Colors.white.withValues(alpha: 0.08);

    final icon = isFirst
        ? isCompleted
              ? CupertinoIcons.check_mark
              : CupertinoIcons.clock
        : CupertinoIcons.calendar;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: isFirst ? 17 : 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DashboardCard(
            variant: DashboardCardVariant.solid,
            color: Colors.white.withValues(alpha: 0.055),
            height: 64,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  step.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DashboardTextStyles.text(
                    fontSize: 11,
                    weight: FontWeight.w600,
                    height: 1.12,
                    color: Colors.white.withValues(alpha: 0.62),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DashboardTextStyles.text(
                    fontSize: 14,
                    weight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CertificateDownloadButton extends StatelessWidget {
  const _CertificateDownloadButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoLiquidPressable(
      onTap: onPressed ?? () {},
      scale: 0.98,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.gradient(style: GradientStyle.linear),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Sertifikatni yuklab olish',
            style: DashboardTextStyles.text(
              fontSize: 14,
              weight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

extension _AccreditationTypeX on AccreditationType {
  String get title {
    switch (this) {
      case AccreditationType.complexStateAccreditation:
        return 'Kompleks davlat akkreditatsiya holati';
      case AccreditationType.specialStateAccreditation:
        return 'Maxsus davlat akkreditatsiyasi';
      case AccreditationType.internationalAccreditation:
        return 'Xalqaro akkreditatsiya';
    }
  }
}
