import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
import 'searchbar.dart';

class DashboardHomeHeader extends StatelessWidget {
  const DashboardHomeHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onVoiceSearch,
    this.onNotificationsPressed,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onVoiceSearch;
  final VoidCallback? onNotificationsPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          height: 82,
          child: SvgPicture.asset('assets/icons/nqaae-logo.svg'),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: DashboardSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
            onRefresh: onVoiceSearch,
          ),
        ),
        const SizedBox(width: 14),
        GlassCard(
          width: 58,
          height: 58,
          padding: EdgeInsets.zero,
          borderRadius: const BorderRadius.all(Radius.circular(99)),
          backgroundColor: AppColors.dashboardSearch,
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: onNotificationsPressed,
            icon: SvgPicture.asset(
              'assets/icons/bell.svg',
              width: 25,
              height: 25,
            ),
          ),
        ),
      ],
    );
  }
}
