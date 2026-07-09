import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/dashboard/widgets/dashboard_section_card.dart';
import '../../shared/widgets/card.dart';
import '../../shared/widgets/cupertino_liquid_pressable.dart';

enum DashboardMetricTileIconPosition { none, topLeft, topRight, rightCenter }

enum DashboardMetricTileBadgeVariant { solid, flat, gradient }

class DashboardMetricTile extends StatelessWidget {
  const DashboardMetricTile({
    super.key,
    required this.label,
    this.value,

    // Card style
    this.variant = DashboardCardVariant.solid,
    this.color = const Color.fromRGBO(255, 255, 255, 0.05),
    this.gradient,
    this.height = 80,
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
    this.padding = const EdgeInsets.fromLTRB(12, 10, 12, 10),

    // Tile border
    this.withBorder = false,
    this.borderColor,
    this.borderGradient,
    this.borderWidth = 1,

    // Icon
    this.icon,
    this.assetName,
    this.iconPosition = DashboardMetricTileIconPosition.none,
    this.iconSize = 30,
    this.iconColor,

    // Text
    this.valueFontSize = 19,
    this.valueWeight = FontWeight.w800,
    this.labelFontSize = 11,
    this.labelWeight = FontWeight.w600,
    this.labelMaxLines = 2,
    this.valueMaxLines = 1,
    this.valueLabelGap = 7,
    this.labelColor,
    this.valueColor,

    // Badge
    this.badge,
    this.badgeVariant = DashboardMetricTileBadgeVariant.solid,
    this.badgeColor = const Color(0xFF5D9EFF),
    this.badgeGradient,
    this.badgeTextColor = Colors.white,
    this.badgeFontSize = 10,
    this.badgeHeight = 20,
    this.badgeHorizontalPadding = 10,

    // Arrow/details
    this.showArrow = false,
    this.onTap,
    this.onArrowTap,

    /// By default, icon/badge/arrow are absolute overlays and text uses full width.
    /// Set this only if a specific tile text should avoid the overlay.
    this.reservedTrailingWidth = 0,
  });

  final String? value;
  final String label;

  final DashboardCardVariant variant;
  final Color color;
  final Gradient? gradient;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  final bool withBorder;
  final Color? borderColor;
  final Gradient? borderGradient;
  final double borderWidth;

  final IconData? icon;
  final String? assetName;
  final DashboardMetricTileIconPosition iconPosition;
  final double iconSize;
  final Color? iconColor;

  final double valueFontSize;
  final FontWeight valueWeight;
  final double labelFontSize;
  final FontWeight labelWeight;
  final int labelMaxLines;
  final int valueMaxLines;
  final double valueLabelGap;
  final Color? labelColor;
  final Color? valueColor;

  final String? badge;
  final DashboardMetricTileBadgeVariant badgeVariant;
  final Color badgeColor;
  final Gradient? badgeGradient;
  final Color badgeTextColor;
  final double badgeFontSize;
  final double badgeHeight;
  final double badgeHorizontalPadding;

  final bool showArrow;
  final VoidCallback? onTap;
  final VoidCallback? onArrowTap;

  final double reservedTrailingWidth;

  bool get _hasValue => value != null && value!.trim().isNotEmpty;
  bool get _hasIcon => icon != null || assetName != null;

  @override
  Widget build(BuildContext context) {
    final card = _buildCard();

    final tappableCard = onTap == null
        ? card
        : CupertinoLiquidPressable(onTap: onTap!, scale: 0.98, child: card);

    if (!withBorder) return tappableCard;

    return _MetricTileBorder(
      height: height,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      borderColor: borderColor,
      borderGradient: borderGradient,
      child: tappableCard,
    );
  }

