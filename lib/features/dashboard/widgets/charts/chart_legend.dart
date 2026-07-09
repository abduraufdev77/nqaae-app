import 'package:flutter/material.dart';

import '../dashboard_section_card.dart';

class ChartLegendItem {
  const ChartLegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({
    super.key,
    required this.items,
    this.totalLabel,
    this.totalValue,
    this.dotSize = 8,
    this.dotLabelGap = 7,
    this.rowGap = 10,
    this.totalBottomGap = 14,
    this.labelFontSize = 12,
    this.labelWeight = FontWeight.w700,
    this.valueFontSize = 14,
    this.valueWeight = FontWeight.w800,
    this.totalLabelFontSize = 12,
    this.totalValueFontSize = 15,
    this.labelColor,
    this.valueColor,
  });

  final List<ChartLegendItem> items;

  final String? totalLabel;
  final String? totalValue;

  final double dotSize;
  final double dotLabelGap;
  final double rowGap;
  final double totalBottomGap;

  final double labelFontSize;
  final FontWeight labelWeight;
  final double valueFontSize;
  final FontWeight valueWeight;

  final double totalLabelFontSize;
  final double totalValueFontSize;

  final Color? labelColor;
  final Color? valueColor;

  bool get _hasTotal =>
      totalLabel != null &&
      totalLabel!.trim().isNotEmpty &&
      totalValue != null &&
      totalValue!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !_hasTotal) return const SizedBox.shrink();

    return Column(
      children: [
        if (_hasTotal) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  totalLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DashboardTextStyles.text(
                    fontSize: totalLabelFontSize,
                    weight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                totalValue!,
                style: DashboardTextStyles.text(
                  fontSize: totalValueFontSize,
                  weight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) SizedBox(height: totalBottomGap),
        ],

        for (var index = 0; index < items.length; index++) ...[
          ChartLegendRow(
            item: items[index],
            dotSize: dotSize,
            dotLabelGap: dotLabelGap,
            labelFontSize: labelFontSize,
            labelWeight: labelWeight,
            valueFontSize: valueFontSize,
            valueWeight: valueWeight,
            labelColor: labelColor,
            valueColor: valueColor,
          ),
          if (index != items.length - 1) SizedBox(height: rowGap),
        ],
      ],
    );
  }
}

class ChartLegendRow extends StatelessWidget {
  const ChartLegendRow({
    super.key,
    required this.item,
    this.dotSize = 8,
    this.dotLabelGap = 7,
    this.labelFontSize = 12,
    this.labelWeight = FontWeight.w700,
    this.valueFontSize = 14,
    this.valueWeight = FontWeight.w800,
    this.labelColor,
    this.valueColor,
  });

  final ChartLegendItem item;

  final double dotSize;
  final double dotLabelGap;

  final double labelFontSize;
  final FontWeight labelWeight;
  final double valueFontSize;
  final FontWeight valueWeight;

  final Color? labelColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        SizedBox(width: dotLabelGap),
        Expanded(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DashboardTextStyles.text(
              fontSize: labelFontSize,
              weight: labelWeight,
              color: labelColor ?? Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          item.value,
          style: DashboardTextStyles.text(
            fontSize: valueFontSize,
            weight: valueWeight,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
