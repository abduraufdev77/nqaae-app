import 'package:flutter/material.dart';

import '../../core/constants/app_design.dart';
import 'sticky_screen_header.dart';

class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.center,
    this.leading,
    this.trailing,
    this.shadowKey,
    this.contentHeight = AppDesign.screenHeaderControlHeight,
    this.horizontalPadding = AppDesign.screenHorizontalPadding,
    this.bottomGap = AppDesign.screenHeaderBottomGap,
    this.leadingGap = 12,
    this.trailingGap = 12,
  });

  final Widget? leading;
  final Widget center;
  final Widget? trailing;
  final Key? shadowKey;
  final double contentHeight;
  final double horizontalPadding;
  final double bottomGap;
  final double leadingGap;
  final double trailingGap;

  @override
  Widget build(BuildContext context) {
    return StickyScreenHeader(
      contentHeight: contentHeight,
      horizontalPadding: horizontalPadding,
      bottomGap: bottomGap,
      shadowKey: shadowKey,
      child: SizedBox(
        height: contentHeight,
        child: Row(
          children: [
            if (leading != null) ...[leading!, SizedBox(width: leadingGap)],
            Expanded(child: center),
            if (trailing != null) ...[SizedBox(width: trailingGap), trailing!],
          ],
        ),
      ),
    );
  }
}
