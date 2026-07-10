import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_cupertino_theme.dart';
import '../providers/auth_provider.dart';

enum _AuthLanguage {
  en,
  ru,
  uz;

  String get flag {
    switch (this) {
      case _AuthLanguage.en:
        return '🇬🇧';
      case _AuthLanguage.ru:
        return '🇷🇺';
      case _AuthLanguage.uz:
        return '🇺🇿';
    }
  }

  String get title {
    switch (this) {
      case _AuthLanguage.en:
        return 'English';
      case _AuthLanguage.ru:
        return 'Русский';
      case _AuthLanguage.uz:
        return 'O‘zbek';
    }
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@nqaae.uz');
  final _passwordController = TextEditingController(text: '123456');

  bool _obscurePassword = true;
  _AuthLanguage _selectedLanguage = _AuthLanguage.en;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text.trim());
  }

  Future<void> _openLanguagePicker() async {
    final picked = await showCupertinoModalPopup<_AuthLanguage>(
      context: context,
      builder: (context) {
        return AppCupertinoTheme(
          child: CupertinoActionSheet(
            title: Text(
              'Choose language',
              style: AppCupertinoTheme.titleTextStyle(),
            ),
            actions: [
              for (final language in _AuthLanguage.values)
                CupertinoActionSheetAction(
                  isDefaultAction: language == _selectedLanguage,
                  onPressed: () => Navigator.of(context).pop(language),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        language.flag,
                        style: const TextStyle(
                          fontSize: AppCupertinoTheme.flagFontSize,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        language.title,
                        style: AppCupertinoTheme.actionTextStyle(),
                      ),
                      if (language == _selectedLanguage) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          CupertinoIcons.check_mark,
                          size: 15,
                          color: CupertinoColors.activeBlue,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: AppCupertinoTheme.cancelTextStyle()),
            ),
          ),
        );
      },
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedLanguage = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      resizeToAvoidBottomInset: false,
      body: _AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = math
                  .min(math.max(constraints.maxWidth - 40, 320.0), 444.0)
                  .toDouble();

              return SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: contentWidth,
                      height: constraints.maxHeight - 42,
                      child: Column(
                        children: [
                          const _AgencyMark(),

                          const SizedBox(height: 28),

                          _LoginCard(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            authState: authState,
                            selectedLanguage: _selectedLanguage,
                            onLanguageTap: _openLanguagePicker,
                            onTogglePassword: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            onSubmit: _submit,
                          ),

                          const Spacer(),

                          Text(
                            "Ta'lim sifatini ta'minlash milliy agentligi ©",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.alexandria(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.darkGradient),
          ),
        ),

        Positioned(
          left: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.08,
              child: SvgPicture.asset(
                'assets/icons/auth/left-corner.svg',
                width: 150,
                fit: BoxFit.contain,
                alignment: Alignment.bottomLeft,
              ),
            ),
          ),
        ),

        Positioned(
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.08,
              child: SvgPicture.asset(
                'assets/icons/auth/right-corner.svg',
                width: 150,
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
              ),
            ),
          ),
        ),

        Positioned.fill(child: child),
      ],
    );
  }
}

