import 'package:flutter/material.dart';

class AppDesign {
  // Prevent instantiation of this class
  AppDesign._();

  static const EdgeInsets defaultPadding = EdgeInsets.fromLTRB(16, 14, 16, 14);
  static const double screenHorizontalPadding = 14;
  static const double screenHeaderControlHeight = 46;
  static const double screenHeaderBottomGap = 16;
  static const double screenTitleTopGap = 34;
  static const double sectionTopGap = 18;

  static const BorderRadius defaultBorderRadius = BorderRadius.all(
    Radius.circular(20),
  );

  static const BorderSide defaultBorderColor = BorderSide(
    color: Color.fromRGBO(255, 255, 255, 0.12),
    width: 1,
  );

  static final List<BoxShadow> cardBoxShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 32,
      offset: const Offset(10, 10),
    ),
  ];

  static const Color glassBackground = Color.fromRGBO(255, 255, 255, 0.07);
  static const Color glassControlBackground = Color(0x0C000000);
  static const double glassControlBorderWidth = 1;
  static const double glassControlBlurStrength = 8;

  static const LinearGradient diagonalBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x18FFFFFF), Color(0x00999999)],
    stops: [0, 1],
  );

  static const LinearGradient verticalBorderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x18FFFFFF), Color.fromARGB(12, 255, 255, 255)],
  );
}
