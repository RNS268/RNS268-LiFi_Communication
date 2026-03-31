import 'package:flutter/material.dart';
import 'package:esp8266_controller_app/theme/app_colors.dart';

import 'package:esp8266_controller_app/services/app_controller.dart';
import 'package:esp8266_controller_app/services/prefs_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppColors get colors => AppColors(context);
  final PrefsService _prefs = PrefsService();
  final AppController _app = AppController.instance;

  final TextEditingController _nameController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _load();
    _app.currentTabIndex.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_app.currentTabIndex.value == 3) {
      _load();
    }
  }

  @override
  void dispose() {
    _app.currentTabIndex.removeListener(_onTabChanged);
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final name = await _prefs.getUserName();
    final mode = await _prefs.getThemeMode();
    if (!mounted) return;
    setState(() {
      _nameController.text = (name ?? '').trim();
      _themeMode = mode;
      _loading = false;
    });
  }

  Future<void> _saveName() async {
    if (_saving) return;
    setState(() => _saving = true);

    final name = _nameController.text.trim();
    await _prefs.setUserName(name);

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved')),
    );
  }

  Future<void> _setThemeMode(String mode) async {
    setState(() => _themeMode = mode);
    await _app.setThemeMode(mode);
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _nameController.text);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User Name', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Enter your name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: Text('Save')),
        ],
      ),
    );
    if (newName != null && newName != _nameController.text) {
      _nameController.text = newName;
      await _saveName();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator());

    final currentName = _nameController.text.isEmpty ? 'Alex' : _nameController.text;

    return Container(
      color: colors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: TextStyle(fontFamily: 'Manrope', fontSize: 36, fontWeight: FontWeight.w800, color: colors.textMain, letterSpacing: -0.5)),
                  SizedBox(height: 4),
                  Text('Configure your device and application preferences', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.textSub)),
                ],
              ),
            ),
            SizedBox(height: 32),
            _buildSectionHeader('General'),
            _buildCard(
              child: InkWell(
                onTap: _editName,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User Name', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16, color: colors.textMain)),
                            Text('$currentName (Main User)', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.textSub)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(currentName, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 16, color: colors.primary)),
                          SizedBox(width: 16),
                          Icon(Icons.chevron_right, color: colors.outline),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Display'),
            _buildCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Appearance', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16, color: colors.textMain)),
                          Text('${_themeMode[0].toUpperCase()}${_themeMode.substring(1)} Mode', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.textSub)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        children: [
                          _buildThemeButton('light', 'Light'),
                          _buildThemeButton('dark', 'Dark'),
                          _buildThemeButton('system', 'System'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            _buildSectionHeader('Account'),
            _buildCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                          child: Icon(Icons.person, color: colors.primary, size: 32),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$currentName Developer', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 18, color: colors.textMain)),
                            Text('${currentName.toLowerCase()}.iot@node.local', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.textSub)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFFDAD6),
                          foregroundColor: const Color(0xFF93000A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text('Logout', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: colors.primaryFixed.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user, color: colors.primary, size: 40),
                        SizedBox(height: 16),
                        Text('System Integrity', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 20, color: colors.textMain, leadingDistribution: TextLeadingDistribution.even, height: 1.1)),
                        SizedBox(height: 4),
                        Text('Encrypted with AES-256 standards.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.textSub)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.info, color: colors.errorFg, size: 40),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: colors.error, borderRadius: BorderRadius.circular(999)),
                              child: Text('V2.4.0', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: colors.surfaceLowest)),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text('Firmware Status', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 20, color: colors.textMain, leadingDistribution: TextLeadingDistribution.even, height: 1.1)),
                        SizedBox(height: 4),
                        Text('Up to date and running smooth.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.errorFg)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5, color: colors.primary),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: colors.surfaceLow, borderRadius: BorderRadius.circular(24)),
      child: child,
    );
  }

  Widget _buildThemeButton(String value, String label) {
    final isSelected = _themeMode == value;
    return InkWell(
      onTap: () => _setThemeMode(value),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : colors.textSub),
        ),
      ),
    );
  }
}