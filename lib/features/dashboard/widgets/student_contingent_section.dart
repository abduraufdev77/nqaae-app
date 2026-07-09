import 'package:flutter/material.dart';
import 'package:nqaae_app/shared/widgets/metric_tile.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/card.dart';
import 'dashboard_section_card.dart';

class StudentContingentMetric {
  const StudentContingentMetric({
    required this.value,
    required this.label,
    this.assetName,
    this.gradient,
    this.badge,
    this.badgeVariant = DashboardMetricTileBadgeVariant.solid,
    this.badgeColor = const Color(0xFF5D9EFF),
    this.badgeGradient,
  });

  final String value;
  final String label;
  final String? assetName;
  final Gradient? gradient;
  final String? badge;
  final DashboardMetricTileBadgeVariant badgeVariant;
  final Color badgeColor;
  final Gradient? badgeGradient;
}

class StudentContingentSection extends StatelessWidget {
  const StudentContingentSection({
    super.key,
    this.title = 'Talabalar kontigenti',
    this.date = '01.07.2026',
    this.cardTitle = 'Jami talabalar',
    this.total = '11 971',
    this.bachelor = '11 504',
    this.master = '467',
    this.onTap,
  });

  final String title;
  final String date;
  final String cardTitle;
  final String total;
  final String bachelor;
  final String master;
  final VoidCallback? onTap;

  static const _masterGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF18B8C2), Color.fromRGBO(5, 178, 184, 1)],
  );

  static const _highBadgeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2961BD), Color(0xFF659CEE)],
  );

  @override
  Widget build(BuildContext context) {
    final primaryMetrics = [
      StudentContingentMetric(
        value: bachelor,
        label: 'Bachelor',
        assetName: 'assets/icons/bachelor.svg',
        gradient: AppColors.gradient(style: GradientStyle.linear),
      ),
      StudentContingentMetric(
        value: master,
        label: 'Master',
        assetName: 'assets/icons/master.svg',
        gradient: _masterGradient,
      ),
    ];

    const compactMetrics = [
      StudentContingentMetric(value: '2 455', label: 'Qabul qilinganlar'),
      StudentContingentMetric(value: '756', label: 'Tamomlash darajasi'),
      StudentContingentMetric(value: '565', label: 'Bitiruvchilar soni'),
      StudentContingentMetric(
        value: '756',
        label: 'Bitiruvchilar bandlik darajasi',
        badge: 'High',
        badgeVariant: DashboardMetricTileBadgeVariant.gradient,
        badgeGradient: _highBadgeGradient,
      ),
    ];

    return DashboardSectionCard(
      title: title,
      date: date,
      cardTitle: cardTitle,
      showButton: true,
      onTap: onTap,
      sectionGap: 18,
      contentGap: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            total,
            style: DashboardTextStyles.text(
              fontSize: 28,
              weight: FontWeight.w800,
              height: 1,
            ),
          ),

          const SizedBox(height: 20),

          const _ContingentRatioBar(),

          const SizedBox(height: 10),

          _MetricPairRow(
            gap: 10,
            children: [
              for (final metric in primaryMetrics)
                DashboardMetricTile(
                  value: metric.value,
                  label: metric.label,
                  assetName: metric.assetName,
                  iconPosition: DashboardMetricTileIconPosition.topRight,
                  iconSize: 32,
                  iconColor: Colors.white.withValues(alpha: 0.4),
                  variant: DashboardCardVariant.gradient,
                  gradient: metric.gradient,
                  height: 84,
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
                  valueFontSize: 22,
                  valueWeight: FontWeight.w900,
                  labelFontSize: 13,
                  labelWeight: FontWeight.w800,
                  labelMaxLines: 1,
                  reservedTrailingWidth: 0,
                ),
            ],
          ),

          const SizedBox(height: 10),

          _MetricGrid(
            items: compactMetrics,
            gap: 10,
            itemBuilder: (metric) {
              return DashboardMetricTile(
                value: metric.value,
                label: metric.label,
                badge: metric.badge,
                badgeVariant: metric.badgeVariant,
                badgeColor: metric.badgeColor,
                badgeGradient: metric.badgeGradient,
                variant: DashboardCardVariant.solid,
                color: Colors.white.withValues(alpha: 0.055),
                height: 78,
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                labelMaxLines: 2,
                reservedTrailingWidth: 0,
              );
            },
          ),

          const SizedBox(height: 10),

          const _GraduateQualityBanner(),
        ],
      ),
    );
  }
}

class _MetricPairRow extends StatelessWidget {
  const _MetricPairRow({required this.children, this.gap = 10});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          Expanded(child: children[index]),
          if (index != children.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.items,
    required this.itemBuilder,
    this.gap = 10,
  });

  final List<StudentContingentMetric> items;
  final Widget Function(StudentContingentMetric metric) itemBuilder;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < items.length; rowIndex += 2) ...[
          _MetricPairRow(
            gap: gap,
            children: [
              itemBuilder(items[rowIndex]),
              if (rowIndex + 1 < items.length) itemBuilder(items[rowIndex + 1]),
            ],
          ),
          if (rowIndex + 2 < items.length) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class _ContingentRatioBar extends StatelessWidget {
  const _ContingentRatioBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '96%',
              style: DashboardTextStyles.text(
                fontSize: 13,
                weight: FontWeight.w900,
                height: 1,
              ),
            ),
            const Spacer(),
            Text(
              '4%',
              style: DashboardTextStyles.text(
                fontSize: 13,
                weight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 28,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.055),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 96,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(5, 5, 3, 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(3, 5, 5, 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18B8C2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GraduateQualityBanner extends StatelessWidget {
  const _GraduateQualityBanner();

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      variant: DashboardCardVariant.gradient,
      height: 96,
      padding: const EdgeInsets.fromLTRB(14, 14, 0, 0),
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [AppColors.primary, Color(0xFF35B8A4)],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/graduates.png',
              key: const ValueKey('student-contingent-graduates'),
              width: 136,
              fit: BoxFit.contain,
            ),
          ),

          Positioned.fill(
            right: 118,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '565',
                  style: DashboardTextStyles.text(
                    fontSize: 20,
                    weight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Bitiruvchilar sifat indeksi',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DashboardTextStyles.text(
                    fontSize: 13,
                    weight: FontWeight.w700,
                    height: 1.08,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
