import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class DashboardSearchBar extends StatelessWidget {
  const DashboardSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onRefresh,
    this.height = 54,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onRefresh;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.openSans(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: GoogleFonts.openSans(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 22, right: 14),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              width: 22,
              height: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 58,
            minHeight: 54,
          ),
          suffixIcon: IconButton(
            tooltip: 'Voice search',
            onPressed: onRefresh,
            icon: SvgPicture.asset(
              'assets/icons/microphone.svg',
              width: 26,
              height: 26,
            ),
          ),
          filled: true,
          fillColor: AppColors.dashboardSearch,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
        ),
      ),
    );
  }
}
