import 'package:flutter/material.dart';

import '../../core/constants/app_design.dart';
import 'searchbar.dart';
import 'glass_button.dart';

class AppHeaderControls extends StatefulWidget {
  const AppHeaderControls({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onVoiceSearch,
    required this.onBack,
    this.onNotificationsPressed,
    this.backKey,
    this.searchShellKey,
    this.notificationsKey,
    this.contentHeight = AppDesign.screenHeaderControlHeight,
    this.searchCollapsedFactor = 0.74,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onVoiceSearch;
  final VoidCallback onBack;
  final VoidCallback? onNotificationsPressed;
  final Key? backKey;
  final Key? searchShellKey;
  final Key? notificationsKey;
  final double contentHeight;
  final double searchCollapsedFactor;

  @override
  State<AppHeaderControls> createState() => _AppHeaderControlsState();
}

class _AppHeaderControlsState extends State<AppHeaderControls> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final buttonSize = widget.contentHeight;
        final availableSearchWidth =
            constraints.maxWidth - (buttonSize * 2) - (gap * 2);
        final focused = _focusNode.hasFocus;
        final collapsedSearchWidth = availableSearchWidth <= 190
            ? availableSearchWidth
            : (availableSearchWidth * widget.searchCollapsedFactor)
                  .clamp(190.0, availableSearchWidth)
                  .toDouble();
        final searchWidth = focused
            ? availableSearchWidth
            : collapsedSearchWidth;
        final searchRight = buttonSize + gap;
        final searchLeft = focused
            ? buttonSize + gap
            : constraints.maxWidth - searchRight - searchWidth;

        return SizedBox(
          height: buttonSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                left: searchLeft,
                right: searchRight,
                top: 0,
                bottom: 0,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  key: widget.searchShellKey,
                  child: DashboardSearchBar(
                    controller: widget.searchController,
                    focusNode: _focusNode,
                    onChanged: widget.onSearchChanged,
                    onRefresh: widget.onVoiceSearch,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: GlassButton(
                  key: widget.backKey,
                  tooltip: 'Back',
                  assetName: 'assets/icons/arrow-right.svg',
                  assetQuarterTurns: 2,
                  onPressed: widget.onBack,
                  width: buttonSize,
                  height: buttonSize,
                  iconSize: 18,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GlassButton(
                  key: widget.notificationsKey,
                  tooltip: 'Notifications',
                  assetName: 'assets/icons/bell.svg',
                  onPressed: widget.onNotificationsPressed,
                  width: buttonSize,
                  height: buttonSize,
                  iconSize: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