  Widget _buildCard() {
    return DashboardCard(
      variant: variant,
      color: color,
      gradient: gradient,
      height: withBorder ? (height - borderWidth * 2).clamp(0, height) : height,
      padding: padding,
      borderRadius: withBorder
          ? _deflateBorderRadius(borderRadius, borderWidth)
          : borderRadius,
      child: Stack(
        children: [
          if (_hasIcon)
            _PositionedMetricIcon(
              icon: icon,
              assetName: assetName,
              iconPosition: iconPosition,
              iconSize: iconSize,
              iconColor: iconColor ?? Colors.white.withValues(alpha: 0.42),
            ),

          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: _MetricBadge(
                label: badge!,
                variant: badgeVariant,
                color: badgeColor,
                gradient: badgeGradient,
                textColor: badgeTextColor,
                fontSize: badgeFontSize,
                height: badgeHeight,
                horizontalPadding: badgeHorizontalPadding,
              ),
            ),

          if (showArrow)
            Positioned(
              top: 0,
              right: 0,
              child: DashboardArrowCircleButton(
                size: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                iconColor: Colors.white.withValues(alpha: 0.9),
                assetName: 'assets/icons/arrow-right.svg',
                onTap: onArrowTap ?? onTap ?? () {},
              ),
            ),

          Positioned.fill(
            right: reservedTrailingWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_hasValue) ...[
                  _MetricValueText(
                    value: value!,
                    maxLines: valueMaxLines,
                    color: valueColor ?? Colors.white,
                    fontSize: valueFontSize,
                    weight: valueWeight,
                  ),
                  SizedBox(height: valueLabelGap),
                ],
                Text(
                  label,
                  maxLines: labelMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: DashboardTextStyles.text(
                    fontSize: labelFontSize,
                    weight: labelWeight,
                    height: 1.12,
                    color: labelColor ?? Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius _deflateBorderRadius(BorderRadius radius, double amount) {
    Radius deflate(Radius r) {
      return Radius.circular((r.x - amount).clamp(0, double.infinity));
    }

    return BorderRadius.only(
      topLeft: deflate(radius.topLeft),
      topRight: deflate(radius.topRight),
      bottomLeft: deflate(radius.bottomLeft),
      bottomRight: deflate(radius.bottomRight),
    );
  }
}

class _MetricTileBorder extends StatelessWidget {
  const _MetricTileBorder({
    required this.child,
    required this.height,
    required this.borderRadius,
    required this.borderWidth,
    required this.borderColor,
    required this.borderGradient,
  });

  final Widget child;
  final double height;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color? borderColor;
  final Gradient? borderGradient;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        borderGradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            borderColor ?? Colors.white.withValues(alpha: 0.14),
            borderColor ?? Colors.white.withValues(alpha: 0.14),
          ],
        );

    return Container(
      height: height,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: effectiveGradient,
      ),
      child: child,
    );
  }
}

class _PositionedMetricIcon extends StatelessWidget {
  const _PositionedMetricIcon({
    required this.icon,
    required this.assetName,
    required this.iconPosition,
    required this.iconSize,
    required this.iconColor,
  });

  final IconData? icon;
  final String? assetName;
  final DashboardMetricTileIconPosition iconPosition;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final child = assetName != null
        ? SvgPicture.asset(
            assetName!,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          )
        : Icon(icon, size: iconSize, color: iconColor);

    switch (iconPosition) {
      case DashboardMetricTileIconPosition.none:
        return const SizedBox.shrink();

      case DashboardMetricTileIconPosition.topLeft:
        return Positioned(top: 0, left: 0, child: child);

      case DashboardMetricTileIconPosition.topRight:
        return Positioned(top: 0, right: 0, child: child);

      case DashboardMetricTileIconPosition.rightCenter:
        return Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: Center(child: child),
        );
    }
  }
}

class _MetricValueText extends StatelessWidget {
  const _MetricValueText({
    required this.value,
    required this.maxLines,
    required this.color,
    required this.fontSize,
    required this.weight,
  });

  final String value;
  final int maxLines;
  final Color color;
  final double fontSize;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    final style = DashboardTextStyles.text(
      color: color,
      fontSize: fontSize,
      weight: weight,
      height: maxLines > 1 ? 1.05 : 1,
    );

    if (maxLines <= 1) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(value, maxLines: 1, style: style),
      );
    }

    return Text(
      value,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.label,
    required this.variant,
    required this.color,
    required this.gradient,
    required this.textColor,
    required this.fontSize,
    required this.height,
    required this.horizontalPadding,
  });

  final String label;
  final DashboardMetricTileBadgeVariant variant;
  final Color color;
  final Gradient? gradient;
  final Color textColor;
  final double fontSize;
  final double height;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final Decoration decoration = switch (variant) {
      DashboardMetricTileBadgeVariant.solid => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      DashboardMetricTileBadgeVariant.flat => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      DashboardMetricTileBadgeVariant.gradient => BoxDecoration(
        gradient:
            gradient ??
            const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF5D9EFF), Color(0xFF31D7C5)],
            ),
        borderRadius: BorderRadius.circular(999),
      ),
    };

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: decoration,
      child: Center(
        child: Text(
          label,
          style: DashboardTextStyles.text(
            color: textColor,
            fontSize: fontSize,
            weight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
