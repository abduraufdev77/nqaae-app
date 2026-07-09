import 'package:flutter/material.dart';
import 'package:nqaae_app/shared/widgets/metric_tile.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card.dart';
import 'dashboard_section_card.dart';

class NationalRatingMetric {
  const NationalRatingMetric({
    required this.value,
    required this.label,
    required this.gradient,
    this.assetName,
    this.onTap,
  });

  final String value;
  final String label;
  final Gradient gradient;
  final String? assetName;
  final VoidCallback? onTap;
}

class NationalRatingSection extends StatelessWidget {
  const NationalRatingSection({
    super.key,
    this.title = 'Milliy reyting ko‘rsatkichlari',
    this.metrics = defaultMetrics,
  });

  static const defaultMetrics = [
    NationalRatingMetric(
      value: '11 504',
      label: 'Milliy reytingdagi o‘rni',
      assetName: 'assets/icons/bachelor.svg',
      gradient: AppColors.blueGradient,
    ),
    NationalRatingMetric(
      value: '467',
      label: 'Umumiy ballar',
      assetName: 'assets/icons/master.svg',
      gradient: AppColors.accentGradient,
    ),
  ];

  final String title;
  final List<NationalRatingMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: title,
      sectionGap: 18,
      child: Column(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            _NationalRatingTile(metric: metrics[index]),
            if (index != metrics.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _NationalRatingTile extends StatelessWidget {
  const _NationalRatingTile({required this.metric});

  final NationalRatingMetric metric;

  @override
  Widget build(BuildContext context) {
    return DashboardMetricTile(
      value: metric.value,
      label: metric.label,
      assetName: metric.assetName,
      onTap: metric.onTap,
      iconPosition: DashboardMetricTileIconPosition.topRight,
      iconSize: 44,
      variant: DashboardCardVariant.gradient,
      gradient: metric.gradient,
      height: 92,
      valueFontSize: 22,
      valueWeight: FontWeight.w900,
      labelFontSize: 15,
      labelMaxLines: 2,
      reservedTrailingWidth: 0,
    );
  }
}
