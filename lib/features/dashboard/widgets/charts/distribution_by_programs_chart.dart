import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../dashboard_section_card.dart';
import 'chart_legend.dart';

class ProgramDistributionItem {
  const ProgramDistributionItem({
    required this.label,
    required this.value,
    required this.amount,
    required this.color,
  });

  final String label;
  final String value;
  final double amount;
  final Color color;

  ChartLegendItem toLegendItem() {
    return ChartLegendItem(label: label, value: value, color: color);
  }
}

class DistributionByProgramsChart extends StatefulWidget {
  const DistributionByProgramsChart({
    super.key,
    this.items = defaultItems,
    this.totalLabel = 'Jami talabalar',
    this.totalValue = '13 136',
    this.size = 220,
    this.startDegreeOffset = -200,
    this.gapWidth = 4,
    this.cornerRadius = 10,
    this.centerCornerRadius = 45,
    this.centerGlowOpacity = 0.15,
    this.chartLegendGap = 28,
    this.placeholderSliceCount = 3,
    this.animateFromEqualPlaceholder = true,
    this.animationDuration = const Duration(milliseconds: 850),
    this.animationCurve = Curves.easeOutCubic,
  });

  static const defaultItems = [
    ProgramDistributionItem(
      label: 'Amaliy fanlar',
      value: '5 842',
      amount: 5842,
      color: AppColors.primary,
    ),
    ProgramDistributionItem(
      label: 'Ijod (sport)',
      value: '1 588',
      amount: 1588,
      color: Color(0xFF0F6D73),
    ),
    ProgramDistributionItem(
      label: 'Ijtimoiy-gumanitar fanlar',
      value: '5 706',
      amount: 5706,
      color: AppColors.accent,
    ),
  ];

  final List<ProgramDistributionItem> items;
  final String totalLabel;
  final String totalValue;

  final double size;
  final double startDegreeOffset;
  final double gapWidth;
  final double cornerRadius;
  final double centerCornerRadius;
  final double centerGlowOpacity;
  final double chartLegendGap;

  /// Used while async data is not loaded yet.
  final int placeholderSliceCount;

  /// If true, first real render animates from equal slices to real ratio.
  final bool animateFromEqualPlaceholder;

  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<DistributionByProgramsChart> createState() =>
      _DistributionByProgramsChartState();
}

