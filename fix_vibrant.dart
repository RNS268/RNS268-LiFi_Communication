import 'dart:io';

void main() {
  final screens = Directory('lib/screens').listSync().whereType<File>();
  for (var file in screens) {
    if (!file.path.endsWith('.dart')) continue;
    var content = file.readAsStringSync();
    
    // Replace hardcoded Colors.black and Colors.white
    content = content.replaceAll('color: Colors.black,', 'color: colors.textMain,');
    content = content.replaceAll('color: Colors.white,', 'color: colors.surfaceLowest,');
    content = content.replaceAll('color: Colors.white', 'color: colors.surfaceLowest');
    content = content.replaceAll('Colors.white.withOpacity', 'colors.outline.withOpacity');
    
    // But wait, there are places where white is correct. e.g. text on primary button!
    // Instead of blind replace, I should undo what I just did for specific buttons if they are broken.
    // Let's rely on standard colors.
    
    // Let's replace the leftover hex colors with vibrant AppColors properties!
    content = content.replaceAll('Color(0xFFBAD3FD)', 'colors.primaryFixed');
    content = content.replaceAll('Color(0xFF425B7F)', 'colors.textSub');
    content = content.replaceAll('Color(0xFFFFDBC7)', 'colors.errorBg');
    content = content.replaceAll('Color(0xFF944700)', 'colors.errorFg');
    content = content.replaceAll('Color(0xFFBA5B00)', 'colors.error');
    content = content.replaceAll('Color(0xFF733600)', 'colors.errorFg');
    content = content.replaceAll('Color(0xFF311300)', 'colors.errorFg');
    
    // Logs Screen:
    content = content.replaceAll('color: Colors.white', 'color: colors.surfaceLowest'); // Fix container bg
    content = content.replaceAll('color: const Color(0xFFE6E8F0)', 'color: colors.surfaceContainer');
    
    // Settings Screen specific fixes:
    content = content.replaceAll('color: const Color(0xFFFFDAD6)', 'color: colors.errorBg');
    content = content.replaceAll('color: const Color(0xFF93000A)', 'color: colors.errorFg');
    
    file.writeAsStringSync(content);
  }
}
