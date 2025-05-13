import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled/theme/app_theme.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime unlockDate;
  final bool showLabels;
  final bool showDays;
  final bool showHours;
  final bool showMinutes;
  final bool showSeconds;
  final double fontSize;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CountdownTimer({
    Key? key,
    required this.unlockDate,
    this.showLabels = true,
    this.showDays = true,
    this.showHours = true,
    this.showMinutes = true,
    this.showSeconds = true,
    this.fontSize = 24,
    this.textColor,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _remainingTime;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    _remainingTime = widget.unlockDate.difference(now);
    
    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _calculateRemainingTime();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = widget.textColor ?? Colors.white;
    final backgroundColor = widget.backgroundColor ?? Colors.white;
    final foregroundColor = widget.foregroundColor ?? AppTheme.primaryColor;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (widget.showLabels)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Time until unlock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.showDays) ...[
                _buildTimeUnit(
                  _remainingTime.inDays,
                  'Days',
                  foregroundColor,
                  textColor,
                ),
                if (widget.showDays && widget.showHours)
                  _buildSeparator(textColor),
              ],
              if (widget.showHours) ...[
                _buildTimeUnit(
                  _remainingTime.inHours % 24,
                  'Hours',
                  foregroundColor,
                  textColor,
                ),
                if (widget.showHours && widget.showMinutes)
                  _buildSeparator(textColor),
              ],
              if (widget.showMinutes) ...[
                _buildTimeUnit(
                  _remainingTime.inMinutes % 60,
                  'Minutes',
                  foregroundColor,
                  textColor,
                ),
                if (widget.showMinutes && widget.showSeconds)
                  _buildSeparator(textColor),
              ],
              if (widget.showSeconds)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: _buildTimeUnit(
                        _remainingTime.inSeconds % 60,
                        'Seconds',
                        foregroundColor,
                        textColor,
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label, Color foregroundColor, Color textColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: foregroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: foregroundColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        if (widget.showLabels) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSeparator(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
