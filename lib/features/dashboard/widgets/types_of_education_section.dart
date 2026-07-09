import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'charts/student_distribution_chart.dart';
import 'dashboard_section_card.dart';

class TypesOfEducationSection extends StatelessWidget {
  const TypesOfEducationSection({
    super.key,
    this.title = "Ta'lim turlari bo'yicha",
    this.date = '07.07.2026',
    this.cardTitle = 'Total Students',
    this.showButton = true,
    this.items = defaultItems,
    this.onTap,
  });

  static const defaultItems = [
    StudentDistributionChartItem(
      label: 'Kunduzgi',
      value: '6 715',
      percent: 56.1,
      percentText: '56.1%',
      color: AppColors.primary,
    ),
    StudentDistributionChartItem(
      label: 'Sirtqi',
      value: '4 101',
      percent: 34.2,
      percentText: '34.2%',
      color: Color(0xFF40A994),
    ),
    StudentDistributionChartItem(
      label: 'Kechki',
      value: '955',
      percent: 8.0,
      percentText: '8.0%',
      color: Color(0xFF18E5E7),
    ),
    StudentDistributionChartItem(
      label: 'Ikkinchi oliy (kunduzgi)',
      value: '15',
      percent: 0.13,
      percentText: '0.13%',
      color: Color(0xFF2588FF),
    ),
    StudentDistributionChartItem(
      label: 'Ikkinchi oliy (sirtqi)',
      value: '188',
      percent: 1.6,
      percentText: '1.6%',
      color: Color(0xFFFF986B),
    ),
  ];

  final String title;
  final String date;
  final String cardTitle;
  final bool showButton;
  final List<StudentDistributionChartItem> items;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: title,
      date: date,
      cardTitle: cardTitle,
      showButton: showButton,
      onTap: onTap,
      sectionGap: 18,
      contentGap: 28,
      child: StudentDistributionChart(items: items),
    );
  }
}
