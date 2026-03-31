import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  final files = dir.listSync().whereType<File>().toList();
  
  for (var file in files) {
    if (!file.path.endsWith('.dart')) continue;
    
    var content = file.readAsStringSync();
    
    // Insert import if absent
    if (!content.contains('app_colors.dart')) {
      content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:esp8266_controller_app/theme/app_colors.dart';");
    }
    
    // Add colors instance in build
    if (!content.contains('final colors = AppColors(context);')) {
      content = content.replaceAll('Widget build(BuildContext context) {', 'Widget build(BuildContext context) {\n    final colors = AppColors(context);');
    }
    
    // Replace consts inside classes where colors is not available (like HomeScreen static consts)
    // Wait, HomeScreen has `static const Color kBackground = ...`
    // Let's replace those static consts with getters using AppColors in HomeScreen
    if (file.path.contains('home_screen.dart')) {
      content = content.replaceAll('static const Color kPrimary = Color(0xFF005DAC);', 'Color get kPrimary => AppColors(context).primary;');
      content = content.replaceAll('static const Color kBackground = Color(0xFFF9F9FF);', 'Color get kBackground => AppColors(context).background;');
      content = content.replaceAll('static const Color kSurfaceLowest = Color(0xFFFFFFFF);', 'Color get kSurfaceLowest => AppColors(context).surfaceLowest;');
      content = content.replaceAll('static const Color kSurfaceContainer = Color(0xFFECEDF6);', 'Color get kSurfaceContainer => AppColors(context).surfaceContainer;');
      content = content.replaceAll('static const Color kSurfaceLow = Color(0xFFF2F3FC);', 'Color get kSurfaceLow => AppColors(context).surfaceLow;');
      content = content.replaceAll('static const Color kSurfaceHighest = Color(0xFFE0E2EA);', 'Color get kSurfaceHighest => AppColors(context).surfaceHighest;');
      content = content.replaceAll('static const Color kSecondary = Color(0xFF475F84);', 'Color get kSecondary => AppColors(context).textSub;'); // Map to textSub
      content = content.replaceAll('static const Color kOnSurfaceVariant = Color(0xFF414752);', 'Color get kOnSurfaceVariant => AppColors(context).textSub;');
      content = content.replaceAll('static const Color kOutline = Color(0xFF717783);', 'Color get kOutline => AppColors(context).outline;');
      content = content.replaceAll('static const Color kPrimaryFixed = Color(0xFFD4E3FF);', 'Color get kPrimaryFixed => AppColors(context).primaryFixed;');
      content = content.replaceAll('static const Color kOnPrimaryFixed = Color(0xFF001C3A);', 'Color get kOnPrimaryFixed => AppColors(context).onPrimaryFixed;');
      content = content.replaceAll('static const Color kSecondaryContainer = Color(0xFFBAD3FD);', 'Color get kSecondaryContainer => AppColors(context).primaryFixed;');
      content = content.replaceAll('static const Color kOnSecondaryContainer = Color(0xFF425B7F);', 'Color get kOnSecondaryContainer => AppColors(context).onPrimaryFixed;');
      content = content.replaceAll('static const Color kError = Color(0xFFBA1A1A);', 'Color get kError => AppColors(context).error;');
    }
    else {
      // Direct replace for settings, specs, logs
      // But we need to remove `const` before Color if we are replacing with `colors.XYZ`
      // For instance: `const Color(0xFFF9F9FF)` -> `colors.background`
      // Also without const: `Color(0xFFF9F9FF)` -> `colors.background`
      final replaces = {
        '0xFFF9F9FF': 'colors.background',
        '0xFF181C21': 'colors.textMain',
        '0xFF414752': 'colors.textSub',
        '0xFF005DAC': 'colors.primary',
        '0xFF717783': 'colors.outline',
        '0xFFF2F3FC': 'colors.surfaceLow',
        '0xFFECEDF6': 'colors.surfaceContainer',
        '0xFFE0E2EA': 'colors.surfaceHighest',
        '0xFFFFFFFF': 'colors.surfaceLowest',
        '0xFFBA1A1A': 'colors.error',
        '0xFF1976D2': 'colors.primary', // Close enough to primary
      };
      
      replaces.forEach((hex, code) {
        content = content.replaceAll('const Color($hex)', code);
        content = content.replaceAll('Color($hex)', code);
        // Also fix `const InputDecoration(...)` that might be broken if colors used
        // Actually, it's safer to just let the compiler tell us if any `const` is broken.
      });
      // Removing leftover `const` before Text or TextStyle that now uses dynamic colors...
      // E.g., `const Text('...', style: TextStyle(color: colors.primary))` is invalid.
      // E.g., `const TextStyle(color: colors.primary)` is invalid.
      final invalidConsts = RegExp(r'const\s+([A-Z][a-zA-Z0-9_]*)\([^)]*colors\.[a-zA-Z0-9_]+', multiLine: true);
      // It's a bit hard to strip all invalid consts with regex because of nested parens.
      // Let's do a fast generic strip of `const ` before `TextStyle`, `Text`, `BoxDecoration`, `Container`, `Padding`, `Icon`, `Row`, `Column`, `SizedBox`, `Expanded`, `Center`, `Border`, `BorderSide` etc in these specific files!
      
      final constWidgets = ['TextStyle', 'Text', 'BoxDecoration', 'Container', 'Padding', 'Icon', 'Row', 'Column', 'SizedBox', 'Expanded', 'Center', 'Border', 'BorderSide', 'EdgeInsets', 'IconData', 'Shadow', 'BoxShadow', 'LinearGradient', 'Radius', 'BorderRadius', 'RoundedRectangleBorder', 'InputDecoration', 'OutlineInputBorder', 'ThemeData'];
      for (var w in constWidgets) {
        content = content.replaceAll('const $w(', '$w(');
        content = content.replaceAll('const [$w(', '[$w(');
      }
    }
    
    file.writeAsStringSync(content);
  }
}
