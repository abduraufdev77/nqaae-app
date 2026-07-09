import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card.dart';
import '../../../shared/widgets/metric_tile.dart';
import 'dashboard_section_card.dart';
import 'sheets/survey_results_sheet.dart';

class SurveyResultItem {
  const SurveyResultItem({
    required this.label,
    required this.assetPath,
    this.onTap,
  });

  final String label;
  final String assetPath;
  final VoidCallback? onTap;
}

class SurveyResultsSection extends StatelessWidget {
  const SurveyResultsSection({
    super.key,
    this.title = 'Umummilliy so‘rovnoma natijalari',
    this.items = defaultItems,
  });

  static const defaultItems = [
    SurveyResultItem(
      label: 'Professorlar va o‘qituvchilar',
      assetPath: SurveyResultsSheet.professorsAssetPath,
    ),
    SurveyResultItem(
      label: 'Talabalar',
      assetPath: SurveyResultsSheet.studentsAssetPath,
    ),
  ];

  final String title;
  final List<SurveyResultItem> items;

  void _openSheet(BuildContext context, SurveyResultItem item) {
    if (item.onTap != null) {
      item.onTap!();
      return;
    }

    SurveyResultsSheet.show(
      context: context,
      title: item.label,
      assetPath: item.assetPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(title: title),

        const SizedBox(height: 18),

        Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Expanded(
                child: DashboardMetricTile(
                  label: items[index].label,
                  onTap: () => _openSheet(context, items[index]),
                  onArrowTap: () => _openSheet(context, items[index]),
                  showArrow: true,
                  variant: DashboardCardVariant.gradient,
                  gradient: AppColors.gradient(style: GradientStyle.diagonal),
                  height: 100,
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                  padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                  labelFontSize: 14,
                  labelWeight: FontWeight.w700,
                  labelMaxLines: 2,
                ),
              ),
              if (index != items.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
}
