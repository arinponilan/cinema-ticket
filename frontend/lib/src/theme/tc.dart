import 'package:flutter/material.dart';

import '../app_config.dart';

class CinemaTheme {
  static const bg = Color(0xFF07070B);
  static const panel = Color(0xFF12121A);
  static const card = Color(0xFF171725);
  static const cardAlt = Color(0xFF202033);
  static const accent = Color(0xFFE2B23D);
  static const purple = Color(0xFF5F3D9B);
  static const textPrimary = Color(0xFFF6F0E5);
  static const textSecondary = Color(0xFF9A94A8);
  static const border = Color(0x26E2B23D);
  static const success = Color(0xFF3FA46A);
  static const danger = Color(0xFFE06363);
}

class TC {
  static const bg = CinemaTheme.bg;
  static const card = CinemaTheme.card;
  static const surface = CinemaTheme.cardAlt;
  static const seatAvail = Color(0xFF262639);
  static const seatSel = CinemaTheme.accent;
  static const seatBook = Color(0xFF69667A);
  static const accent = CinemaTheme.accent;
  static const textPri = CinemaTheme.textPrimary;
  static const textSec = CinemaTheme.textSecondary;
  static const textHint = Color(0xFF6D687A);
  static const success = CinemaTheme.success;
  static const purple = CinemaTheme.purple;
}

Widget cinemaBackdrop({required Widget child}) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF060609), Color(0xFF0D0D14), Color(0xFF07070B)],
      ),
    ),
    child: child,
  );
}

Widget cinemaCard({required Widget child, EdgeInsetsGeometry? padding}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CinemaTheme.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: CinemaTheme.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: child,
  );
}

Widget cinemaSectionTitle(String title, {String? subtitle}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: CinemaTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: CinemaTheme.textSecondary, fontSize: 12),
        ),
      ],
    ],
  );
}

String money(double value) {
  final amount = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < amount.length; i++) {
    final remaining = amount.length - i;
    buffer.write(amount[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'Rp $buffer';
}

String get fullApiBaseUrl => apiBaseUrl;
