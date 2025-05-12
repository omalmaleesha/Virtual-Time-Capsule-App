import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime unlockDate;

  const CountdownTimer({
    Key? key,
    required this.unlockDate,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remainingTime;
  
  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }
  
  @override
  void dispose() {
    _timer.cancel();
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Time until unlock',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(_remainingTime.inDays, 'Days'),
              _buildSeparator(),
              _buildTimeUnit(_remainingTime.inHours % 24, 'Hours'),
              _buildSeparator(),
              _buildTimeUnit(_remainingTime.inMinutes % 60, 'Minutes'),
              _buildSeparator(),
              _buildTimeUnit(_remainingTime.inSeconds % 60, 'Seconds'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeUnit(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
