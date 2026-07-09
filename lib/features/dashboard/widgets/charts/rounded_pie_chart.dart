import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'chart_legend.dart';
import '../dashboard_section_card.dart';

class RoundedPieChartSegment {
  const RoundedPieChartSegment({
    required this.label,
    required this.value,
    required this.amount,
    required this.color,
  });

  final String label;
  final String value;
  final double amount;
  final Color color;
}

class RoundedPieChart extends StatefulWidget {
  const RoundedPieChart({
    super.key,
    required this.segments,
    this.centerValue,
    this.size = 188,
    this.pieColors,
    this.showLegend = false,
    this.showCenterValue = true,
    this.strokeWidth,
    this.gapDegree = 4,
    this.startDegreeOffset = -106,
    this.chartLegendGap = 20,
    this.legendDotSize = 10,
    this.legendRowGap = 12,
    this.legendLabelFontSize = 12,
    this.legendValueFontSize = 16,
    this.animationDuration = const Duration(milliseconds: 850),
    this.animationCurve = Curves.easeOutCubic,
  });

  final List<RoundedPieChartSegment> segments;
  final String? centerValue;
  final double size;
  final List<Color>? pieColors;
  final bool showLegend;
  final bool showCenterValue;
  final double? strokeWidth;
  final double gapDegree;
  final double startDegreeOffset;
  final double chartLegendGap;
  final double legendDotSize;
  final double legendRowGap;
  final double legendLabelFontSize;
  final double legendValueFontSize;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<RoundedPieChart> createState() => _RoundedPieChartState();
}

class _RoundedPieChartState extends State<RoundedPieChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late List<double> _fromAmounts;
  late List<double> _toAmounts;

  @override
  void initState() {
    super.initState();

    _fromAmounts = _amountsOf(widget.segments);
    _toAmounts = _amountsOf(widget.segments);

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant RoundedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }

    final nextAmounts = _amountsOf(widget.segments);

    if (!_sameAmounts(_toAmounts, nextAmounts)) {
      final currentT = widget.animationCurve.transform(_controller.value);

      _fromAmounts = _lerpAmounts(
        _fromAmounts,
        _toAmounts,
        currentT,
        math.max(_fromAmounts.length, _toAmounts.length),
      );

      _toAmounts = nextAmounts;
      _controller.forward(from: 0);
    }
  }

  List<double> _amountsOf(List<RoundedPieChartSegment> segments) {
    return segments.map((segment) => segment.amount).toList();
  }

  bool _sameAmounts(List<double> a, List<double> b) {
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  List<double> _lerpAmounts(
    List<double> from,
    List<double> to,
    double t,
    int length,
  ) {
    return List.generate(length, (index) {
      final start = index < from.length ? from[index] : 0.0;
      final end = index < to.length ? to[index] : 0.0;

      return start + (end - start) * t;
    });
  }

  List<RoundedPieChartSegment> get _coloredSegments {
    final colors = widget.pieColors;
    if (colors == null || colors.isEmpty) return widget.segments;

    return [
      for (var index = 0; index < widget.segments.length; index++)
        RoundedPieChartSegment(
          label: widget.segments[index].label,
          value: widget.segments[index].value,
          amount: widget.segments[index].amount,
          color: colors[index % colors.length],
        ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final segments = _coloredSegments;
    final chart = _RoundedPieChartBody(
      segments: segments,
      centerValue: widget.centerValue,
      size: widget.size,
      strokeWidth: widget.strokeWidth,
      gapDegree: widget.gapDegree,
      startDegreeOffset: widget.startDegreeOffset,
      showCenterValue: widget.showCenterValue,
      animation: _controller,
      animationDuration: widget.animationDuration,
      animationCurve: widget.animationCurve,
      fromAmounts: _fromAmounts,
      toAmounts: _toAmounts,
      lerpAmounts: _lerpAmounts,
    );

    if (!widget.showLegend) return chart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: chart),
        SizedBox(height: widget.chartLegendGap),
        ChartLegend(
          items: [
            for (final segment in segments)
              ChartLegendItem(
                label: segment.label,
                value: segment.value,
                color: segment.color,
              ),
          ],
          dotSize: widget.legendDotSize,
          rowGap: widget.legendRowGap,
          labelFontSize: widget.legendLabelFontSize,
          labelWeight: FontWeight.w700,
          valueFontSize: widget.legendValueFontSize,
          valueWeight: FontWeight.w800,
          labelColor: Colors.white.withValues(alpha: 0.85),
        ),
      ],
    );
  }
}

