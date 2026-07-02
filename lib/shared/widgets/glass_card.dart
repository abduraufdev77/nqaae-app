import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blurStrength;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.blurStrength = 10,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                (isDark ? AppColors.glassDark : AppColors.glassLight),
            borderRadius: borderRadius,
            border: Border.all(
              color:
                  borderColor ??
                  (isDark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight),
              width: 1,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