class _DistributionByProgramsChartState
    extends State<DistributionByProgramsChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late List<double> _fromAmounts;
  late List<double> _toAmounts;

  @override
  void initState() {
    super.initState();

    final initialAmounts = _amountsOf(widget.items);

    if (widget.animateFromEqualPlaceholder && initialAmounts.isNotEmpty) {
      _fromAmounts = _equalAmounts(initialAmounts.length);
      _toAmounts = initialAmounts;
      _controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      )..forward();
    } else {
      _fromAmounts = initialAmounts.isEmpty
          ? _equalAmounts(widget.placeholderSliceCount)
          : initialAmounts;
      _toAmounts = _fromAmounts;
      _controller = AnimationController(
        vsync: this,
        duration: widget.animationDuration,
        value: 1,
      );
    }
  }

  @override
  void didUpdateWidget(covariant DistributionByProgramsChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }

    final nextAmounts = _amountsOf(widget.items);

    final resolvedNextAmounts = nextAmounts.isEmpty
        ? _equalAmounts(widget.placeholderSliceCount)
        : nextAmounts;

    if (!_sameValues(_toAmounts, resolvedNextAmounts)) {
      final currentT = widget.animationCurve.transform(_controller.value);

      _fromAmounts = _lerpValues(
        _fromAmounts,
        _toAmounts,
        currentT,
        math.max(_fromAmounts.length, _toAmounts.length),
      );

      _toAmounts = resolvedNextAmounts;
      _controller.forward(from: 0);
    }
  }

  List<double> _amountsOf(List<ProgramDistributionItem> items) {
    return items.map((item) => item.amount).toList();
  }

  List<double> _equalAmounts(int count) {
    return List<double>.filled(math.max(1, count), 1);
  }

  bool _sameValues(List<double> a, List<double> b) {
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  List<double> _lerpValues(
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

  List<ProgramDistributionItem> _visibleItems() {
    if (widget.items.isNotEmpty) return widget.items;

    return List.generate(widget.placeholderSliceCount, (index) {
      return ProgramDistributionItem(
        label: '',
        value: '',
        amount: 1,
        color: _placeholderColors[index % _placeholderColors.length],
      );
    });
  }

  static const _placeholderColors = [
    AppColors.primary,
    Color(0xFF0F6D73),
    AppColors.accent,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasRealData = widget.items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox.square(
            dimension: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = widget.animationCurve.transform(_controller.value);

                final animatedAmounts = _lerpValues(
                  _fromAmounts,
                  _toAmounts,
                  t,
                  math.max(_fromAmounts.length, _toAmounts.length),
                );

                return CustomPaint(
                  size: Size.square(widget.size),
                  painter: _DistributionByProgramsPainter(
                    items: _visibleItems(),
                    animatedAmounts: animatedAmounts,
                    startDegreeOffset: widget.startDegreeOffset,
                    gapWidth: widget.gapWidth,
                    cornerRadius: widget.cornerRadius,
                    centerCornerRadius: widget.centerCornerRadius,
                    centerGlowOpacity: widget.centerGlowOpacity,
                    showLabels: hasRealData,
                    labelStyle: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: widget.size * 0.065,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        if (hasRealData) ...[
          SizedBox(height: widget.chartLegendGap),
          ChartLegend(
            totalLabel: widget.totalLabel,
            totalValue: widget.totalValue,
            items: widget.items.map((item) => item.toLegendItem()).toList(),
            dotSize: 8,
            rowGap: 12,
            labelFontSize: 12,
            labelWeight: FontWeight.w700,
            valueFontSize: 14,
            valueWeight: FontWeight.w800,
            labelColor: Colors.white.withValues(alpha: 0.82),
          ),
        ],
      ],
    );
  }
}

class _DistributionByProgramsPainter extends CustomPainter {
  const _DistributionByProgramsPainter({
    required this.items,
    required this.animatedAmounts,
    required this.startDegreeOffset,
    required this.gapWidth,
    required this.cornerRadius,
    required this.centerCornerRadius,
    required this.centerGlowOpacity,
    required this.showLabels,
    required this.labelStyle,
  });

  final List<ProgramDistributionItem> items;
  final List<double> animatedAmounts;
  final double startDegreeOffset;
  final double gapWidth;
  final double cornerRadius;
  final double centerCornerRadius;
  final double centerGlowOpacity;
  final bool showLabels;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty || animatedAmounts.isEmpty) return;

    final total = animatedAmounts.fold<double>(
      0,
      (sum, value) => sum + math.max(0, value),
    );

    if (total <= 0) return;

    final chartSize = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = chartSize * 0.48;

    final chartRect = Rect.fromCircle(center: center, radius: outerRadius);
    final labelInfos = <_PieLabelInfo>[];

    var currentDegree = startDegreeOffset;

    for (var i = 0; i < items.length; i++) {
      final amount = i < animatedAmounts.length
          ? math.max(0, animatedAmounts[i])
          : 0.0;

      if (amount <= 0) continue;

      final sweepDegree = (amount / total) * 360;

      final slicePath = _buildRoundedSeparatedSlicePath(
        center: center,
        outerRadius: outerRadius,
        startDegree: currentDegree,
        sweepDegree: sweepDegree,
      );

      canvas.drawShadow(
        slicePath,
        Colors.black.withValues(alpha: 0.16),
        4,
        false,
      );

      final paint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..shader = _sliceGradient(items[i].color, chartRect);

      canvas.drawPath(slicePath, paint);

      if (showLabels) {
        labelInfos.add(
          _PieLabelInfo(
            text: '${((items[i].amount / _realTotal()) * 100).round()}%',
            midDegree: currentDegree + sweepDegree / 2,
            sweepDegree: sweepDegree,
          ),
        );
      }

      currentDegree += sweepDegree;
    }

    _drawCenterGlow(canvas: canvas, center: center, radius: outerRadius);

    if (showLabels) {
      for (final labelInfo in labelInfos) {
        _drawLabel(
          canvas: canvas,
          center: center,
          outerRadius: outerRadius,
          info: labelInfo,
        );
      }
    }
  }

  double _realTotal() {
    return items.fold<double>(0, (sum, item) => sum + math.max(0, item.amount));
  }

  Path _buildRoundedSeparatedSlicePath({
    required Offset center,
    required double outerRadius,
    required double startDegree,
    required double sweepDegree,
  }) {
    final startRad = _degreeToRadian(startDegree);
    final sweepRad = _degreeToRadian(sweepDegree);
    final endRad = startRad + sweepRad;

    final halfGap = gapWidth / 2;

    final startUnit = _unit(startRad);
    final endUnit = _unit(endRad);

    final startTangent = _clockwiseTangent(startRad);
    final endTangent = _clockwiseTangent(endRad);

    final startOffset = center + startTangent * halfGap;
    final endOffset = center - endTangent * halfGap;

    final safeOuterIntersection = math.sqrt(
      math.max(0, outerRadius * outerRadius - halfGap * halfGap),
    );

    final startOuterCorner = startOffset + startUnit * safeOuterIntersection;
    final endOuterCorner = endOffset + endUnit * safeOuterIntersection;

    final startOuterAngle = math.atan2(
      startOuterCorner.dy - center.dy,
      startOuterCorner.dx - center.dx,
    );

    final endOuterAngle = math.atan2(
      endOuterCorner.dy - center.dy,
      endOuterCorner.dx - center.dx,
    );

    final availableOuterSweep = _positiveSweep(startOuterAngle, endOuterAngle);

    final safeCenterDistance = math.min(centerCornerRadius, outerRadius * 0.16);

    final maxCornerFromSide = math.max(
      0.0,
      safeOuterIntersection - safeCenterDistance - 2,
    );

    final maxCornerFromArc = outerRadius * availableOuterSweep * 0.26;

    final safeCornerRadius = math.max(
      0.0,
      math.min(cornerRadius, math.min(maxCornerFromSide, maxCornerFromArc)),
    );

    final cornerAngle = math.min(
      safeCornerRadius / outerRadius,
      availableOuterSweep * 0.32,
    );

    final startInner = startOffset + startUnit * safeCenterDistance;
    final endInner = endOffset + endUnit * safeCenterDistance;

    final startBeforeOuterCorner =
        startOffset + startUnit * (safeOuterIntersection - safeCornerRadius);

    final endBeforeOuterCorner =
        endOffset + endUnit * (safeOuterIntersection - safeCornerRadius);

    final outerArcStartAngle = startOuterAngle + cornerAngle;
    final outerArcEndAngle = endOuterAngle - cornerAngle;

    final outerArcStart = _pointOnCircle(
      center,
      outerRadius,
      outerArcStartAngle,
    );

    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final outerArcSweep = _positiveSweep(outerArcStartAngle, outerArcEndAngle);

    final path = Path()
      ..moveTo(startInner.dx, startInner.dy)
      ..lineTo(startBeforeOuterCorner.dx, startBeforeOuterCorner.dy)
      ..quadraticBezierTo(
        startOuterCorner.dx,
        startOuterCorner.dy,
        outerArcStart.dx,
        outerArcStart.dy,
      )
      ..arcTo(outerRect, outerArcStartAngle, outerArcSweep, false)
      ..quadraticBezierTo(
        endOuterCorner.dx,
        endOuterCorner.dy,
        endBeforeOuterCorner.dx,
        endBeforeOuterCorner.dy,
      )
      ..lineTo(endInner.dx, endInner.dy)
      ..quadraticBezierTo(center.dx, center.dy, startInner.dx, startInner.dy)
      ..close();

    return path;
  }

  Shader _sliceGradient(Color baseColor, Rect rect) {
    final lightColor = Color.lerp(baseColor, Colors.white, 0.22)!;
    final darkColor = Color.lerp(baseColor, Colors.black, 0.24)!;

    return RadialGradient(
      center: const Alignment(0, -0.05),
      radius: 0.92,
      colors: [lightColor, baseColor, darkColor],
      stops: const [0.0, 0.58, 1.0],
    ).createShader(rect);
  }

  void _drawCenterGlow({
    required Canvas canvas,
    required Offset center,
    required double radius,
  }) {
    final glowRect = Rect.fromCircle(center: center, radius: radius * 0.58);

    final glowPaint = Paint()
      ..isAntiAlias = true
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: centerGlowOpacity),
          Colors.white.withValues(alpha: centerGlowOpacity * 0.42),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(glowRect);

    canvas.drawCircle(center, radius * 0.58, glowPaint);
  }

  void _drawLabel({
    required Canvas canvas,
    required Offset center,
    required double outerRadius,
    required _PieLabelInfo info,
  }) {
    final labelRadiusFactor = info.sweepDegree < 64 ? 0.62 : 0.54;

    final labelCenter = _pointOnCircle(
      center,
      outerRadius * labelRadiusFactor,
      _degreeToRadian(info.midDegree),
    );

    final textPainter = TextPainter(
      text: TextSpan(text: info.text, style: labelStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        labelCenter.dx - textPainter.width / 2,
        labelCenter.dy - textPainter.height / 2,
      ),
    );
  }

  Offset _unit(double radian) {
    return Offset(math.cos(radian), math.sin(radian));
  }

  Offset _clockwiseTangent(double radian) {
    return Offset(-math.sin(radian), math.cos(radian));
  }

  Offset _pointOnCircle(Offset center, double radius, double radian) {
    return Offset(
      center.dx + math.cos(radian) * radius,
      center.dy + math.sin(radian) * radius,
    );
  }

  double _degreeToRadian(double degree) {
    return degree * math.pi / 180;
  }

  double _positiveSweep(double startRadian, double endRadian) {
    var sweep = endRadian - startRadian;

    while (sweep < 0) {
      sweep += math.pi * 2;
    }

    while (sweep > math.pi * 2) {
      sweep -= math.pi * 2;
    }

    return sweep;
  }

  @override
  bool shouldRepaint(covariant _DistributionByProgramsPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.animatedAmounts != animatedAmounts ||
        oldDelegate.startDegreeOffset != startDegreeOffset ||
        oldDelegate.gapWidth != gapWidth ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.centerCornerRadius != centerCornerRadius ||
        oldDelegate.centerGlowOpacity != centerGlowOpacity ||
        oldDelegate.showLabels != showLabels ||
        oldDelegate.labelStyle != labelStyle;
  }
}

class _PieLabelInfo {
  const _PieLabelInfo({
    required this.text,
    required this.midDegree,
    required this.sweepDegree,
  });

  final String text;
  final double midDegree;
  final double sweepDegree;
}
