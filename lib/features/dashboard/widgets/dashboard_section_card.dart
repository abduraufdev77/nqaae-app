import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/card.dart';
import '../../../shared/widgets/cupertino_liquid_pressable.dart';

class DashboardTextStyles {
  const DashboardTextStyles._();

  static TextStyle text({
    required double fontSize,
    required FontWeight weight,
    double height = 1.1,
    Color color = const Color.fromRGBO(255, 255, 255, 0.95),
  }) {
    return GoogleFonts.openSans(
      color: color,
      fontSize: fontSize,
      fontWeight: weight,
      height: height,
    );
  }
}

class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({super.key, required this.title, this.date});

  final String title;
  final String? date;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DashboardTextStyles.text(
              fontSize: 16,
              weight: FontWeight.w700,
              height: 1.05,
            ),
          ),
        ),
        if (date != null) ...[
          const SizedBox(width: 12),
          Text(
            date!,
            style: DashboardTextStyles.text(
              fontSize: 15,
              weight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ],
    );
  }
}

class DashboardCardHeader extends StatelessWidget {
  const DashboardCardHeader({
    super.key,
    required this.title,
    this.showButton = true,
    this.onTap,
  });

  final String title;
  final bool showButton;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DashboardTextStyles.text(
              fontSize: 16,
              weight: FontWeight.w700,
              height: 1.05,
            ),
          ),
        ),
        if (showButton)
          DashboardArrowCircleButton(
            size: 34,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            iconColor: Colors.white.withValues(alpha: 0.9),
            assetName: 'assets/icons/arrow-right.svg',
            onTap: onTap ?? () {},
          ),
      ],
    );
  }
}

class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    super.key,
    required this.child,
    this.title,
    this.date,
    this.cardTitle,
    this.showButton = true,
    this.onTap,
    this.sectionGap = 18,
    this.contentGap = 28,
  });

  final String? title;
  final String? date;
  final String? cardTitle;
  final bool showButton;
  final VoidCallback? onTap;
  final double sectionGap;
  final double contentGap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hasSectionHeader = title != null || date != null;
    final hasCardHeader = cardTitle != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasSectionHeader) ...[
          DashboardSectionHeader(title: title ?? '', date: date),
          SizedBox(height: sectionGap),
        ],
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasCardHeader) ...[
                DashboardCardHeader(
                  title: cardTitle!,
                  showButton: showButton,
                  onTap: onTap,
                ),
                SizedBox(height: contentGap),
              ],
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class DashboardArrowCircleButton extends StatelessWidget {
  const DashboardArrowCircleButton({
    required this.size,
    required this.backgroundColor,
    required this.iconColor,
    required this.assetName,
    required this.onTap,
    super.key,
  });

  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final String assetName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoLiquidPressable(
      onTap: onTap,
      scale: 0.94,
      child: Container(
        padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            assetName,
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            width: size * 0.4,
            height: size * 0.4,
          ),
        ),
      ),
    );
  }
}
