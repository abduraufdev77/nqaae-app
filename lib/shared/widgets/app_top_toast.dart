import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

OverlayEntry? _activeToast;

enum AppToastType { success, info, error }

Future<void> showAppTopToast(
  BuildContext context, {
  required String message,
  AppToastType type = AppToastType.success,
  Duration duration = const Duration(milliseconds: 2400),
}) async {
  _activeToast?.remove();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => AppTopToast(message: message, type: type),
  );
  _activeToast = entry;
  Overlay.of(context, rootOverlay: true).insert(entry);

  await Future<void>.delayed(duration);
  if (entry.mounted) entry.remove();
  if (identical(_activeToast, entry)) _activeToast = null;
}

class AppTopToast extends StatelessWidget {
  const AppTopToast({
    super.key,
    required this.message,
    this.type = AppToastType.success,
  });

  final String message;
  final AppToastType type;

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final radius = BorderRadius.circular(isIos ? 16 : 20);
    final accentColor = switch (type) {
      AppToastType.success => AppColors.accent,
      AppToastType.info => AppColors.primary,
      AppToastType.error => AppColors.error,
    };
    final icon = switch (type) {
      AppToastType.success => CupertinoIcons.check_mark,
      AppToastType.info => CupertinoIcons.info,
      AppToastType.error => CupertinoIcons.exclamationmark,
    };
    final labelStyle = isIos
        ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            color: CupertinoColors.label.resolveFrom(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.2,
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
          )
        : GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.2,
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
          );
    final toast = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isIos ? 26 : 18,
          sigmaY: isIos ? 26 : 18,
        ),
        child: DecoratedBox(
          key: const ValueKey('app-toast-glass-surface'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isIos
                  ? [
                      const Color(0xFF30434B).withValues(alpha: 0.58),
                      AppColors.darkSurface.withValues(alpha: 0.42),
                    ]
                  : [
                      const Color(0xFF23434B).withValues(alpha: 0.72),
                      AppColors.darkSurface.withValues(alpha: 0.58),
                    ],
            ),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withValues(alpha: isIos ? 0.12 : 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isIos ? 0.24 : 0.3),
                blurRadius: isIos ? 18 : 24,
                offset: Offset(0, isIos ? 7 : 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isIos ? 14 : 16,
              vertical: isIos ? 12 : 13,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isIos ? 28 : 30,
                  height: isIos ? 28 : 30,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: isIos ? 15 : 17, color: Colors.white),
                ),
                SizedBox(width: isIos ? 10 : 12),
                Flexible(child: Text(message, style: labelStyle)),
              ],
            ),
          ),
        ),
      ),
    );

    return Positioned(
      key: const ValueKey('app-top-toast'),
      left: 18,
      right: 18,
      top: MediaQuery.paddingOf(context).top + 12,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, -18 * (1 - value)),
              child: child,
            ),
          ),
          child: isIos
              ? CupertinoPopupSurface(isSurfacePainted: false, child: toast)
              : Material(color: Colors.transparent, child: toast),
        ),
      ),
    );
  }
}
