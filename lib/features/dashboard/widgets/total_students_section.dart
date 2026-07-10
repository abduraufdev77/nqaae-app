import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:nqaae_app/shared/widgets/metric_tile.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card.dart';
import 'charts/rounded_pie_chart.dart';
import 'dashboard_section_card.dart';

class TotalStudentsSection extends StatelessWidget {
  const TotalStudentsSection({
    super.key,
    this.cardTitle = 'Jami talabalar',
    this.total = '12 510',
    this.segments = defaultSegments,
    this.professors = '229',
    this.nationalRanking = '36',
    this.onTap,
  });

  static const defaultSegments = [
    RoundedPieChartSegment(
      label: 'Bakalavr',
      value: '11 504',
      amount: 11504,
      color: AppColors.primary,
    ),
    RoundedPieChartSegment(
      label: 'Magistratura',
      value: '467',
      amount: 467,
      color: Color(0xFF18E5E7),
    ),
    RoundedPieChartSegment(
      label: 'Doktorantura',
      value: '539',
      amount: 539,
      color: AppColors.accent,
    ),
  ];

  final String cardTitle;
  final String total;
  final List<RoundedPieChartSegment> segments;
  final String professors;
  final String nationalRanking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardSectionCard(
          cardTitle: cardTitle,
          showButton: true,
          onTap: onTap,
          contentGap: 20,
          child: RoundedPieChart(
            centerValue: total,
            segments: segments,
            size: 188,
            showLegend: true,
            showCenterValue: true,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: DashboardMetricTile(
                icon: Iconsax.people,
                iconPosition: DashboardMetricTileIconPosition.topLeft,
                value: professors,
                label: 'Professors and teachers',
                variant: DashboardCardVariant.solid,
                color: AppColors.primary,
                height: 100,
                iconSize: 30,
                labelMaxLines: 1,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DashboardMetricTile(
                icon: Iconsax.chart_2,
                iconPosition: DashboardMetricTileIconPosition.topLeft,
                value: nationalRanking,
                label: 'National ranking position',
                variant: DashboardCardVariant.solid,
                color: AppColors.primary,
                height: 100,
                iconSize: 30,
                labelMaxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
