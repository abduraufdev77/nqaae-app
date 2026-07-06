import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_colors.dart';
import 'dashboard_section_card.dart';

class StudentContingentSection extends StatelessWidget {
  const StudentContingentSection({super.key});

  static const _segments = [
    _StudentSegment('Bakalavr', '11 504', AppColors.primaryLight, 0.92),
    _StudentSegment('Magistratura', '467', Color(0xFF18E5E7), 0.037),
    _StudentSegment('Doktorantura', '539', Color(0xFF25BD94), 0.043),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Key metrics',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size(72, 34),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Export',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DashboardSectionCard(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Student contingent',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.arrow_right_3,
                      color: Colors.white.withValues(alpha: 0.52),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: _StudentDonutPainter(_segments),
                    child: Center(
                      child: Text(
                        '12 510',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (final segment in _segments) ...[
                _StudentLegendRow(segment: segment),
                if (segment != _segments.last) const SizedBox(height: 13),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _DashboardMetricTile(
                icon: Iconsax.people,
                value: '229',
                label: 'Professors and teachers',
              ),
            ),
            SizedBox(width: 13),
            Expanded(
              child: _DashboardMetricTile(
                icon: Iconsax.chart_2,
                value: '36',
                label: 'National ranking position',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StudentLegendRow extends StatelessWidget {
  const _StudentLegendRow({required this.segment});

  final _StudentSegment segment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: segment.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            segment.label,
            style: GoogleFonts.openSans(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          segment.value,
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DashboardMetricTile extends StatelessWidget {
  const _DashboardMetricTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.dashboardMetricTile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.dashboardMutedIcon, size: 30),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentDonutPainter extends CustomPainter {
  const _StudentDonutPainter(this.segments);

  final List<_StudentSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.15;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    var start = -math.pi * 1.36;
    const gap = 0.12;

    for (final segment in segments) {
      final sweep = (math.pi * 2 * segment.ratio) - gap;
      paint.color = segment.color;
      canvas.drawArc(
        arcRect,
        start,
        sweep.clamp(0.08, math.pi * 2).toDouble(),
        false,
        paint,
      );
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _StudentDonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

class _StudentSegment {
  const _StudentSegment(this.label, this.value, this.color, this.ratio);

  final String label;
  final String value;
  final Color color;
  final double ratio;
}
