import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:esp8266_controller_app/theme/app_colors.dart';
import 'package:flutter/services.dart';

import 'package:esp8266_controller_app/models/esp_log.dart';
import 'package:esp8266_controller_app/services/esp_service.dart';
import 'package:esp8266_controller_app/services/log_service.dart';
import 'package:esp8266_controller_app/services/prefs_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppColors get colors => AppColors(context);
  final _ipController = TextEditingController();
  final _messageController = TextEditingController();
  final EspService _espService = EspService();
  final LogService _logService = LogService();
  final PrefsService _prefsService = PrefsService();

  bool _isSending = false;
  bool _isCheckingConnection = false;
  bool? _isConnected;
  String _userName = 'Alex';
  int _userAge = 18;
  bool _hasInputs = false;

  // Design Colors from HTML
  Color get kPrimary => AppColors(context).primary;
  Color get kBackground => AppColors(context).background;
  Color get kSurfaceLowest => AppColors(context).surfaceLowest;
  Color get kSurfaceContainer => AppColors(context).surfaceContainer;
  Color get kSurfaceLow => AppColors(context).surfaceLow;
  Color get kSurfaceHighest => AppColors(context).surfaceHighest;
  Color get kSecondary => AppColors(context).textSub;
  Color get kOnSurfaceVariant => AppColors(context).textSub;
  Color get kOutline => AppColors(context).outline;
  Color get kPrimaryFixed => AppColors(context).primaryFixed;
  Color get kOnPrimaryFixed => AppColors(context).onPrimaryFixed;
  Color get kSecondaryContainer => AppColors(context).primaryFixed;
  Color get kOnSecondaryContainer => AppColors(context).onPrimaryFixed;
  Color get kError => AppColors(context).error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _ipController.addListener(_recomputeInputs);
    _messageController.addListener(_recomputeInputs);
  }

  void _recomputeInputs() {
    final hasIp = _ipController.text.trim().isNotEmpty;
    final hasMsg = _messageController.text.trim().isNotEmpty;
    final hasInputs = hasIp && hasMsg;
    if (hasInputs != _hasInputs) {
      setState(() => _hasInputs = hasInputs);
    }
    if (_isConnected != null && _ipController.text.trim().isEmpty) {
      setState(() => _isConnected = null);
    }
  }

  Future<void> _loadUserProfile() async {
    final name = await _prefsService.getUserName();
    final age = await _prefsService.getUserAge();
    
    if (name == null || age == null || name.trim().isEmpty) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSetupDialog();
      });
    } else {
      if (!mounted) return;
      setState(() {
        _userName = name.trim();
        _userAge = age;
      });
    }
  }

  Future<void> _showSetupDialog() async {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Welcome to LiFi', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please set up your profile to continue.', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: ageCtrl,
                  decoration: const InputDecoration(labelText: 'Your Age', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (int.tryParse(v.trim()) == null) return 'Invalid age';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final name = nameCtrl.text.trim();
                  final age = int.parse(ageCtrl.text.trim());
                  await _prefsService.setUserName(name);
                  await _prefsService.setUserAge(age);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  setState(() {
                    _userName = name;
                    _userAge = age;
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    if (_isCheckingConnection) return;

    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;

    setState(() {
      _isCheckingConnection = true;
      _isConnected = null;
    });

    final status = await _espService.checkConnection(ip);

    if (!mounted) return;
    setState(() {
      _isCheckingConnection = false;
      _isConnected = status == 'Connected';
    });
  }

  Future<void> _send() async {
    if (_isSending) return;

    final ip = _ipController.text.trim();
    final message = _messageController.text;

    if (_userAge < 18) {
      final msgLower = message.toLowerCase();
      final blockedWords = ['fuck', 'shit', 'bitch', 'ass', 'porn', 'sex', 'crap', 'damn'];
      for (final word in blockedWords) {
        if (msgLower.contains(word)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message blocked due to age restriction')),
          );
          return;
        }
      }
    }

    setState(() {
      _isSending = true;
    });

    final result = await _espService.sendData(ip, message);
    await _logService.saveLog(
      EspLog(message: message, timestamp: DateTime.now(), status: result),
    );

    if (!mounted) return;
    setState(() {
      _isSending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Note: We don't use a nested Scaffold here to avoid layout conflicts with main.dart's Scaffold
    return Container(
      color: kBackground,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 40),
              _buildBentoGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      return Flex(
        direction: isWide ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: kSecondary,
                ),
              ),
              Text(
                'Hello, $_userName',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  fontSize: 48,
                  height: 1.1,
                  letterSpacing: -1.2,
                  color: colors.textMain,
                ),
              ),
            ],
          ),
          if (!isWide) const SizedBox(height: 24),
          _buildStatusChip(),
        ],
      );
    });
  }

  Widget _buildStatusChip() {
    final String label;
    final Color dotColor;
    final bool isAnimating;

    if (_isCheckingConnection) {
      label = 'CHECKING';
      dotColor = kPrimary;
      isAnimating = true;
    } else if (_isConnected == true) {
      label = 'CONNECTED';
      dotColor = const Color(0xFF2E7D32);
      isAnimating = false;
    } else {
      label = 'DISCONNECTED';
      dotColor = kError;
      isAnimating = true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: kSurfaceLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(color: dotColor, isAnimating: isAnimating),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: kOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Column(
          children: [
            if (isWide)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _buildConnectionCard()),
                    const SizedBox(width: 24),
                    Expanded(flex: 7, child: _buildTransmissionCard(isWide: true)),
                  ],
                ),
              )
            else ...[
              _buildConnectionCard(),
              const SizedBox(height: 24),
              _buildTransmissionCard(isWide: false),
            ],
            const SizedBox(height: 24),
            _buildHardwareSpecsCard(),
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        );
      },
    );
  }

  Widget _buildConnectionCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kSurfaceLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kSurfaceContainer.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryFixed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.router, color: kOnPrimaryFixed, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Device Connection',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: colors.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'IP ADDRESS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: kOutline,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ipController,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kPrimary,
            ),
            decoration: InputDecoration(
              hintText: '192.168.1.100',
              filled: true,
              fillColor: kSurfaceHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isCheckingConnection ? null : _checkConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: kPrimary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: EdgeInsets.zero,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimary, Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isCheckingConnection)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.surfaceLowest),
                      )
                    else
                      const Icon(Icons.sensors, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Connect',
                      style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransmissionCard({required bool isWide}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kSurfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kSurfaceHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.swap_horiz, color: kPrimary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Data Transmission',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: colors.textMain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isWide)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kSecondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'SYSTEM STATUS  ',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: kOnSecondaryContainer,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Ready',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: kOnSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 180, // Fixed height to prevent layout crash in SingleChildScrollView
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSurfaceLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.surfaceLowest.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMMAND',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: kOutline,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: 'Enter ESP8266 AT commands or JSON payloads...',
                      hintStyle: TextStyle(fontSize: 13, color: kOutline),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isSending || !_hasInputs) ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [kPrimary, Color(0xFF1976D2)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSending)
                            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.surfaceLowest))
                          else
                            const Icon(Icons.send, size: 18),
                          const SizedBox(width: 10),
                          const Text('Send', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kSurfaceHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: Icon(Icons.delete, color: kOnSurfaceVariant),
                  onPressed: () {
                    _messageController.clear();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareSpecsCard() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDXPjHTRgWIplUvBMs4Q0VBP0_bk1as5jWCSt4OPAWZ_Uj4q5OXK-XesUOFVv0KKUfqeVb5e4_oHb4upiwNQHHacbJ1lw7Q3H6yBgyS2aJYiZ983qwMwoH3pz36DpSp1Ae1hbtcDVTL5p1hXjUxmPQzSKbFoiWkFhh7G3nKmGq4YsjU9Auxysn24BeFGqEbnv8RjxqQZ9TZhW57_MyKb26DybN6aezQ1c6y8p8F8m8J9hB7SDfHvEJAUa4b8od2QxacilZyj7pZ6O0m'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            top: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: Colors.black.withValues(alpha: 0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hardware Specs',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          color: colors.surfaceLowest,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'L106 32-bit RISC microprocessor core based on the Tensilica Xtensa Diamond Standard 106Micro running at 80 MHz.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: colors.surfaceLowest.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
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
}

class _PulseDot extends StatefulWidget {
  final Color color;
  final bool isAnimating;

  const _PulseDot({required this.color, required this.isAnimating});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: widget.isAnimating ? (0.4 + 0.6 * _controller.value) : 1.0),
            shape: BoxShape.circle,
            boxShadow: [
              if (widget.isAnimating)
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4 * (1 - _controller.value)),
                  spreadRadius: 4 * _controller.value,
                  blurRadius: 4 * _controller.value,
                ),
            ],
          ),
        );
      },
    );
  }
}