import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

class NqaaeColors {
  static const page = Color(0xFFF4F5F5);
  static const text = Color(0xFF061422);
  static const muted = Color(0xFF778191);
  static const border = Color(0xFFEAEFF5);
  static const field = Color(0xFFF5F7FA);
  static const teal = Color(0xFF3C878C);
  static const blue = Color(0xFF3E7BB6);
  static const green = Color(0xFF19AE8B);
  static const gold = Color(0xFFD3BF64);

  static const gradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [green, Color(0xFF23939F), blue],
  );
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
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NqaaeColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NqaaeColors.text,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: GoogleFonts.inter(
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
        color: const Color(0xFFEDF4F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
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
        color: Colors.white,
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
        style: GoogleFonts.inter(
          color: NqaaeColors.teal,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
