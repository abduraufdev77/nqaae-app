import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dashboard_section_card.dart';
import 'chart_legend.dart';

class StudentDistributionChartItem {
  const StudentDistributionChartItem({
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

  ChartLegendItem toLegendItem() {
    return ChartLegendItem(label: label, value: value, color: color);
  }
}

class StudentDistributionChart extends StatelessWidget {
  const StudentDistributionChart({
    super.key,
    required this.items,
    this.trackHeight = 126,
    this.legendTopGap = 30,
    this.barGap = 18,
    this.minBarWidth = 42,
    this.maxBarWidth = 54,
    this.percentFontSize = 12,
    this.percentFontWeight = FontWeight.w700,
    this.legendDotSize = 8,
    this.legendRowGap = 14,
    this.legendLabelFontSize = 12,
    this.legendLabelWeight = FontWeight.w700,
    this.legendValueFontSize = 14,
    this.legendValueWeight = FontWeight.w700,
  });

  final List<StudentDistributionChartItem> items;

  final double trackHeight;
  final double legendTopGap;
  final double barGap;
  final double minBarWidth;
  final double maxBarWidth;

  final double percentFontSize;
  final FontWeight percentFontWeight;

  final double legendDotSize;
  final double legendRowGap;
  final double legendLabelFontSize;
  final FontWeight legendLabelWeight;
  final double legendValueFontSize;
  final FontWeight legendValueWeight;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        _StudentDistributionBars(
          items: items,
          trackHeight: trackHeight,
          gap: barGap,
          minBarWidth: minBarWidth,
          maxBarWidth: maxBarWidth,
          percentFontSize: percentFontSize,
          percentFontWeight: percentFontWeight,
        ),

        SizedBox(height: legendTopGap),

        ChartLegend(
          items: items.map((item) => item.toLegendItem()).toList(),
          dotSize: legendDotSize,
          rowGap: legendRowGap,
          labelFontSize: legendLabelFontSize,
          labelWeight: legendLabelWeight,
          valueFontSize: legendValueFontSize,
          valueWeight: legendValueWeight,
        ),
      ],
    );
  }
}

class _StudentDistributionBars extends StatelessWidget {
  const _StudentDistributionBars({
    required this.items,
    required this.trackHeight,
    required this.gap,
    required this.minBarWidth,
    required this.maxBarWidth,
    required this.percentFontSize,
    required this.percentFontWeight,
  });

  final List<StudentDistributionChartItem> items;
  final double trackHeight;
  final double gap;
  final double minBarWidth;
  final double maxBarWidth;
  final double percentFontSize;
  final FontWeight percentFontWeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final calculatedBarWidth =
            (constraints.maxWidth - gap * (items.length - 1)) / items.length;

        final barWidth = calculatedBarWidth.clamp(minBarWidth, maxBarWidth);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final item in items)
              _StudentDistributionBar(
                item: item,
                width: barWidth,
                trackHeight: trackHeight,
                percentFontSize: percentFontSize,
                percentFontWeight: percentFontWeight,
              ),
          ],
        );
      },
    );
  }
}

class _StudentDistributionBar extends StatelessWidget {
  const _StudentDistributionBar({
    required this.item,
    required this.width,
    required this.trackHeight,
    required this.percentFontSize,
    required this.percentFontWeight,
  });

  final StudentDistributionChartItem item;
  final double width;
  final double trackHeight;
  final double percentFontSize;
  final FontWeight percentFontWeight;

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
                fontSize: percentFontSize,
                weight: percentFontWeight,
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
