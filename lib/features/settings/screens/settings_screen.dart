import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_header_controls.dart';
import '../../../shared/widgets/app_screen_header.dart';
import '../../../shared/widgets/app_silver_box.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../profile/widgets/profile_avatar.dart';

enum _SettingsLanguage {
  en,
  ru,
  uz;

  String get flag {
    switch (this) {
      case _SettingsLanguage.en:
        return '🇬🇧';
      case _SettingsLanguage.ru:
        return '🇷🇺';
      case _SettingsLanguage.uz:
        return '🇺🇿';
    }
  }

  String get title {
    switch (this) {
      case _SettingsLanguage.en:
        return 'English';
      case _SettingsLanguage.ru:
        return 'Русский';
      case _SettingsLanguage.uz:
        return 'O‘zbek';
    }
  }

  String get shortTitle {
    switch (this) {
      case _SettingsLanguage.en:
        return 'ENG';
      case _SettingsLanguage.ru:
        return 'RU';
      case _SettingsLanguage.uz:
        return 'UZ';
    }
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onVoiceSearch,
    required this.onBack,
    this.onProfileTap,
    this.onLogout,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onVoiceSearch;
  final VoidCallback onBack;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogout;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const double _horizontalPadding = 18;

  bool _pauseNotifications = true;
  bool _darkMode = false;
  _SettingsLanguage _language = _SettingsLanguage.uz;

  bool get _isIos {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  void _openProfile() {
    if (widget.onProfileTap != null) {
      widget.onProfileTap!();
      return;
    }

    context.push('/profile');
  }

  void _openGeneralSettings() {
    context.push('/settings/general');
  }

  void _openMyContact() {
    context.push('/settings/contact');
  }

  void _openFaq() {
    context.push('/settings/faq');
  }

  void _openTerms() {
    context.push('/settings/terms');
  }

  void _openUserPolicy() {
    context.push('/settings/policy');
  }

  Future<void> _openLanguagePicker() async {
    final picked = _isIos
        ? await _showCupertinoLanguageSheet()
        : await _showMaterialLanguageSheet();

    if (!mounted || picked == null) return;

    setState(() {
      _language = picked;
    });
  }

  Future<_SettingsLanguage?> _showCupertinoLanguageSheet() {
    return showCupertinoModalPopup<_SettingsLanguage>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            'Choose language',
            style: GoogleFonts.openSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            for (final language in _SettingsLanguage.values)
              CupertinoActionSheetAction(
                isDefaultAction: language == _language,
                onPressed: () => Navigator.of(context).pop(language),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(language.flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text(
                      language.title,
                      style: GoogleFonts.openSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.openSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<_SettingsLanguage?> _showMaterialLanguageSheet() {
    return showModalBottomSheet<_SettingsLanguage>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: GlassCard(
              borderRadius: const BorderRadius.all(Radius.circular(28)),
              padding: EdgeInsets.zero,
              blurStrength: 18,
              borderWidth: 1,
              backgroundColor: const Color(0xFF12353D).withValues(alpha: 0.96),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose language',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    for (final language in _SettingsLanguage.values) ...[
                      _LanguageOptionTile(
                        language: language,
                        isSelected: language == _language,
                        onTap: () => Navigator.of(context).pop(language),
                      ),
                      if (language != _SettingsLanguage.values.last)
                        const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    if (widget.onLogout == null) return;

    if (_isIos) {
      final shouldLogout = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(
              'Log out?',
              style: GoogleFonts.openSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            message: Text(
              'Are you sure you want to log out?',
              style: GoogleFonts.openSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Log Out',
                  style: GoogleFonts.openSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.openSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      );

      if (shouldLogout == true) widget.onLogout!();
      return;
    }

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) widget.onLogout!();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          AppScreenHeader(
            horizontalPadding: _horizontalPadding,
            shadowKey: const ValueKey('settings-header-shadow'),
            center: AppHeaderControls(
              backKey: const ValueKey('settings-header-back'),
              searchShellKey: const ValueKey('settings-search-shell'),
              notificationsKey: const ValueKey('settings-header-notifications'),
              searchController: widget.searchController,
              onSearchChanged: widget.onSearchChanged,
              onVoiceSearch: widget.onVoiceSearch,
              onBack: widget.onBack,
            ),
          ),

          AppSliverBox(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: 34,
            child: Text(
              'SETTINGS',
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),

          AppSliverBox(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: 18,
            child: _ProfileSummaryCard(onTap: _openProfile),
          ),

          AppSliverBox(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: 14,
            child: _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.notifications_off_outlined,
                  title: 'Pause notifications',
                  onTap: () {
                    setState(() {
                      _pauseNotifications = !_pauseNotifications;
                    });
                  },
                  trailing: _SettingsSwitch(
                    value: _pauseNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pauseNotifications = value;
                      });
                    },
                  ),
                ),
                _SettingsRow(
                  icon: Icons.tune,
                  title: 'General settings',
                  showChevron: true,
                  onTap: _openGeneralSettings,
                ),
              ],
            ),
          ),

          AppSliverBox(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: 14,
            child: _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark mode',
                  onTap: () {
                    setState(() {
                      _darkMode = !_darkMode;
                    });
                  },
                  trailing: _SettingsSwitch(
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                ),
                _SettingsRow(
                  icon: Icons.translate,
                  title: 'Language',
                  showChevron: true,
                  onTap: _openLanguagePicker,
                  trailing: _SettingsValueText(value: _language.shortTitle),
                ),
                _SettingsRow(
                  icon: Icons.people_outline,
                  title: 'My Contact',
                  showChevron: true,
                  onTap: _openMyContact,
                ),
              ],
            ),
          ),

          AppSliverBox(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: 14,
            child: _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.help_outline,
                  title: 'FAQ',
                  showChevron: true,
                  onTap: _openFaq,
                ),
                _SettingsRow(
                  icon: Icons.info_outline,
                  title: 'Terms of service',
                  showChevron: true,
                  onTap: _openTerms,
                ),
                _SettingsRow(
                  icon: Icons.policy_outlined,
                  title: 'User policy',
                  showChevron: true,
                  onTap: _openUserPolicy,
                ),
              ],
            ),
          ),

          AppSliverBox(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: 28,
            bottom: 118,
            child: _LogoutButton(onPressed: _confirmLogout),
          ),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(24));

    return GlassCard(
      height: 86,
      borderRadius: radius,
      padding: EdgeInsets.zero,
      blurStrength: 14,
      borderWidth: 1,
      backgroundColor: Colors.white.withValues(alpha: 0.045),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              children: [
                const ProfileAvatar(size: 54),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jaloliddin Ozodov',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '@yourname',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.openSans(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.62),
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(24));

    return GlassCard(
      borderRadius: radius,
      padding: EdgeInsets.zero,
      blurStrength: 14,
      borderWidth: 1,
      backgroundColor: Colors.white.withValues(alpha: 0.045),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 54,
                  endIndent: 16,
                  color: Colors.white.withValues(alpha: 0.055),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.showChevron = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.68),
                  size: 21,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),

                if (trailing != null) ...[const SizedBox(width: 10), trailing!],

                if (showChevron) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.58),
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsValueText extends StatelessWidget {
  const _SettingsValueText({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: GoogleFonts.openSans(
        color: Colors.white.withValues(alpha: 0.58),
        fontSize: 13,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  bool _isIos(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    if (_isIos(context)) {
      return Transform.scale(
        scale: 0.78,
        alignment: Alignment.centerRight,
        child: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.accent,
          inactiveTrackColor: const Color(0xFF3B4157),
          thumbColor: Colors.white,
        ),
      );
    }

    return Transform.scale(
      scale: 0.76,
      alignment: Alignment.centerRight,
      child: Switch(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        activeThumbColor: Colors.white,
        activeTrackColor: AppColors.accent,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFF3B4157),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final _SettingsLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.045),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(language.flag, style: const TextStyle(fontSize: 24)),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  language.title,
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.accent,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(28));
    final isEnabled = onPressed != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isEnabled ? 1 : 0.45,
      child: GlassCard(
        height: 54,
        width: double.infinity,
        borderRadius: radius,
        padding: EdgeInsets.zero,
        blurStrength: 16,
        borderWidth: 1,
        backgroundColor: Colors.white.withValues(alpha: 0.001),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.error.withValues(alpha: 0.80),
            AppColors.error.withValues(alpha: 0.80),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed,
            splashColor: AppColors.error.withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.04),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/log-out.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'Log Out',
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
