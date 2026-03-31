import 'package:flutter/material.dart';

class AppColors {
  final bool isDark;

  AppColors(BuildContext context) : isDark = Theme.of(context).brightness == Brightness.dark;

  Color get primary => isDark ? const Color(0xFF7CB9FF) : const Color(0xFF005DAC);
  Color get background => isDark ? const Color(0xFF0A0C10) : const Color(0xFFF8F9FF);
  Color get surfaceLowest => isDark ? const Color(0xFF12151B) : const Color(0xFFFFFFFF);
  Color get surfaceContainer => isDark ? const Color(0xFF1E232E) : const Color(0xFFEFF1F8);
  Color get surfaceLow => isDark ? const Color(0xFF161A22) : const Color(0xFFF3F5FC);
  Color get surfaceHighest => isDark ? const Color(0xFF282F3D) : const Color(0xFFE2E5EE);

  Color get textMain => isDark ? const Color(0xFFE2E2E6) : const Color(0xFF1A1C1E);
  Color get textSub => isDark ? const Color(0xFFA1A3AB) : const Color(0xFF43474E);
  Color get outline => isDark ? const Color(0xFF4D4D54) : const Color(0xFF73777F);

  Color get error => isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A);

  Color get primaryFixed => isDark ? const Color(0xFF004481) : const Color(0xFFD3E4FF);
  Color get onPrimaryFixed => isDark ? const Color(0xFFD3E4FF) : const Color(0xFF001C3B);

  Color get successBg => isDark ? const Color(0xFF0F3D1E) : const Color(0xFFD4FFD6);
  Color get successFg => isDark ? const Color(0xFF81FF91) : const Color(0xFF006D2A);

  Color get errorBg => isDark ? const Color(0xFF410002) : const Color(0xFFFFDAD6);
  Color get errorFg => isDark ? const Color(0xFFFFB4AB) : const Color(0xFF93000A);
}
