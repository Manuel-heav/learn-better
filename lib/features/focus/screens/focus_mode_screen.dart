import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import 'dart:math' as math;

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with SingleTickerProviderStateMixin {
  bool _isRunning = false;
  bool _isBreak = false;
  bool _rainSoundsEnabled = true;
  int _minutes = 25;
  int _seconds = 0;
  int _cyclesCompleted = 0;
  int _totalCycles = 4;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Session settings
  int _focusDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  String _currentSubject = 'AI Algorithms';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else if (_minutes > 0) {
          _minutes--;
          _seconds = 59;
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _minutes = _focusDuration;
      _seconds = 0;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    if (_isBreak) {
      // Break completed, start new focus session
      setState(() {
        _isBreak = false;
        _minutes = _focusDuration;
        _seconds = 0;
      });
      _showBreakCompleteDialog();
    } else {
      // Focus session completed
      setState(() {
        _cyclesCompleted++;
      });
      _showCompletionDialog();
    }
  }

  void _startBreak(int duration) {
    setState(() {
      _isBreak = true;
      _minutes = duration;
      _seconds = 0;
    });
    _startTimer();
  }

  void _showBreakCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.coffee_rounded,
                color: AppColors.primaryBlue,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Break Over!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ready to get back to studying?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startTimer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Focus Session',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    final isLongBreak = _cyclesCompleted % 4 == 0;
    final breakDuration = isLongBreak ? _longBreakDuration : _shortBreakDuration;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Session Complete! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ve completed $_cyclesCompleted of $_totalCycles cycles.\n${isLongBreak ? 'Time for a long break!' : 'Take a short break!'}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startBreak(breakDuration);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start $breakDuration min Break',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (_cyclesCompleted >= _totalCycles) {
                  Navigator.pop(context);
                } else {
                  _resetTimer();
                }
              },
              child: Text(_cyclesCompleted >= _totalCycles ? 'Finish Study Session' : 'Skip Break'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1E3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Timer Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingRow('Focus Duration', '$_focusDuration min', () {
                _showDurationPicker('Focus', _focusDuration, (value) {
                  setSheetState(() => _focusDuration = value);
                  setState(() {
                    _focusDuration = value;
                    if (!_isBreak) {
                      _minutes = value;
                      _seconds = 0;
                    }
                  });
                });
              }),
              _buildSettingRow('Short Break', '$_shortBreakDuration min', () {
                _showDurationPicker('Short Break', _shortBreakDuration, (value) {
                  setSheetState(() => _shortBreakDuration = value);
                  setState(() => _shortBreakDuration = value);
                });
              }),
              _buildSettingRow('Long Break', '$_longBreakDuration min', () {
                _showDurationPicker('Long Break', _longBreakDuration, (value) {
                  setSheetState(() => _longBreakDuration = value);
                  setState(() => _longBreakDuration = value);
                });
              }),
              _buildSettingRow('Total Cycles', '$_totalCycles', () {
                _showCyclePicker();
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationPicker(String title, int currentValue, Function(int) onChanged) {
    final durations = [5, 10, 15, 20, 25, 30, 45, 60];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1E3A),
        title: Text('$title Duration', style: const TextStyle(color: Colors.white)),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: durations.map((d) => ChoiceChip(
            label: Text('$d min'),
            selected: currentValue == d,
            onSelected: (_) {
              onChanged(d);
              Navigator.pop(context);
            },
            selectedColor: AppColors.primaryBlue,
            labelStyle: TextStyle(
              color: currentValue == d ? Colors.white : Colors.white70,
            ),
            backgroundColor: Colors.white.withOpacity(0.1),
          )).toList(),
        ),
      ),
    );
  }

  void _showCyclePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1E3A),
        title: const Text('Total Cycles', style: TextStyle(color: Colors.white)),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [2, 3, 4, 5, 6, 8].map((c) => ChoiceChip(
            label: Text('$c'),
            selected: _totalCycles == c,
            onSelected: (_) {
              setState(() => _totalCycles = c);
              Navigator.pop(context);
            },
            selectedColor: AppColors.primaryBlue,
            labelStyle: TextStyle(
              color: _totalCycles == c ? Colors.white : Colors.white70,
            ),
            backgroundColor: Colors.white.withOpacity(0.1),
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_minutes * 60 + _seconds) / ((_isBreak ? (_minutes == _longBreakDuration ? _longBreakDuration : _shortBreakDuration) : _focusDuration) * 60);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    _isBreak ? 'BREAK TIME' : 'FOCUS MODE',
                    style: TextStyle(
                      color: _isBreak ? AppColors.success : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Subject
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (_isBreak ? AppColors.success : AppColors.primaryBlue).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isBreak ? '☕ RELAX' : 'STUDYING NOW',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _isBreak ? 'Take a Break' : _currentSubject,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),

            // Timer Circle - Flexible to take available space
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isRunning ? _pulseAnimation.value : 1.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isBreak ? AppColors.success : AppColors.primaryBlue).withOpacity(0.3),
                                  blurRadius: 60,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          // Timer circle
                          SizedBox(
                            width: 260,
                            height: 260,
                            child: CustomPaint(
                              painter: TimerPainter(
                                progress: progress,
                                isRunning: _isRunning,
                                color: _isBreak ? AppColors.success : AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          // Time display
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _minutes.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 64,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      ':',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 64,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _seconds.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 64,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isBreak ? 'BREAK' : 'FOCUS',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Cycles Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalCycles,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: index < _cyclesCompleted
                              ? AppColors.primaryBlue
                              : Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: index == _cyclesCompleted && !_isBreak
                              ? Border.all(color: AppColors.primaryBlue, width: 2)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_cyclesCompleted/$_totalCycles Cycles',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Rain Sounds Toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_queue_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Ambient',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _rainSoundsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _rainSoundsEnabled = value;
                      });
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Control Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    color: Colors.white70,
                    iconSize: 28,
                    onPressed: _resetTimer,
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _isBreak ? AppColors.success : AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isBreak ? AppColors.success : AppColors.primaryBlue).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 36,
                      ),
                      color: Colors.white,
                      onPressed: _toggleTimer,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    color: Colors.white70,
                    iconSize: 28,
                    onPressed: _showSettings,
                  ),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final bool isRunning;
  final Color color;

  TimerPainter({
    required this.progress,
    required this.isRunning,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.color != color;
}
