import 'package:flutter/material.dart';

import 'package:esp8266_controller_app/services/app_controller.dart';

import 'screens/home_screen.dart';
import 'screens/logs_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/specs_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AppController _app = AppController.instance;

  @override
  void initState() {
    super.initState();
    _app.loadThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _app.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF005DAC),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF005DAC),
            brightness: Brightness.dark,
          ),
          home: const MainScaffold(),
        );
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;
  final AppController _app = AppController.instance;

  static const _screens = <Widget>[
    HomeScreen(),
    LogsScreen(),
    SpecsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine dynamic colors based on current theme mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111418) : const Color(0xFFF9F9FF);
    final surfaceColor = isDark ? const Color(0xFF1B1E24) : const Color(0xFFECEDF6);
    final textMain = isDark ? Colors.white : const Color(0xFF005DAC);
    final textSub = isDark ? const Color(0xFFC4C6D0) : const Color(0xFF44474E);
    final indicatorColor = isDark ? const Color(0xFF00325B) : const Color(0xFFD4E3FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        title: Row(
          children: [
            const Icon(Icons.memory, color: Color(0xFF005DAC)),
            const SizedBox(width: 12),
            Text(
              'LiFi',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: textMain,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: surfaceColor,
            height: 1.0,
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF005DAC).withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBar(
            backgroundColor: bgColor,
            indicatorColor: indicatorColor,
            surfaceTintColor: Colors.transparent,
            selectedIndex: _index,
            onDestinationSelected: (i) {
              _app.currentTabIndex.value = i;
              setState(() => _index = i);
            },
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? textMain : textSub,
              );
            }),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.history_edu_outlined), selectedIcon: Icon(Icons.history_edu), label: 'Logs'),
              NavigationDestination(icon: Icon(Icons.settings_input_component_outlined), selectedIcon: Icon(Icons.settings_input_component), label: 'Specs'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}

