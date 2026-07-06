import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class DashboardSectionChips extends StatefulWidget {
  const DashboardSectionChips({
    super.key,
    this.items = const ['Overview', 'Students', 'Research', 'Rating'],
    this.initialIndex = 0,
    this.onChanged,
  });

  final List<String> items;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  @override
  State<DashboardSectionChips> createState() => _DashboardSectionChipsState();
}

class _DashboardSectionChipsState extends State<DashboardSectionChips> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _select(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    widget.onChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 22),
        itemBuilder: (context, index) {
          final label = widget.items[index];
          final selected = index == _selectedIndex;

          return GestureDetector(
            key: ValueKey(
              selected
                  ? 'dashboard-chip-$label-selected'
                  : 'dashboard-chip-$label',
            ),
            behavior: HitTestBehavior.opaque,
            onTap: () => _select(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: 48,
              constraints: const BoxConstraints(minWidth: 116),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.dashboardChipSelected
                    : AppColors.dashboardChip,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                label,
                maxLines: 1,
                style: GoogleFonts.openSans(
                  color: Colors.white.withValues(alpha: selected ? 1 : 0.78),
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
