import 'package:flutter/material.dart';

import '../../core/constants/app_design.dart';

class AppSliverBox extends StatelessWidget {
  const AppSliverBox({
    super.key,
    required this.child,
    this.top = 24,
    this.bottom = 0,
    this.left = AppDesign.screenHorizontalPadding,
    this.right = AppDesign.screenHorizontalPadding,
  });

  final Widget child;
  final double top;
  final double bottom;
  final double left;
  final double right;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      sliver: SliverToBoxAdapter(child: child),
    );
  }
}
