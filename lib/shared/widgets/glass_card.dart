import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final double blurStrength;
  final Color? borderColor;
  final Color? backgroundColor;
  final Gradient? borderGradient;
  final double borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.blurStrength = 10,
    this.borderColor,
    this.backgroundColor,
    this.borderGradient,
    this.borderWidth = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final radius = borderRadius;
    final strokeGradient =
        borderGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.52),
            Colors.white.withValues(alpha: 0.12),
            AppColors.accent.withValues(alpha: 0.46),
          ],
        );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(gradient: strokeGradient, borderRadius: radius),
      padding: EdgeInsets.all(borderWidth),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: Container(
            decoration: BoxDecoration(
              color:
                  backgroundColor ??
                  (isDark ? AppColors.glassDark : AppColors.glassLight),
              borderRadius: radius,
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor!, width: borderWidth),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
