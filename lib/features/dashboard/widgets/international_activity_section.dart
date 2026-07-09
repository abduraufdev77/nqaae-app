import 'package:flutter/material.dart';
import 'package:nqaae_app/shared/widgets/metric_tile.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card.dart';
import '../../../features/dashboard/widgets/dashboard_section_card.dart';

class InternationalActivityItem {
  const InternationalActivityItem({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;
}

class InternationalActivitySection extends StatelessWidget {
  const InternationalActivitySection({
    super.key,
    this.title = 'Xalqaro faoliyat',
    this.date = '07.07.2026',
    this.items = defaultItems,
  });

  static const defaultItems = [
    InternationalActivityItem(
      value: '11 504',
      label: 'Xorijiy talabalar soni',
      color: AppColors.primary,
      icon: Icons.public,
    ),
    InternationalActivityItem(
      value: '335',
      label: 'Xorijiy professor-o‘qituvchilar soni',
      color: Color(0xFF0FAAA6),
      icon: Icons.business_center_rounded,
    ),
    InternationalActivityItem(
      value: '12',
      label: 'Qo‘shma dasturlar',
      color: Color(0xFF13747D),
      icon: Icons.assignment_rounded,
    ),
  ];

  final String title;
  final String date;
  final List<InternationalActivityItem> items;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: title,
      date: date,
      sectionGap: 18,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            DashboardMetricTile(
              value: items[index].value,
              label: items[index].label,
              icon: items[index].icon,
              iconPosition: DashboardMetricTileIconPosition.topRight,
              iconSize: 42,
              iconColor: Colors.white.withValues(alpha: 0.36),
              variant: DashboardCardVariant.solid,
              color: items[index].color,
              height: 72,
              valueFontSize: 20,
              valueWeight: FontWeight.w800,
              labelFontSize: 12,
              labelMaxLines: 1,
              reservedTrailingWidth: 50,
            ),
            if (index != items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
