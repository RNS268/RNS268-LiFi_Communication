import 'package:flutter/material.dart';
import 'package:esp8266_controller_app/theme/app_colors.dart';

import 'package:esp8266_controller_app/models/esp_log.dart';
import 'package:esp8266_controller_app/services/app_controller.dart';
import 'package:esp8266_controller_app/services/log_service.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  AppColors get colors => AppColors(context);
  final LogService _logService = LogService();
  final AppController _app = AppController.instance;

  bool _loading = true;
  List<EspLog> _logs = const [];
  late final VoidCallback _tabListener;

  @override
  void initState() {
    super.initState();
    _loadLogs();

    _tabListener = () {
      if (_app.currentTabIndex.value == 1) {
        _loadLogs();
      }
    };
    _app.currentTabIndex.addListener(_tabListener);
  }

  @override
  void dispose() {
    _app.currentTabIndex.removeListener(_tabListener);
    super.dispose();
  }

  Future<void> _loadLogs() async {
    final logs = await _logService.getLogs();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (!mounted) return;
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  Future<void> _clear() async {
    await _logService.clearLogs();
    if (!mounted) return;
    setState(() => _logs = const []);
  }

  String _formatTimestamp(DateTime t) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[t.month - 1];
    final day = t.day;
    final hour = t.hour;
    final minute = t.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$month $day, $formattedHour:$minute $ampm';
  }

  IconData _getIconForMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('temp')) return Icons.thermostat;
    if (lower.contains('led') || lower.contains('light') || lower.contains('brightness')) return Icons.light_mode;
    if (lower.contains('wifi') || lower.contains('config')) return Icons.wifi;
    if (lower.contains('reboot')) return Icons.refresh;
    if (lower.contains('relay')) return Icons.power;
    return Icons.terminal;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.background,
      child: Column(
        children: [
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadLogs,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'History',
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 30,
                                          letterSpacing: -0.5,
                                          color: colors.textMain,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'System activity and request logs',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: colors.textSub,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildHeaderButton(Icons.filter_list, 'Filter', () {}),
                                    SizedBox(width: 8),
                                    _buildHeaderButton(Icons.delete_outline, 'Clear', _logs.isEmpty ? null : _clear),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            if (_logs.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: colors.surfaceLowest,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 24,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'No logs yet',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textSub,
                                  ),
                                ),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  color: colors.surfaceLowest,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 24,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: List.generate(_logs.length, (index) {
                                    final log = _logs[index];
                                    return Column(
                                      children: [
                                        _buildLogItem(log),
                                        if (index < _logs.length - 1)
                                          Container(
                                            height: 1,
                                            margin: const EdgeInsets.symmetric(horizontal: 20),
                                            color: colors.surfaceContainer,
                                          ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            SizedBox(height: 24),
                            if (_logs.isNotEmpty)
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: colors.surfaceContainer,
                                    foregroundColor: colors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Load More History',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, String label, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colors.textSub),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem(EspLog log) {
    final isSuccess = log.status.toLowerCase().contains('success') || log.status.toLowerCase().contains('ok');
    final isFailed = log.status.toLowerCase().contains('failed') || log.status.toLowerCase().contains('error');
    final isRealSuccess = isSuccess || !isFailed;
    
    final iconData = _getIconForMessage(log.message);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isRealSuccess
                            ? colors.primary.withValues(alpha: 0.05)
                            : colors.error.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        iconData,
                        color: isRealSuccess ? colors.primary : colors.error,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.message.isEmpty ? 'Unknown Command' : log.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: colors.textMain,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _formatTimestamp(log.timestamp),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: colors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRealSuccess
                          ? colors.error.withValues(alpha: 0.1)
                          : const Color(0xFFFFDAD6).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isRealSuccess ? 'SUCCESS' : 'FAILED',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: isRealSuccess ? colors.errorFg : colors.error,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRealSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFFDAD6),
                    ),
                    child: Icon(
                      isRealSuccess ? Icons.check_circle : Icons.cancel,
                      size: 20,
                      color: isRealSuccess ? const Color(0xFF15803D) : const Color(0xFF93000A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}