import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nqaae_app/core/constants/app_design.dart';

import '../../core/constants/app_colors.dart';
import '../../features/dashboard/widgets/dashboard_section_card.dart';
import 'glass_button.dart';

enum DashboardModalSheetDirection { left, right, bottom }

enum DashboardModalSheetBackground { gradient, flat }

enum DashboardModalSheetType { normal, fullScreen }

Future<T?> showDashboardModalSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  DashboardModalSheetDirection direction = DashboardModalSheetDirection.bottom,
  DashboardModalSheetBackground background =
      DashboardModalSheetBackground.gradient,
  DashboardModalSheetType type = DashboardModalSheetType.normal,
  Gradient? gradient,
  Color flatColor = const Color(0xFF081936),
  bool barrierDismissible = true,
  Duration transitionDuration = const Duration(milliseconds: 320),
}) {
  if (direction == DashboardModalSheetDirection.bottom) {
    final routeMedia = MediaQuery.of(context);
    final topInset = routeMedia.viewPadding.top > 0
        ? routeMedia.viewPadding.top
        : routeMedia.padding.top;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: barrierDismissible,
      enableDrag: true,
      showDragHandle: false,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) {
        return DashboardModalSheet(
          title: title,
          direction: direction,
          background: background,
          type: type,
          gradient: gradient,
          flatColor: flatColor,
          showGrabHandle: false,
          topInsetOverride: topInset,
          child: child,
        );
      },
    );
  }

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: transitionDuration,
    pageBuilder: (context, _, _) {
      return DashboardModalSheet(
        title: title,
        direction: direction,
        background: background,
        type: type,
        gradient: gradient,
        flatColor: flatColor,
        child: child,
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final beginOffset = switch (direction) {
        DashboardModalSheetDirection.left => const Offset(-1, 0),
        DashboardModalSheetDirection.right => const Offset(1, 0),
        DashboardModalSheetDirection.bottom => const Offset(0, 1),
      };

      return SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      );
    },
  );
}

class DashboardModalSheet extends StatelessWidget {
  const DashboardModalSheet({
    super.key,
    required this.title,
    required this.child,
    this.direction = DashboardModalSheetDirection.bottom,
    this.background = DashboardModalSheetBackground.gradient,
    this.type = DashboardModalSheetType.normal,
    this.gradient,
    this.flatColor = const Color(0xFF081936),
    this.showGrabHandle = true,
    this.topInsetOverride,
  });

  final String title;
  final Widget child;
  final DashboardModalSheetDirection direction;
  final DashboardModalSheetBackground background;
  final DashboardModalSheetType type;
  final Gradient? gradient;
  final Color flatColor;
  final bool showGrabHandle;
  final double? topInsetOverride;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isBottom = direction == DashboardModalSheetDirection.bottom;
    final isFullScreen = type == DashboardModalSheetType.fullScreen;

    final width = isBottom
        ? media.size.width
        : isFullScreen
        ? media.size.width
        : media.size.width * 0.88;

    final height = isBottom
        ? isFullScreen
              ? media.size.height
              : media.size.height * 0.78
        : media.size.height;
    final useFloatingHeader = isBottom && isFullScreen;
    final topInset =
        topInsetOverride ??
        (media.viewPadding.top > 0 ? media.viewPadding.top : media.padding.top);

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: _alignment,
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            key: const ValueKey('dashboard-modal-sheet-clip'),
            borderRadius: _borderRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background == DashboardModalSheetBackground.flat
                    ? flatColor
                    : null,
                gradient: background == DashboardModalSheetBackground.gradient
                    ? gradient ?? AppColors.darkGradient
                    : null,
              ),
              child: useFloatingHeader
                  ? Stack(
                      children: [
                        Positioned.fill(child: child),

                        Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          height: topInset + 100,
                          child: const _DashboardModalEdgeShadow(
                            key: ValueKey('dashboard-modal-top-shadow'),
                            edge: _DashboardModalShadowEdge.top,
                          ),
                        ),

                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 112,
                          child: _DashboardModalEdgeShadow(
                            key: ValueKey('dashboard-modal-bottom-shadow'),
                            edge: _DashboardModalShadowEdge.bottom,
                          ),
                        ),


                        Positioned(
                          left: 14,
                          top: topInset + 5,
                          right: 14,
                          child: _DashboardModalHeader(
                            key: const ValueKey(
                              'dashboard-modal-floating-header',
                            ),
                            title: title,
                            floating: true,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        if (isBottom && showGrabHandle)
                          const SizedBox(height: 12),

                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            32,
                            isBottom ? 26 : media.padding.top + 26,
                            26,
                            22,
                          ),
                          child: _DashboardModalHeader(title: title),
                        ),

                        Expanded(child: child),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Alignment get _alignment {
    switch (direction) {
      case DashboardModalSheetDirection.left:
        return Alignment.centerLeft;
      case DashboardModalSheetDirection.right:
        return Alignment.centerRight;
      case DashboardModalSheetDirection.bottom:
        return Alignment.bottomCenter;
    }
  }

  BorderRadius get _borderRadius {
    switch (direction) {
      case DashboardModalSheetDirection.bottom:
        return const BorderRadius.vertical(top: Radius.circular(34));

      case DashboardModalSheetDirection.left:
        return const BorderRadius.horizontal(right: Radius.circular(34));

      case DashboardModalSheetDirection.right:
        return const BorderRadius.horizontal(left: Radius.circular(34));
    }
  }
}

enum _DashboardModalShadowEdge { top, bottom }

class _DashboardModalEdgeShadow extends StatelessWidget {
  const _DashboardModalEdgeShadow({super.key, required this.edge});

  final _DashboardModalShadowEdge edge;

  @override
  Widget build(BuildContext context) {
    final isTop = edge == _DashboardModalShadowEdge.top;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
            end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: isTop ? 0.93 : 0.77),
              Colors.black.withValues(alpha: isTop ? 0.4 : 0.3),
              Colors.black.withValues(alpha: 0),
            ],
            stops: const [0, 0.52, 1],
          ),
        ),
      ),
    );
  }
}

class _DashboardModalHeader extends StatelessWidget {
  const _DashboardModalHeader({
    super.key,
    required this.title,
    this.floating = true,
  });

  final String title;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DashboardTextStyles.text(
              fontSize: 14,
              weight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(width: 14),
        GlassButton(
          key: const ValueKey('dashboard-modal-close-button'),
          tooltip: 'Close',
          icon: CupertinoIcons.xmark,
          onPressed: () => Navigator.of(context).pop(),
          width: 40,
          height: 40,
          iconSize: 18,
        ),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42), width: 1),
        boxShadow: AppDesign.cardBoxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
            child: header,
          ),
        ),
      ),
    );
  }
}
