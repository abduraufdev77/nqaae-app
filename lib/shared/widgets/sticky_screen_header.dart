import 'package:flutter/material.dart';

import '../../core/constants/app_design.dart';

class StickyScreenHeader extends StatelessWidget {
  const StickyScreenHeader({
    super.key,
    required this.child,
    this.contentHeight = AppDesign.screenHeaderControlHeight,
    this.topGap = 0,
    this.bottomGap = AppDesign.screenHeaderBottomGap,
    this.horizontalPadding = AppDesign.screenHorizontalPadding,
    this.shadowKey,
  });

  final Widget child;
  final double contentHeight;
  final double topGap;
  final double bottomGap;
  final double horizontalPadding;
  final Key? shadowKey;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyScreenHeaderDelegate(
        topPadding: MediaQuery.paddingOf(context).top,
        contentHeight: contentHeight,
        topGap: topGap,
        bottomGap: bottomGap,
        horizontalPadding: horizontalPadding,
        shadowKey: shadowKey,
        child: child,
      ),
    );
  }
}

class _StickyScreenHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _StickyScreenHeaderDelegate({
    required this.topPadding,
    required this.contentHeight,
    required this.topGap,
    required this.bottomGap,
    required this.horizontalPadding,
    required this.child,
    this.shadowKey,
  });

  final double topPadding;
  final double contentHeight;
  final double topGap;
  final double bottomGap;
  final double horizontalPadding;
  final Widget child;
  final Key? shadowKey;

  double get _extent => topPadding + topGap + contentHeight + bottomGap;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shadowOpacity = (shrinkOffset / 24).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          key: shadowKey,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.70 + (shadowOpacity * 0.16)),
                Colors.black.withValues(alpha: 0.42 + (shadowOpacity * 0.10)),
                Colors.black.withValues(alpha: 0),
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.20 + (shadowOpacity * 0.10),
                ),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding + topGap,
            horizontalPadding,
            bottomGap,
          ),
          child: child,
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _StickyScreenHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.contentHeight != contentHeight ||
        oldDelegate.topGap != topGap ||
        oldDelegate.bottomGap != bottomGap ||
        oldDelegate.horizontalPadding != horizontalPadding ||
        oldDelegate.child != child ||
        oldDelegate.shadowKey != shadowKey;
  }
}
