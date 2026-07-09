import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_design.dart';
import 'cupertino_liquid_pressable.dart';
import 'glass_card.dart';

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    this.icon,
    this.assetName,
    this.assetQuarterTurns = 0,
    this.label,
    this.tooltip,
    this.onPressed,
    this.width = 54,
    this.height = 54,
    this.iconSize = 23,
    this.borderRadius = const BorderRadius.all(Radius.circular(99)),
    this.backgroundColor = AppDesign.glassControlBackground,
    this.foregroundColor = Colors.white,
    this.padding = EdgeInsets.zero,
    this.borderGradient = AppDesign.verticalBorderGradient,
    this.borderWidth = AppDesign.glassControlBorderWidth,
    this.blurStrength = AppDesign.glassControlBlurStrength,
  }) : assert(icon != null || assetName != null);

  final IconData? icon;
  final String? assetName;
  final int assetQuarterTurns;
  final String? label;
  final String? tooltip;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double iconSize;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;
  final Gradient? borderGradient;
  final double borderWidth;
  final double blurStrength;

  @override
  Widget build(BuildContext context) {
    final iconWidget = _GlassButtonIcon(
      icon: icon,
      assetName: assetName,
      assetQuarterTurns: assetQuarterTurns,
      color: foregroundColor,
      size: iconSize,
    );

    final button = Center(
      child: label == null
          ? iconWidget
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                const SizedBox(height: 6),
                Text(
                  label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
    );

    final card = GlassCard(
      width: width,
      height: height,
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      borderGradient: borderGradient,
      borderWidth: borderWidth,
      blurStrength: blurStrength,
      child: CupertinoLiquidPressable(
        onTap: onPressed,
        scale: 0.96,
        child: tooltip == null
            ? button
            : Tooltip(message: tooltip!, child: button),
      ),
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      child: card,
    );
  }
}

class _GlassButtonIcon extends StatelessWidget {
  const _GlassButtonIcon({
    required this.icon,
    required this.assetName,
    required this.assetQuarterTurns,
    required this.color,
    required this.size,
  });

  final IconData? icon;
  final String? assetName;
  final int assetQuarterTurns;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (assetName != null) {
      return RotatedBox(
        quarterTurns: assetQuarterTurns,
        child: SvgPicture.asset(
          assetName!,
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      );
    }

    return Icon(icon, color: color, size: size);
  }
}
