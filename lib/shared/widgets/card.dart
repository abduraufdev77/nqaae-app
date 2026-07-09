import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_design.dart';

enum DashboardCardVariant { solid, flat, outline, gradient }

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.variant = DashboardCardVariant.flat,
    this.width,
    this.height,
    this.padding = AppDesign.defaultPadding,
    this.margin,
    this.borderRadius = AppDesign.defaultBorderRadius,
    this.color,
    this.borderColor,
    this.gradientColors,
    this.gradient,
    this.alignment,
  });

  final Widget child;
  final DashboardCardVariant variant;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final Color? color;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final Gradient? gradient;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors ?? const [AppColors.primary, AppColors.accent],
        );

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: switch (variant) {
          DashboardCardVariant.solid => color ?? AppColors.dashboardPanel,
          DashboardCardVariant.flat => color ?? AppColors.dashboardSectionCard,
          DashboardCardVariant.outline => color ?? Colors.transparent,
          DashboardCardVariant.gradient => null,
        },
        gradient: variant == DashboardCardVariant.gradient
            ? effectiveGradient
            : null,
        borderRadius: borderRadius,
        border: variant == DashboardCardVariant.outline
            ? Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.12),
                width: 1,
              )
            : null,
      ),
      child: child,
    );
  }
}
