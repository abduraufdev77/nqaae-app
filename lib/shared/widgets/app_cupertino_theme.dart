import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class AppCupertinoTheme extends StatelessWidget {
  const AppCupertinoTheme({super.key, required this.child});

  final Widget child;

  static const double titleFontSize = 15;
  static const double actionFontSize = 17;
  static const double messageFontSize = 13;
  static const double flagFontSize = 20;

  static TextStyle titleTextStyle({Color? color}) => GoogleFonts.openSans(
    color: color ?? Colors.white.withValues(alpha: 0.62),
    fontSize: titleFontSize,
    fontWeight: FontWeight.w700,
  );

  static TextStyle actionTextStyle({Color? color}) => GoogleFonts.openSans(
    color: color ?? AppColors.primary,
    fontSize: actionFontSize,
    fontWeight: FontWeight.w700,
  );

  static TextStyle cancelTextStyle() => actionTextStyle(color: AppColors.error);

  static TextStyle messageTextStyle({Color? color}) => GoogleFonts.openSans(
    color: color ?? Colors.white.withValues(alpha: 0.62),
    fontSize: messageFontSize,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBg,
        barBackgroundColor: AppColors.darkSurface,
        textTheme: CupertinoTextThemeData(
          actionTextStyle: actionTextStyle(),
          navActionTextStyle: actionTextStyle(),
          navTitleTextStyle: actionTextStyle(color: Colors.white),
          pickerTextStyle: actionTextStyle(color: Colors.white),
          dateTimePickerTextStyle: actionTextStyle(color: Colors.white),
          textStyle: titleTextStyle(color: Colors.white),
        ),
      ),
      child: child,
    );
  }
}
