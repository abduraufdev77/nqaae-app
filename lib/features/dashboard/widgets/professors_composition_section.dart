import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card.dart';
import 'dashboard_section_card.dart';

class ProfessorsCompositionSection extends StatelessWidget {
  const ProfessorsCompositionSection({
    super.key,
    this.title = 'Professor-o‘qituvchilar tarkibi',
    this.date = '01.07.2026',
    this.items = defaultItems,
  });

  static const defaultItems = [
    ProfessorCompositionItem(
      icon: Iconsax.teacher,
      value: '123',
      label: 'Total professors',
    ),
    ProfessorCompositionItem(
      icon: Iconsax.briefcase,
      value: '49,7',
      label: 'Average age',
    ),
    ProfessorCompositionItem(
      icon: Iconsax.people,
      value: '42',
      label: 'Student-to-professor ratio',
    ),
    ProfessorCompositionItem(
      icon: Iconsax.award,
      value: '19.91%',
      label: 'Professors holding academic degrees',
    ),
  ];

  final String title;
  final String date;
  final List<ProfessorCompositionItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(title: title, date: date),
        const SizedBox(height: 18),
        LayoutBuilder(
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
                    child: _ProfessorCompositionTile(item: item),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class ProfessorCompositionItem {
  const ProfessorCompositionItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

class _ProfessorCompositionTile extends StatelessWidget {
  const _ProfessorCompositionTile({required this.item});

  final ProfessorCompositionItem item;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      variant: DashboardCardVariant.gradient,
      height: 114,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      // borderRadius: const BorderRadius.all(Radius.circular(14)),
      gradient: AppColors.gradient(style: GradientStyle.diagonal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            color: Colors.white.withValues(alpha: 0.7),
            size: 24,
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              item.value,
              maxLines: 1,
              style: DashboardTextStyles.text(
                fontSize: 20,
                weight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DashboardTextStyles.text(
              fontSize: 11,
              weight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
