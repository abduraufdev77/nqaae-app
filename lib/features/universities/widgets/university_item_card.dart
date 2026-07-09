import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_design.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/university.dart';
import 'nqaae_ui.dart';

class UniversityItemCard extends StatelessWidget {
  const UniversityItemCard({super.key, required this.university, this.onTap});

  final University university;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      university.region,
      university.ownership,
    ].whereType<String>().where((item) => item.trim().isNotEmpty).join(' / ');

    final effectiveOnTap = onTap ?? () => context.go('/dashboard');

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: effectiveOnTap,
      child: GlassCard(
        key: const ValueKey('university-item-card-glass'),
        height: 80,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        blurStrength: 8,
        borderWidth: 1.1,
        backgroundColor: Colors.black.withValues(
          alpha: 0.03,
        ), // Clean glass opacity
        borderGradient: AppDesign.verticalBorderGradient,
        child: Row(
          children: [
            NqaaeLogo(
              sourceId: university.sourceId,
              hasLogo: university.logoUrl != null,
              fallback: university.name,
              size: 52,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            GlassButton(
              key: const ValueKey('university-item-arrow'),
              assetName: 'assets/icons/arrow-right.svg',
              tooltip: 'Open',
              onPressed: effectiveOnTap,
              width: 38,
              height: 38,
              iconSize: 14,
              borderWidth: 1,
              blurStrength: 8,
            ),
          ],
        ),
      ),
    );
  }
}
