import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_design.dart';
import 'glass_card.dart';

class DashboardSearchBar extends StatefulWidget {
  const DashboardSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onRefresh,
    this.height = 46,
    this.focusNode,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onRefresh;
  final double height;
  final FocusNode? focusNode;

  @override
  State<DashboardSearchBar> createState() => _DashboardSearchBarState();
}

class _DashboardSearchBarState extends State<DashboardSearchBar> {
  late final FocusNode _internalFocusNode;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant DashboardSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldEffectiveFocusNode = oldWidget.focusNode ?? _internalFocusNode;
    if (oldEffectiveFocusNode != _effectiveFocusNode) {
      oldEffectiveFocusNode.removeListener(_handleFocusChanged);
      _effectiveFocusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChanged);
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(28));
    final focused = _effectiveFocusNode.hasFocus;

    return GlassCard(
      key: const ValueKey('dashboard-search-glass'),
      height: widget.height,
      padding: EdgeInsets.zero,
      borderRadius: radius,
      blurStrength: AppDesign.glassControlBlurStrength,
      borderWidth: AppDesign.glassControlBorderWidth,
      backgroundColor: AppDesign.glassControlBackground,
      borderColor: focused ? AppColors.accent : null,
      borderGradient: AppDesign.verticalBorderGradient,
      child: SizedBox(
        height: widget.height,
        child: Row(
          children: [
            const SizedBox(width: 14),

            SvgPicture.asset('assets/icons/search.svg', width: 20, height: 20),

            const SizedBox(width: 10),

            Expanded(
              child: Center(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _effectiveFocusNode,
                  onChanged: widget.onChanged,
                  onTapOutside: (_) {
                    _effectiveFocusNode.unfocus();
                  },
                  maxLines: 1,
                  textInputAction: TextInputAction.search,
                  cursorColor: Colors.white.withValues(alpha: 0.85),
                  cursorHeight: 20,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Search...',
                    hintStyle: GoogleFonts.openSans(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: 44,
              height: widget.height,
              child: IconButton(
                tooltip: 'Voice search',
                onPressed: widget.onRefresh,
                padding: EdgeInsets.zero,
                splashRadius: 22,
                icon: SvgPicture.asset(
                  'assets/icons/microphone.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
