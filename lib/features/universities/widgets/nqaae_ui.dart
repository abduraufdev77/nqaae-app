import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';

class NqaaeColors {
  static const page = AppColors.darkBg;
  static const text = AppColors.textDark;
  static const muted = AppColors.textDarkSecondary;
  static const border = AppColors.glassBorderDark;
  static const field = Color(0x242D86CA);
  static const teal = AppColors.accent;
  static const blue = AppColors.primary;
  static const green = AppColors.accent;
  static const gold = Color(0xFFF2C85B);
  static const card = AppColors.glassDark;

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, Color(0xFF257FAF), green],
  );
}

class NqaaeBackground extends StatelessWidget {
  const NqaaeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.darkGradient),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.darkGradient),
        child: child,
      ),
    );
  }
}

class NqaaeSection extends StatelessWidget {
  const NqaaeSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      blurStrength: 16,
      backgroundColor: AppColors.glassDark,
      padding: padding,
      borderWidth: 1,
      margin: margin,
      child: child,
    );
  }
}

class NqaaeSectionHeader extends StatelessWidget {
  const NqaaeSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NqaaeColors.text,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: NqaaeColors.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class NqaaeGradientIcon extends StatelessWidget {
  const NqaaeGradientIcon({super.key, required this.icon, this.size = 44});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: NqaaeColors.gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.48),
    );
  }
}

class NqaaePill extends StatelessWidget {
  const NqaaePill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.26)),
      ),
      child: Text(
        text,
        style: GoogleFonts.openSans(
          fontSize: 12,
          color: NqaaeColors.teal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class NqaaeLogo extends StatelessWidget {
  const NqaaeLogo({
    super.key,
    required this.sourceId,
    required this.hasLogo,
    required this.fallback,
    this.size = 50,
  });

  final int sourceId;
  final bool hasLogo;
  final String fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: NqaaeColors.border),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: !hasLogo
          ? _FallbackLogo(fallback: fallback)
          : FutureBuilder<Uint8List>(
              future: _loadLogo(sourceId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(snapshot.data!, fit: BoxFit.contain);
                }
                return _FallbackLogo(fallback: fallback);
              },
            ),
    );
  }

  static Future<Uint8List> _loadLogo(int sourceId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/universities/$sourceId/logo'),
    );
    if (response.statusCode != 200) {
      throw StateError('Logo unavailable');
    }
    return response.bodyBytes;
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.fallback});

  final String fallback;

  @override
  Widget build(BuildContext context) {
    final firstLetter = fallback.trim().isEmpty ? 'N' : fallback.trim()[0];
    return Center(
      child: Text(
        firstLetter,
        style: GoogleFonts.openSans(
          color: NqaaeColors.teal,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
