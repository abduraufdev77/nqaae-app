import 'package:flutter/material.dart';

import 'glass_card.dart';

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.icon,
    this.label,
    this.tooltip,
    this.onPressed,
    this.width = 54,
    this.height = 54,
    this.iconSize = 23,
    this.borderRadius = const BorderRadius.all(Radius.circular(99)),
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.white,
    this.padding = EdgeInsets.zero,
  });

  final IconData icon;
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

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius.resolve(Directionality.of(context)),
        onTap: onPressed,
        child: Center(
          child: label == null
              ? Icon(icon, color: foregroundColor, size: iconSize)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: foregroundColor, size: iconSize),
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
        ),
      ),
    );

    return GlassCard(
      width: width,
      height: height,
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      child: tooltip == null
          ? button
          : Tooltip(message: tooltip!, child: button),
    );
  }
}
