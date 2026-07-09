import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../widgets/cupertino_liquid_pressable.dart';

class FloatingNavBarItem {
  const FloatingNavBarItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class FloatingNavBar extends StatefulWidget {
  const FloatingNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.items = defaultItems,
  });

  static const defaultItems = [
    FloatingNavBarItem(icon: Iconsax.home_2, label: 'Asosiy'),
    FloatingNavBarItem(icon: Iconsax.buildings, label: 'Universitetlar'),
    FloatingNavBarItem(icon: Iconsax.chart_2, label: 'Reyting'),
    FloatingNavBarItem(icon: Iconsax.setting_2, label: 'Sozlamalar'),
  ];

  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<FloatingNavBarItem> items;

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  static const double _navWidth = 272;
  static const double _navHeight = 74;

  static const double _horizontalPadding = 7;
  static const double _verticalPadding = 8;

  static const double _bubbleSize = 56;
  static const Duration _animationDuration = Duration(milliseconds: 430);

  late final AnimationController _controller;

  double _visualIndex = 0;
  double _animationStart = 0;
  double _animationEnd = 0;

  bool _isDragging = false;
  int? _lastDragHapticIndex;

  @override
  void initState() {
    super.initState();

    _visualIndex = _clampIndex(widget.currentIndex).toDouble();

    _controller = AnimationController(vsync: this, duration: _animationDuration)
      ..addListener(_handleAnimationTick);
  }

  @override
  void didUpdateWidget(covariant FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.isEmpty) {
      _visualIndex = 0;
      return;
    }

    _visualIndex = _clampVisualIndex(_visualIndex);

    if (!_isDragging && widget.currentIndex != oldWidget.currentIndex) {
      _animateBubbleTo(_clampIndex(widget.currentIndex).toDouble());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleAnimationTick);
    _controller.dispose();
    super.dispose();
  }

  void _handleAnimationTick() {
    final curvedValue = Curves.easeOutCubic.transform(_controller.value);

    setState(() {
      _visualIndex = lerpDouble(_animationStart, _animationEnd, curvedValue)!;
    });
  }

  int _clampIndex(int index) {
    if (widget.items.isEmpty) return 0;
    return index.clamp(0, widget.items.length - 1).toInt();
  }

  double _clampVisualIndex(double index) {
    if (widget.items.isEmpty) return 0;
    return index.clamp(0.0, (widget.items.length - 1).toDouble()).toDouble();
  }

  void _animateBubbleTo(
    double target, {
    Duration duration = _animationDuration,
  }) {
    target = _clampVisualIndex(target);

    _controller.stop();

    _animationStart = _visualIndex;
    _animationEnd = target;
    _controller.duration = duration;

    if ((_animationStart - _animationEnd).abs() < 0.001) {
      setState(() {
        _visualIndex = target;
      });
      return;
    }

    _controller.forward(from: 0);
  }

  void _handleTap(int index) {
    final targetIndex = _clampIndex(index);
    final currentIndex = _clampIndex(widget.currentIndex);

    if (targetIndex == currentIndex &&
        (_visualIndex - targetIndex).abs() < 0.001) {
      return;
    }

    HapticFeedback.selectionClick();

    _animateBubbleTo(targetIndex.toDouble());
    widget.onTap?.call(targetIndex);
  }

  void _startDrag(DragStartDetails details, double navWidth) {
    _isDragging = true;
    _controller.stop();

    _lastDragHapticIndex = _clampIndex(_visualIndex.round());
    _updateDragPosition(details.localPosition.dx, navWidth);
  }

  void _updateDrag(DragUpdateDetails details, double navWidth) {
    _updateDragPosition(details.localPosition.dx, navWidth);
  }

  void _updateDragPosition(double localDx, double navWidth) {
    if (widget.items.isEmpty) return;

    final contentWidth = navWidth - (_horizontalPadding * 2);
    final itemWidth = contentWidth / widget.items.length;

    final localContentX = (localDx - _horizontalPadding).clamp(
      0.0,
      contentWidth,
    );

    final rawIndex = (localContentX / itemWidth) - 0.5;
    final nextVisualIndex = _clampVisualIndex(rawIndex);

    final nearestIndex = _clampIndex(nextVisualIndex.round());

    if (_lastDragHapticIndex != nearestIndex) {
      _lastDragHapticIndex = nearestIndex;
      HapticFeedback.selectionClick();
    }

    setState(() {
      _visualIndex = nextVisualIndex;
    });
  }

  void _endDrag() {
    if (widget.items.isEmpty) return;

    _isDragging = false;

    final targetIndex = _clampIndex(_visualIndex.round());
    final currentIndex = _clampIndex(widget.currentIndex);

    _animateBubbleTo(
      targetIndex.toDouble(),
      duration: const Duration(milliseconds: 360),
    );

    if (targetIndex != currentIndex) {
      widget.onTap?.call(targetIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeCurrentIndex = _clampIndex(widget.currentIndex);

    return SafeArea(
      minimum: const EdgeInsets.only(left: 14, right: 14, bottom: 6),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: _navWidth,
              height: _navHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final navWidth = constraints.maxWidth;
                  final navHeight = constraints.maxHeight;

                  final contentWidth = navWidth - (_horizontalPadding * 2);
                  final itemWidth = contentWidth / widget.items.length;

                  final fractional =
                      (_visualIndex - _visualIndex.floorToDouble()).abs();

                  final morphAmount = sin(fractional * pi).abs();

                  final bubbleWidth = _bubbleSize + (18 * morphAmount);
                  final bubbleHeight = _bubbleSize - (2 * morphAmount);

                  final bubblePaintWidth = bubbleWidth + 34;
                  final bubblePaintHeight = _bubbleSize + 28;

                  final bubbleCenterX =
                      _horizontalPadding + itemWidth * (_visualIndex + 0.5);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (details) {
                      _startDrag(details, navWidth);
                    },
                    onHorizontalDragUpdate: (details) {
                      _updateDrag(details, navWidth);
                    },
                    onHorizontalDragEnd: (_) {
                      _endDrag();
                    },
                    onHorizontalDragCancel: _endDrag,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: bubbleCenterX - (bubblePaintWidth / 2),
                          top: (navHeight - bubblePaintHeight) / 2,
                          width: bubblePaintWidth,
                          height: bubblePaintHeight,
                          child: Center(
                            child: _LiquidNavBubble(
                              width: bubbleWidth,
                              height: bubbleHeight,
                              morphAmount: morphAmount,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          left: _horizontalPadding,
                          right: _horizontalPadding,
                          top: _verticalPadding,
                          bottom: _verticalPadding,
                          child: Row(
                            children: [
                              for (final entry in widget.items.indexed)
                                Expanded(
                                  child: _FloatingNavBarButton(
                                    item: entry.$2,
                                    selected: entry.$1 == safeCurrentIndex,
                                    selectedAmount: _selectedAmountFor(
                                      entry.$1,
                                    ),
                                    onTap: () => _handleTap(entry.$1),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _selectedAmountFor(int index) {
    final distance = (_visualIndex - index).abs().clamp(0.0, 1.0);
    return 1.0 - distance;
  }
}

class _LiquidNavBubble extends StatelessWidget {
  const _LiquidNavBubble({
    required this.width,
    required this.height,
    required this.morphAmount,
  });

  final double width;
  final double height;
  final double morphAmount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.32),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 7),
            ),
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.16),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: CustomPaint(
              painter: _LiquidBubblePainter(morphAmount: morphAmount),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.96),
                      AppColors.accent.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidBubblePainter extends CustomPainter {
  const _LiquidBubblePainter({required this.morphAmount});

  final double morphAmount;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.height / 2);
    final rrect = RRect.fromRectAndRadius(rect.deflate(0.4), radius);

    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.65, -0.75),
        radius: 1.1 + (morphAmount * 0.15),
        colors: [
          Colors.white.withValues(alpha: 0.34),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.00),
        ],
        stops: const [0.0, 0.46, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, highlightPaint);

    final borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.44),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.02),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..isAntiAlias = true;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidBubblePainter oldDelegate) {
    return oldDelegate.morphAmount != morphAmount;
  }
}

class _FloatingNavBarButton extends StatelessWidget {
  const _FloatingNavBarButton({
    required this.item,
    required this.selected,
    required this.selectedAmount,
    required this.onTap,
  });

  final FloatingNavBarItem item;
  final bool selected;
  final double selectedAmount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = Color.lerp(
      Colors.white.withValues(alpha: 0.72),
      Colors.white,
      selectedAmount,
    )!;

    final selectedScale = lerpDouble(1.0, 1.13, selectedAmount)!;
    final yOffset = lerpDouble(0, -1.5, selectedAmount)!;

    return Tooltip(
      message: item.label,
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: CupertinoLiquidPressable(
          onTap: onTap,
          scale: 0.94,
          enableHaptics: false,
          child: Center(
            child: Transform.translate(
              offset: Offset(0, yOffset),
              child: Transform.scale(
                scale: selectedScale,
                child: Icon(item.icon, color: iconColor, size: 26),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
