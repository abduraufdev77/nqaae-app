import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CupertinoLiquidPressable extends StatefulWidget {
  const CupertinoLiquidPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeOutCubic,
    this.enableHaptics = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;
  final Curve curve;
  final bool enableHaptics;

  @override
  State<CupertinoLiquidPressable> createState() =>
      _CupertinoLiquidPressableState();
}

class _CupertinoLiquidPressableState extends State<CupertinoLiquidPressable> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    _setPressed(true);
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _setPressed(false);
  }

  void _handleTapCancel() {
    _setPressed(false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: widget.duration,
        curve: widget.curve,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.88 : 1,
          duration: widget.duration,
          curve: widget.curve,
          child: widget.child,
        ),
      ),
    );
  }
}
