import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_header_controls.dart';
import '../../../shared/widgets/app_screen_header.dart';
import '../../../shared/widgets/app_silver_box.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../universities/widgets/nqaae_ui.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
              shadowKey: const ValueKey('profile-header-shadow'),
              center: AppHeaderControls(
                backKey: const ValueKey('profile-header-back'),
                searchShellKey: const ValueKey('profile-search-shell'),
                notificationsKey: const ValueKey(
                  'profile-header-notifications',
                ),
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
                'PROFILE',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),

            const AppSliverBox(
              left: _horizontalPadding,
              right: _horizontalPadding,
              top: 24,
              child: Center(
                child: ProfileAvatar(size: 126, showCameraButton: true),
              ),
            ),

            const AppSliverBox(
              left: _horizontalPadding,
              right: _horizontalPadding,
              top: 28,
              child: _ProfileInfoCard(),
            ),

            AppSliverBox(
              left: _horizontalPadding,
              right: _horizontalPadding,
              top: 22,
              bottom: 42,
              child: _SaveChangesButton(onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      padding: EdgeInsets.zero,
      blurStrength: 14,
      borderWidth: 1,
      backgroundColor: Colors.white.withValues(alpha: 0.045),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProfileInfoRow(label: 'Full name', value: 'Your Name'),
          _ProfileInfoRow(label: 'Phone number', value: '+998 90 327 97 87'),
          _ProfileInfoRow(label: 'Email', value: 'youremail@email.com'),
          _ProfileInfoRow(label: 'Username', value: '@yourname', isLast: true),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.055),
                  width: 1,
                ),
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.openSans(
                color: Colors.white.withValues(alpha: 0.58),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            flex: 6,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GoogleFonts.openSans(
                color: Colors.white.withValues(alpha: 0.94),
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveChangesButton extends StatelessWidget {
  const _SaveChangesButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.gradient(style: GradientStyle.linear),
          borderRadius: BorderRadius.circular(27),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(27),
          child: InkWell(
            borderRadius: BorderRadius.circular(27),
            onTap: onPressed,
            child: Center(
              child: Text(
                'Save Changes',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
