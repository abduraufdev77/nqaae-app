import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:nqaae_app/core/constants/app_design.dart';
import 'package:nqaae_app/shared/widgets/metric_tile.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card.dart';
import 'charts/distribution_by_programs_chart.dart';
import 'dashboard_section_card.dart';

class SpecializationItem {
  const SpecializationItem({
    required this.color,
    required this.icon,
    required this.eyebrow,
    required this.title,
    this.gradient,
    this.onTap,
  });

  final Color color;
  final Gradient? gradient;
  final IconData icon;
  final String eyebrow;
  final String title;
  final VoidCallback? onTap;
}

class SpecializationSection extends StatelessWidget {
  const SpecializationSection({
    super.key,
    this.title = 'Ixtisoslashuv',
    this.date = '28.02.2026',
    this.items = defaultItems,
    this.chartCardTitle = 'Taʼlim yo\'nalishlari tarkibi',
    this.showChartButton = false,
    this.onChartTap,
    this.chart = const DistributionByProgramsChart(
      size: 220,
      gapWidth: 4,
      cornerRadius: 10,
      centerCornerRadius: 45,
    ),
  });

  static const defaultItems = [
    SpecializationItem(
      color: AppColors.accent,
      icon: Iconsax.building,
      eyebrow: 'OTT toifasi',
      title: 'Ijtimoiy-gumanitar fanlar',
    ),
    SpecializationItem(
      color: AppColors.primary,
      icon: Iconsax.book,
      eyebrow: 'Ustuvor yo’nalishlar',
      title: 'Boshlang‘ich ta’lim',
    ),
  ];

  final String title;
  final String date;
  final List<SpecializationItem> items;

  final String chartCardTitle;
  final bool showChartButton;
  final VoidCallback? onChartTap;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(title: title, date: date),

        const SizedBox(height: 18),

        for (var index = 0; index < items.length; index++) ...[
          SpecializationTile(item: items[index]),
          if (index != items.length - 1) const SizedBox(height: 12),
        ],

        const SizedBox(height: 12),

        DashboardSectionCard(
          cardTitle: chartCardTitle,
          showButton: showChartButton,
          onTap: onChartTap,
          contentGap: 28,
          child: chart,
        ),
      ],
    );
  }
}

class SpecializationTile extends StatelessWidget {
  const SpecializationTile({super.key, required this.item});

  final SpecializationItem item;

  @override
  Widget build(BuildContext context) {
    return DashboardMetricTile(
      value: item.eyebrow,
      label: item.title,
      icon: item.icon,
      iconPosition: DashboardMetricTileIconPosition.topLeft,
      iconSize: 34,
      iconColor: Colors.white.withValues(alpha: 0.70),

      showArrow: true,
      onTap: item.onTap,
      onArrowTap: item.onTap,

      variant: item.gradient == null
          ? DashboardCardVariant.solid
          : DashboardCardVariant.gradient,
      color: item.color,
      gradient: item.gradient,

      height: 122,
      borderRadius: AppDesign.defaultBorderRadius,
      padding: AppDesign.defaultPadding,

      valueFontSize: 12,
      valueWeight: FontWeight.w600,
      valueColor: Colors.white.withValues(alpha: 0.92),

      labelFontSize: 17,
      labelWeight: FontWeight.w800,
      labelMaxLines: 2,
      labelColor: Colors.white,

      reservedTrailingWidth: 0,
    );
  }
}
