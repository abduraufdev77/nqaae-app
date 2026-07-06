import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import '../models/university.dart';
import 'nqaae_ui.dart';

class UniversityItem extends StatelessWidget {
  const UniversityItem({super.key, required this.university});

  final University university;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.push('/universities/${university.sourceId}'),
      child: GlassCard(
        borderRadius: const BorderRadius.all(Radius.circular(22)),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        backgroundColor: Colors.white.withValues(alpha: 0.10),
        child: Row(
          children: [
            NqaaeLogo(
              sourceId: university.sourceId,
              hasLogo: university.logoUrl != null,
              fallback: university.name,
              size: 58,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      height: 1.22,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    [university.region, university.ownership]
                        .whereType<String>()
                        .where((item) => item.isNotEmpty)
                        .join(' / '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
              ),
              child: const Icon(Iconsax.arrow_right_3, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
