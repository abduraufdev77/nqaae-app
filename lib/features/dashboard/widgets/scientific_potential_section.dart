import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../shared/widgets/card.dart';
import 'dashboard_section_card.dart';
import '../../../shared/widgets/metric_tile.dart';

class ScientificPotentialSection extends StatelessWidget {
  const ScientificPotentialSection({
    super.key,
    this.title = 'Ilmiy salohiyat',
    this.cardTitle = 'Research Lab',
    this.metrics = defaultMetrics,
    this.spinOffCount = '10',
    this.rankings = defaultRankings,
    this.onTap,
  });

  static const defaultMetrics = [
    ScientificPotentialMetric(
      value: '756',
      label: 'Ilmiy dajali kadrlar ulushi',
    ),
    ScientificPotentialMetric(value: '756', label: 'Ilmiy grantlar hajmi'),
    ScientificPotentialMetric(
      value: '756',
      label: 'Xalqaro va milliy ilmiy loyihalar soni',
    ),
    ScientificPotentialMetric(
      value: '756',
      label: 'Spin-off korxonalar aylanmasi',
    ),
    ScientificPotentialMetric(value: '756', label: 'Spin-off korxonalar soni'),
    ScientificPotentialMetric(value: '756', label: 'Patentlar soni'),
  ];

  static const defaultRankings = [
    ScientificPotentialRanking(label: 'Top 1%', value: '0'),
    ScientificPotentialRanking(label: 'Top 10%', value: '0'),
    ScientificPotentialRanking(label: 'Q1', value: '0'),
    ScientificPotentialRanking(label: 'Q2', value: '2'),
    ScientificPotentialRanking(label: 'Q3', value: '4'),
    ScientificPotentialRanking(label: 'Q4', value: '4'),
  ];

  final String title;
  final String cardTitle;
  final List<ScientificPotentialMetric> metrics;
  final String spinOffCount;
  final List<ScientificPotentialRanking> rankings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(title: title),
        const SizedBox(height: 18),
        DashboardCard(
          variant: DashboardCardVariant.flat,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardCardHeader(
                title: cardTitle,
                showButton: true,
                onTap: onTap,
              ),
              const SizedBox(height: 10),
              _ScientificMetricGrid(metrics: metrics),
              const SizedBox(height: 10),
              _SpinOffRankingCard(count: spinOffCount, rankings: rankings),
            ],
          ),
        ),
      ],
    );
  }
}

class ScientificPotentialMetric {
  const ScientificPotentialMetric({required this.value, required this.label});

  final String value;
  final String label;
}

class ScientificPotentialRanking {
  const ScientificPotentialRanking({required this.label, required this.value});

  final String label;
  final String value;
}

class _ScientificMetricGrid extends StatelessWidget {
  const _ScientificMetricGrid({required this.metrics});

  final List<ScientificPotentialMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final tileWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: 10,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: tileWidth,
                child: DashboardMetricTile(
                  value: metric.value,
                  label: metric.label,
                  variant: DashboardCardVariant.solid,
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                  height: 80,
                  valueFontSize: 20,
                  valueWeight: FontWeight.w800,
                  labelFontSize: 11,
                  labelWeight: FontWeight.w600,
                  labelMaxLines: 2,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SpinOffRankingCard extends StatelessWidget {
  const _SpinOffRankingCard({required this.count, required this.rankings});

  final String count;
  final List<ScientificPotentialRanking> rankings;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      variant: DashboardCardVariant.gradient,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      padding: EdgeInsetsGeometry.all(18),
      gradient: const LinearGradient(
        begin: Alignment(-0.36, -0.93),
        end: Alignment(0.36, 0.93),
        colors: [Color(0xFF1A71B3), Color(0xFF4AA9F2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Iconsax.award,
                color: Colors.white.withValues(alpha: 0.68),
                size: 42,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scopusdagi maqolalar soni',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DashboardTextStyles.text(
                        fontSize: 13,
                        weight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        count,
                        maxLines: 1,
                        style: DashboardTextStyles.text(
                          fontSize: 22,
                          weight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 14.0;
              final itemWidth = (constraints.maxWidth - (gap * 2)) / 3;

              return Wrap(
                spacing: gap,
                runSpacing: 22,
                children: [
                  for (final ranking in rankings)
                    SizedBox(
                      width: itemWidth,
                      child: _RankingCell(ranking: ranking),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RankingCell extends StatelessWidget {
  const _RankingCell({required this.ranking});

  final ScientificPotentialRanking ranking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 1.5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.19),
                // round only the right side borders
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(99),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: -3.3,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(102, 176, 233, 1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        ranking.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DashboardTextStyles.text(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          weight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '-',
                      style: DashboardTextStyles.text(
                        fontSize: 13,
                        weight: FontWeight.w700,
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ranking.value,
                maxLines: 1,
                textAlign: TextAlign.right,
                style: DashboardTextStyles.text(
                  fontSize: 13,
                  weight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
