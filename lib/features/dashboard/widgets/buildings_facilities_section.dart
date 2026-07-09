import 'package:flutter/material.dart';

import '../../../shared/widgets/card.dart';
import 'package:nqaae_app/shared/widgets/metric_tile.dart';
import 'dashboard_section_card.dart';

class BuildingFacilityItem {
  const BuildingFacilityItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

class BuildingsFacilitiesSection extends StatelessWidget {
  const BuildingsFacilitiesSection({
    super.key,
    this.title = 'Bino va inshootlar',
    this.date = '07.07.2026',
    this.items = defaultItems,
  });

  static const defaultItems = [
    BuildingFacilityItem(
      value: '6',
      label: 'O‘quv binolari soni',
      icon: Icons.apartment_rounded,
    ),
    BuildingFacilityItem(
      value: '3 200',
      label: 'O‘quv binolari sig‘imi',
      icon: Icons.article_rounded,
    ),
    BuildingFacilityItem(
      value: '4',
      label: 'TTJ soni',
      icon: Icons.meeting_room_rounded,
    ),
    BuildingFacilityItem(
      value: '1 986',
      label: 'TTJ sig‘imi',
      icon: Icons.domain_rounded,
    ),
  ];

  final String title;
  final String date;
  final List<BuildingFacilityItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(title: title, date: date),

        const SizedBox(height: 18),

        DashboardCard(
          variant: DashboardCardVariant.gradient,
          // borderRadius: const BorderRadius.all(Radius.circular(26)),
          // padding: const EdgeInsets.all(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F4A54), Color(0xFF157180)],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              final tileWidth = (constraints.maxWidth - gap) / 2;

              return Wrap(
                spacing: gap,
                runSpacing: 10,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: tileWidth,
                      child: DashboardMetricTile(
                        value: item.value,
                        label: item.label,
                        icon: item.icon,
                        iconPosition: DashboardMetricTileIconPosition.topRight,
                        iconSize: 36,
                        iconColor: Colors.white.withValues(alpha: 0.25),
                        variant: DashboardCardVariant.solid,
                        color: const Color(0xFF146C7A),
                        height: 80,
                        labelMaxLines: 2,
                        reservedTrailingWidth: 0,
                        withBorder: true,
                        borderColor: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
