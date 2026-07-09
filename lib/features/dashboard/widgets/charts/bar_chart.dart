import 'dart:math' as math;

import 'package:flutter/material.dart';

import '..//dashboard_section_card.dart';

class DashboardBarChartItem {
  const DashboardBarChartItem({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    this.percentText,
  });

  final String label;
  final String value;
  final double percent;
  final String? percentText;
  final Color color;

  String get displayPercent => percentText ?? '${percent.toStringAsFixed(1)}%';
}

class DashboardBarChartWithLegend extends StatelessWidget {
  const DashboardBarChartWithLegend({
    super.key,
    required this.items,
    this.trackHeight = 126,
    this.legendTopGap = 30,
  });

  final List<DashboardBarChartItem> items;
  final double trackHeight;
  final double legendTopGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardBarChart(items: items, trackHeight: trackHeight),
        SizedBox(height: legendTopGap),
        for (final item in items) ...[
          DashboardBarLegendRow(item: item),
          if (item != items.last) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class DashboardBarChart extends StatelessWidget {
  const DashboardBarChart({
    super.key,
    required this.items,
    this.trackHeight = 126,
  });

  final List<DashboardBarChartItem> items;
  final double trackHeight;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 18.0;
        final calculatedBarWidth =
            (constraints.maxWidth - gap * (items.length - 1)) / items.length;

        final barWidth = calculatedBarWidth.clamp(42.0, 54.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final item in items)
              DashboardBar(
                item: item,
                width: barWidth,
                trackHeight: trackHeight,
              ),
          ],
        );
      },
    );
  }
}

class DashboardBar extends StatelessWidget {
  const DashboardBar({
    super.key,
    required this.item,
    required this.width,
    required this.trackHeight,
  });

  final DashboardBarChartItem item;
  final double width;
  final double trackHeight;

  @override
  Widget build(BuildContext context) {
    final targetFactor = (item.percent / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.displayPercent,
              maxLines: 1,
              style: DashboardTextStyles.text(
                fontSize: 14,
                weight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: targetFactor),
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutCubic,
            builder: (context, factor, _) {
              final fillHeight = _fillHeight(
                percent: item.percent,
                factor: factor,
                trackHeight: trackHeight,
              );

              return Container(
                width: width,
                height: trackHeight,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: fillHeight,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  double _fillHeight({
    required double percent,
    required double factor,
    required double trackHeight,
  }) {
    if (percent <= 0) return 0;

    final rawHeight = trackHeight * factor;
    final minVisibleHeight = percent < 1 ? 4.0 : 7.0;

    return math.max(minVisibleHeight, rawHeight);
  }
}

class DashboardBarLegendRow extends StatelessWidget {
  const DashboardBarLegendRow({super.key, required this.item});

  final DashboardBarChartItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DashboardTextStyles.text(
              fontSize: 15,
              weight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          item.value,
          style: DashboardTextStyles.text(
            fontSize: 16,
            weight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
