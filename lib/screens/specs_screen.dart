import 'package:flutter/material.dart';
import 'package:esp8266_controller_app/theme/app_colors.dart';

class SpecsScreen extends StatelessWidget {
  const SpecsScreen({super.key});

  Widget _flexChild(bool isWide, int flex, Widget child) {
    return isWide ? Expanded(flex: flex, child: child) : child;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      color: colors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32).copyWith(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _flexChild(
                    isWide,
                    7,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Technical Specifications',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: colors.textMain,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Comprehensive overview of the NodeMCU ESP8266 hardware architecture and operational metrics.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: colors.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isWide) SizedBox(width: 32) else SizedBox(height: 32),
                  _flexChild(
                    isWide,
                    5,
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainer,
                              borderRadius: BorderRadius.circular(24),
                              image: const DecorationImage(
                                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA2ww7-DUoYANfb1PyQicgW97HlBe3YrF3hkqiKXdL3qEUDHM-q0L35oIrAX9te_6JrSToK1F7dUnoi5mRUa0AZhangpaf53lcNiSijtd6CR_BnJcjQmOkQilIjsIt2Z51fgncZOeeP7P42tE9k0TUTWf20kINn05f6EHx922VMTiwaQSSjr7BGXSx4l-aTcU9ARdTBrsUmNAOr6CXOM4n5zmv5HZ4LCmq8LH9EPMxZktOwnPH5_xcO5MjdDJAEm0_-z1Rp3o4xG4vX'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -16,
                          left: -16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: colors.surfaceHighest.withValues(alpha: 0.9),
                              border: Border.all(color: const Color(0xFFC1C6D4).withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HARDWARE REVISION',
                                  style: TextStyle(fontFamily: 'Manrope', fontSize: 10, fontWeight: FontWeight.bold, color: colors.primary, letterSpacing: 1.5),
                                ),
                                Text(
                                  'NodeMCU v3',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: colors.textMain),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            SizedBox(height: 48),
            // Status Grid
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                children: [
                  _flexChild(isWide, 1, _buildStatusCard(icon: Icons.monitor_heart, title: 'Health Status', value: 'Working', bgColor: colors.surfaceLowest, fgColor: colors.textMain, primaryColor: colors.primary, isLive: true)),
                  if (isWide) SizedBox(width: 16) else SizedBox(height: 16),
                  _flexChild(isWide, 1, _buildStatusCard(icon: Icons.bolt, title: 'Power Consumption', value: '3.3V / 80mA', bgColor: colors.primary, fgColor: Colors.white, primaryColor: const Color(0xFFA5C8FF), badge: 'LIVE', badgeBg: colors.primary, badgeFg: Colors.white)),
                  if (isWide) SizedBox(width: 16) else SizedBox(height: 16),
                  _flexChild(isWide, 1, _buildStatusCard(icon: Icons.wifi, title: 'Wireless Link', value: 'Connected', bgColor: colors.surfaceLow, fgColor: colors.textMain, primaryColor: colors.errorFg, badge: 'SECURE', badgeBg: colors.errorBg, badgeFg: colors.errorFg)),
                ],
              );
            }),
            SizedBox(height: 24),
            // Tech Specs Details
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.surfaceLowest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.surfaceHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.settings_input_component, color: colors.primary),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Module Capabilities', style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.bold, color: colors.textMain)),
                            Text('Internal Hardware Architecture', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.outline)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 500;
                    return Wrap(
                      spacing: 48,
                      runSpacing: 32,
                      children: [
                        _buildDetailItem(colors, 'PROTOCOL', 'WiFi Stack', '802.11 b/g/n', isWide ? constraints.maxWidth / 2 - 24 : double.infinity),
                        _buildDetailItem(colors, 'VOLTAGE', 'Operating', '3.3V Nominal', isWide ? constraints.maxWidth / 2 - 24 : double.infinity),
                        _buildDetailItem(colors, 'PROCESSOR', 'Tensilica L106', '32-bit RISC Core', isWide ? constraints.maxWidth / 2 - 24 : double.infinity),
                        _buildDetailItem(colors, 'STORAGE', 'Flash Memory', '4MB External', isWide ? constraints.maxWidth / 2 - 24 : double.infinity),
                      ],
                    );
                  }),
                  SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.only(top: 32),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.surfaceContainer))),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildTag(colors, Icons.developer_board, 'ESP-12E Module'),
                        _buildTag(colors, Icons.usb, 'CP2102 Serial'),
                        _buildTag(colors, Icons.router, 'PCB Antenna'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({required IconData icon, required String title, required String value, required Color bgColor, required Color fgColor, required Color primaryColor, bool isLive = false, String? badge, Color? badgeBg, Color? badgeFg}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: primaryColor, size: 28),
              if (isLive)
                Container(width: 12, height: 12, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle))
              else if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
                  child: Text(badge, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: badgeFg)),
                ),
            ],
          ),
          SizedBox(height: 32),
          Text(title.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: primaryColor)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.bold, color: fgColor, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(AppColors colors, String header, String title, String subtitle, double width) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: colors.outline)),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.bold, color: colors.textMain)),
          SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: colors.textSub)),
        ],
      ),
    );
  }

  Widget _buildTag(AppColors colors, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.textMain),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: colors.textMain)),
        ],
      ),
    );
  }
}