class _AgencyMark extends StatelessWidget {
  const _AgencyMark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 68,
          height: 66,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 8),

        Text(
          "O'ZBEKISTON RESPUBLIKASI\nPREZIDENTI ADMINISTRATSIYASI HUZURIDAGI",
          textAlign: TextAlign.center,
          style: GoogleFonts.alexandria(
            color: Colors.white,
            fontSize: 9,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 13),

        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF438DD2), Color(0xFF39BC7D)],
              stops: [0.34, 0.66],
            ).createShader(bounds);
          },
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "TA'LIM SIFATINI TA'MINLASH",
              maxLines: 1,
              textAlign: TextAlign.center,
              style: GoogleFonts.alexandria(
                color: Colors.white,
                fontSize: 27,
                height: 1.06,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),

        Text(
          'MILLIY AGENTLIGI',
          textAlign: TextAlign.center,
          style: GoogleFonts.alexandria(
            color: Colors.white,
            fontSize: 27,
            height: 1.06,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.authState,
    required this.selectedLanguage,
    required this.onLanguageTap,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final AuthState authState;
  final _AuthLanguage selectedLanguage;
  final VoidCallback onLanguageTap;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _LoginGlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Xush kelibsiz',
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Foydalanuvchi nomi orqali kirish',
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),

          const SizedBox(height: 14),

          _AuthField(
            controller: emailController,
            hintText: 'Email yoki Login',
            icon: Iconsax.sms,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 10),

          _AuthField(
            controller: passwordController,
            hintText: 'Parol',
            icon: Iconsax.lock,
            obscureText: obscurePassword,
            onSubmitted: (_) => onSubmit(),
            suffix: IconButton(
              tooltip: obscurePassword
                  ? "Parolni ko'rsatish"
                  : 'Parolni yopish',
              onPressed: onTogglePassword,
              padding: EdgeInsets.zero,
              icon: Icon(
                obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                color: const Color(0xFF9AA7B9),
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: 4),

          _FieldDescription(message: authState.error),

          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.76),
              minimumSize: const Size(0, 20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Login yoki parolni unutdingizmi?',
              style: GoogleFonts.alexandria(
                fontSize: 11,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white.withValues(alpha: 0.76),
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),

          const SizedBox(height: 20),

          _GradientActionButton(
            label: 'Tizimga kirish',
            isLoading: authState.isLoading,
            onPressed: authState.isLoading ? null : onSubmit,
          ),

          const SizedBox(height: 30),

          Text(
            'Yagona identifikatsiya tizimi orqali kirish',
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 42,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF213D88),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        'assets/icons/auth/one-id-logo.svg',
                        height: 26,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      'OneID orqali kirish',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.alexandria(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const Icon(Iconsax.arrow_right_3, size: 19),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HelpChip(onTap: () {}),
              const SizedBox(width: 7),
              _LanguageChip(language: selectedLanguage, onTap: onLanguageTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginGlassPanel extends StatelessWidget {
  const _LoginGlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(20));
    const borderWidth = 0.5;

    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.38),
        Colors.white.withValues(alpha: 0.04),
        Colors.white.withValues(alpha: 0.26),
      ],
      stops: const [0, 0.5, 1],
    );

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.5, sigmaY: 15.5),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.025),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.035),
                      AppColors.accent.withValues(alpha: 0.005),
                      Colors.white.withValues(alpha: 0.012),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 22),
                child: child,
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GradientBorderPainter(
                  borderRadius: radius,
                  gradient: borderGradient,
                  strokeWidth: borderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(8));

    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        cursorColor: Colors.white,
        cursorHeight: 18,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.alexandria(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: GoogleFonts.alexandria(
            color: const Color(0xFF9AA7B9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF9AA7B9), size: 18),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: suffix,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          filled: true,
          fillColor: const Color(0xFF2156A1).withValues(alpha: 0.12),
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.09),
              width: 0.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.09),
              width: 0.6,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.18),
              width: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.alexandria(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
        ),
      ),
    );
  }
}

class _HelpChip extends StatelessWidget {
  const _HelpChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _AuthPillButton(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '?',
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Yordam',
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.language, required this.onTap});

  final _AuthLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _AuthPillButton(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(language.flag, style: const TextStyle(fontSize: 14, height: 1)),
          const SizedBox(width: 2),
          Text(
            language.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            CupertinoIcons.chevron_down,
            color: Colors.white,
            size: 12,
          ),
        ],
      ),
    );
  }
}

class _AuthPillButton extends StatelessWidget {
  const _AuthPillButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(100);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.04),
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: Colors.black.withValues(alpha: 0.03),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.34),
              width: 1.1,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _FieldDescription extends StatelessWidget {
  const _FieldDescription({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 16,
      child: Text(
        message ?? '',
        textAlign: TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.alexandria(
          color: AppColors.error,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  const _GradientBorderPainter({
    required this.borderRadius,
    required this.gradient,
    required this.strokeWidth,
  });

  final BorderRadius borderRadius;
  final Gradient gradient;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);

    final paint = Paint()
      ..isAntiAlias = true
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(borderRadius.toRRect(rect), paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return borderRadius != oldDelegate.borderRadius ||
        gradient != oldDelegate.gradient ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
