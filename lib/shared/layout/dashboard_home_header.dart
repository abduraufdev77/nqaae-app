import 'package:flutter/material.dart';

import '../widgets/glass_button.dart';
import '../widgets/searchbar.dart';

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
          width: 72,
          height: 72,
          child: Image.asset('assets/images/university-logo.png'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
            onRefresh: onVoiceSearch,
          ),
        ),
        const SizedBox(width: 12),
        GlassButton(
          key: const ValueKey('dashboard-header-notifications'),
          tooltip: 'Notifications',
          assetName: 'assets/icons/bell.svg',
          onPressed: onNotificationsPressed,
          width: 46,
          height: 46,
          iconSize: 20,
        ),
      ],
    );
  }
}
