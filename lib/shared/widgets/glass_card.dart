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
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.blurStrength = 12,
    this.borderColor,
    this.backgroundColor,
    this.borderGradient,
    this.borderWidth = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final radius = borderRadius;

    // CRITICAL FIX: Calculate the nested inner radius to stop background bleeding
    final innerRadius = BorderRadius.only(
      topLeft: Radius.circular(
        (radius.topLeft.x - borderWidth).clamp(0, double.infinity),
      ),
      topRight: Radius.circular(
        (radius.topRight.x - borderWidth).clamp(0, double.infinity),
      ),
      bottomLeft: Radius.circular(
        (radius.bottomLeft.x - borderWidth).clamp(0, double.infinity),
      ),
      bottomRight: Radius.circular(
        (radius.bottomRight.x - borderWidth).clamp(0, double.infinity),
      ),
    );

    final strokeGradient =
        borderGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFFFFFFF), const Color(0x009999FF)],
          stops: [0.0, 0.0],
        );

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(gradient: strokeGradient, borderRadius: radius),
      padding: EdgeInsets.all(borderWidth), // Outer stroke width simulator
      child: ClipRRect(
        borderRadius: innerRadius, // Uses adjusted inner corner bounds
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: Container(
            decoration: BoxDecoration(
              color:
                  backgroundColor ??
                  (isDark ? AppColors.glassDark : AppColors.glassLight),
              borderRadius: innerRadius,
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