class _RoundedPieChartBody extends StatelessWidget {
  const _RoundedPieChartBody({
    required this.segments,
    required this.centerValue,
    required this.size,
    required this.strokeWidth,
    required this.gapDegree,
    required this.startDegreeOffset,
    required this.showCenterValue,
    required this.animation,
    required this.animationDuration,
    required this.animationCurve,
    required this.fromAmounts,
    required this.toAmounts,
    required this.lerpAmounts,
  });

  final List<RoundedPieChartSegment> segments;
  final String? centerValue;
  final double size;
  final double? strokeWidth;
  final double gapDegree;
  final double startDegreeOffset;
  final bool showCenterValue;
  final Animation<double> animation;
  final Duration animationDuration;
  final Curve animationCurve;
  final List<double> fromAmounts;
  final List<double> toAmounts;
  final List<double> Function(
    List<double> from,
    List<double> to,
    double t,
    int length,
  )
  lerpAmounts;

  @override
  Widget build(BuildContext context) {
    final effectiveStrokeWidth = strokeWidth ?? size * 0.115;

    return SizedBox.square(
      dimension: size,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animationCurve.transform(animation.value);
          final animatedAmounts = lerpAmounts(
            fromAmounts,
            toAmounts,
            t,
            segments.length,
          );

          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                key: const ValueKey('rounded-pie-chart-paint'),
                size: Size.square(size),
                painter: _RoundedPieChartPainter(
                  segments: segments,
                  amounts: animatedAmounts,
                  strokeWidth: effectiveStrokeWidth,
                  visibleGapDegree: gapDegree,
                  startDegreeOffset: startDegreeOffset,
                ),
              ),
              if (showCenterValue && centerValue != null)
                AnimatedSwitcher(
                  duration: animationDuration,
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.92,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    centerValue!,
                    key: ValueKey(centerValue),
                    style: DashboardTextStyles.text(
                      fontSize: size * 0.15,
                      weight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RoundedPieChartPainter extends CustomPainter {
  const _RoundedPieChartPainter({
    required this.segments,
    required this.amounts,
    required this.strokeWidth,
    required this.visibleGapDegree,
    required this.startDegreeOffset,
  });

  final List<RoundedPieChartSegment> segments;
  final List<double> amounts;
  final double strokeWidth;
  final double visibleGapDegree;
  final double startDegreeOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty || amounts.isEmpty) return;

    final total = amounts.fold<double>(
      0,
      (sum, value) => sum + math.max(0, value),
    );

    if (total <= 0) return;

    final chartSize = math.min(size.width, size.height);
    final radius = (chartSize - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final visibleSegments = amounts.where((value) => value > 0).length;
    if (visibleSegments == 0) return;

    final capDegree = _capDegree(radius, strokeWidth);
    final compensatedGapDegree = visibleGapDegree + (capDegree * 2);
    final totalGapDegree = compensatedGapDegree * visibleSegments;
    final availableDegree = math.max(1, 360 - totalGapDegree);

    var startDegree = startDegreeOffset;

    for (var i = 0; i < segments.length; i++) {
      final amount = i < amounts.length ? math.max(0, amounts[i]) : 0.0;
      if (amount <= 0) continue;

      final sweepDegree = (amount / total) * availableDegree;
      if (sweepDegree <= 0) continue;

      paint.color = segments[i].color;
      canvas.drawArc(
        rect,
        _degreeToRadian(startDegree),
        _degreeToRadian(sweepDegree),
        false,
        paint,
      );

      startDegree += sweepDegree + compensatedGapDegree;
    }
  }

  double _capDegree(double radius, double strokeWidth) {
    if (radius <= 0) return 0;

    final capRadians = (strokeWidth / 2) / radius;
    return _radianToDegree(capRadians);
  }

  double _degreeToRadian(double degree) {
    return degree * math.pi / 180;
  }

  double _radianToDegree(double radian) {
    return radian * 180 / math.pi;
  }

  @override
  bool shouldRepaint(covariant _RoundedPieChartPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.amounts != amounts ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.visibleGapDegree != visibleGapDegree ||
        oldDelegate.startDegreeOffset != startDegreeOffset;
  }
}
