import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:nqaae_app/shared/widgets/metric_tile.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card.dart';
import 'dashboard_section_card.dart';

class InstituteInfoItem {
  const InstituteInfoItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

class InstituteSummaryCard extends StatelessWidget {
  const InstituteSummaryCard({
    super.key,
    this.name = 'ANDIJAN STATE PEDAGOGICAL INSTITUTE',
    this.items = defaultItems,
  });

  final String name;
  final List<InstituteInfoItem> items;

  static const defaultItems = [
    InstituteInfoItem(
      value: 'STATE',
      label: 'Mulkchilik',
      icon: Iconsax.teacher,
    ),
    InstituteInfoItem(
      value: 'Navoiy shahar',
      label: 'Hudud',
      icon: Iconsax.location,
    ),
    InstituteInfoItem(
      value: '2021',
      label: 'Tashkil etilgan',
      icon: Iconsax.calendar,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InstituteHeader(name: name),

          const SizedBox(height: 16),

          _InstituteInfoGrid(items: items),
        ],
      ),
    );
  }
}

class _InstituteHeader extends StatelessWidget {
  const _InstituteHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SvgPicture.asset(
            'assets/icons/building.svg',
            width: 30,
            height: 31,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            name,
            style: DashboardTextStyles.text(
              fontSize: 16,
              weight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _InstituteInfoGrid extends StatelessWidget {
  const _InstituteInfoGrid({required this.items});

  final List<InstituteInfoItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(
            child: DashboardMetricTile(
              value: items[index].value,
              label: items[index].label,
              icon: items[index].icon,
              iconPosition: DashboardMetricTileIconPosition.topRight,
              iconSize: 16,
              iconColor: Colors.white.withValues(alpha: 0.44),
              variant: DashboardCardVariant.gradient,
              gradient: AppColors.gradient(style: GradientStyle.linear),
              height: 72,
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              valueFontSize: 11,
              valueWeight: FontWeight.w800,
              valueMaxLines: 3,
              valueLabelGap: 2,
              labelColor: Colors.white.withValues(alpha: 0.8),
              labelWeight: FontWeight.w700,
              reservedTrailingWidth: 0,
            ),
          ),
          if (index != items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}
