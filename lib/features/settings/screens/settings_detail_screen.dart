import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/app_header_controls.dart';
import '../../../shared/widgets/app_screen_header.dart';
import '../../../shared/widgets/app_silver_box.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../universities/widgets/nqaae_ui.dart';

class SettingsDetailScreen extends StatefulWidget {
  const SettingsDetailScreen({super.key, required this.title});

  final String title;

  @override
  State<SettingsDetailScreen> createState() => _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends State<SettingsDetailScreen> {
  static const double _horizontalPadding = 18;

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NqaaeBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            AppScreenHeader(
              horizontalPadding: _horizontalPadding,
              shadowKey: ValueKey('${widget.title}-header-shadow'),
              center: AppHeaderControls(
                backKey: ValueKey('${widget.title}-header-back'),
                searchShellKey: ValueKey('${widget.title}-search-shell'),
                notificationsKey: ValueKey('${widget.title}-notifications'),
                searchController: _searchController,
                onSearchChanged: (_) {},
                onVoiceSearch: () {},
                onBack: _handleBack,
              ),
            ),

            AppSliverBox(
              left: _horizontalPadding,
              right: _horizontalPadding,
              top: 34,
              child: Text(
                widget.title.toUpperCase(),
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),

            AppSliverBox(
              left: _horizontalPadding,
              right: _horizontalPadding,
              top: 18,
              bottom: 42,
              child: GlassCard(
                width: double.infinity,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                blurStrength: 14,
                borderWidth: 1,
                backgroundColor: Colors.white.withValues(alpha: 0.045),
                child: Text(
                  '${widget.title} screen content goes here.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
