import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@nqaae.uz');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1735), Color(0xFF064644)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              left: 0,
              bottom: 0,
              child: _CornerAsset(path: 'assets/icons/left-corner.svg'),
            ),
            const Positioned(
              right: 0,
              bottom: 0,
              child: _CornerAsset(path: 'assets/icons/right-corner.svg'),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = math.min(
                    math.max(constraints.maxWidth - 48, 300.0),
                    430.0,
                  );

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 2),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: width,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const _AgencyMark(),
                                    const SizedBox(height: 26),
                                    _LoginCard(
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      obscurePassword: _obscurePassword,
                                      authState: authState,
                                      onTogglePassword: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                      onSubmit: _submit,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "Ta'lim sifatini ta'minlash milliy agentligi ©",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alexandria(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text.trim());
  }
}

class _AgencyMark extends StatelessWidget {
  const _AgencyMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            child: Image.asset('assets/images/logo.png', width: 92, height: 72),
          ),
          const SizedBox(height: 14),
          Text(
            "O'ZBEKISTON RESPUBLIKASI\nPREZIDENTI ADMINISTRATSIYASI HUZURIDAGI",
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontSize: 10,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF438DD2), Color(0xFF37B777)],
              stops: [0.3393, 0.6559],
            ).createShader(bounds),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "TA'LIM SIFATINI TA'MINLASH",
                textAlign: TextAlign.center,
                maxLines: 1,
                style: GoogleFonts.alexandria(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          Text(
            'MILLIY AGENTLIGI',
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontSize: 26,
              height: 1.12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.authState,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final AuthState authState;
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
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Foydalanuvchi nomi orqali kirish',
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13,
              fontWeight: FontWeight.w500,
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
              icon: Icon(
                obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                color: const Color(0xFF909AAE),
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _FieldDescription(message: authState.error),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.75),
              minimumSize: const Size(0, 20),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Login yoki parolni unutdingizmi?',
              style: GoogleFonts.alexandria(
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _GradientActionButton(
            label: 'Tizimga kirish',
            isLoading: authState.isLoading,
            onPressed: authState.isLoading ? null : onSubmit,
          ),
          const SizedBox(height: 32),
          Text(
            'Yagona identifikatsiya tizimi orqali kirish',
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13,
              fontWeight: FontWeight.w500,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SvgPicture.asset(
                        'assets/icons/one-id-logo.svg',
                        height: 28,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Iconsax.arrow_right_3, size: 19),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SmallChip(icon: Iconsax.support, label: 'Yordam'),
              SizedBox(width: 8),
              _LanguageChip(),
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
    const borderWidth = 0.4;
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.65),
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: 0.65),
      ],
      stops: const [0, 0.5, 1],
    );

    return SizedBox(
      width: double.infinity,
      height: 480.1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.4938, sigmaY: 15.4938),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x100C203B), Color(0x032157A1)],
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 28, 0, 24),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: _GradientBorderPainter(
                borderRadius: radius,
                gradient: borderGradient,
                strokeWidth: borderWidth,
              ),
            ),
          ),
        ],
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
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        style: GoogleFonts.alexandria(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.alexandria(
            color: const Color(0xFF909AAE),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF909AAE), size: 18),
          suffixIcon: suffix,
          filled: true,
          fillColor: const Color.fromARGB(12, 33, 86, 161),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0x24E8F5FA), width: 0.3),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0x24E8F5FA), width: 0.3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0x24E8F5FA), width: 0.3),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
        color: Colors.black.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
        color: Colors.black.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.language_circle, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            'English',
            style: GoogleFonts.alexandria(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Iconsax.arrow_down_1, color: Colors.white, size: 11),
        ],
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
        ),
      ),
    );
  }
}

class _CornerAsset extends StatelessWidget {
  const _CornerAsset({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      width: 150,
      colorFilter: ColorFilter.mode(
        Colors.white.withValues(alpha: 0.09),
        BlendMode.srcIn,
      ),
    );
  }
}
