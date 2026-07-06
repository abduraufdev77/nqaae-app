import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.dashboardSectionCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
