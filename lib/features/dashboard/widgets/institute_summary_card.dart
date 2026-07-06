import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_colors.dart';

class InstituteSummaryCard extends StatelessWidget {
  const InstituteSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 32),
      decoration: BoxDecoration(
        color: AppColors.dashboardPanel,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SvgPicture.asset(
                  'assets/icons/building.svg',
                  width: 43,
                  height: 42,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  'ANDIJAN STATE\nPEDAGOGICAL INSTITUTE',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 54),
          const Row(
            children: [
              Expanded(
                child: _InstituteInfoTile(
                  title: 'STATE',
                  subtitle: 'Mulkchilik',
                  icon: Iconsax.teacher,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _InstituteInfoTile(
                  title: 'ANDIJON',
                  subtitle: 'Hudud',
                  icon: Iconsax.location,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _InstituteInfoTile(
                  title: '2021',
                  subtitle: 'Tashkil etilgan',
                  icon: Iconsax.calendar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstituteInfoTile extends StatelessWidget {
  const _InstituteInfoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.52),
              size: 25,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 1,
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.08,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
