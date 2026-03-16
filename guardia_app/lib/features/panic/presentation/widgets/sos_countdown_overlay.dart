import 'dart:async';

import 'package:flutter/material.dart';

class SosCountdownOverlay extends StatefulWidget {

  const SosCountdownOverlay({
    required this.onCancel,
    required this.onConfirm,
    required this.onPinCompleted,
    super.key,
  });
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Future<bool> Function(String pin) onPinCompleted;

  @override
  State<SosCountdownOverlay> createState() => _SosCountdownOverlayState();
}

class _SosCountdownOverlayState extends State<SosCountdownOverlay> {
  int _secondsRemaining = 5;
  Timer? _timer;
  Timer? _confirmTimer;
  String _enteredPin = '';
  bool _isSubmittingPin = false;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cancelled) {
        timer.cancel();
        return;
      }

      if (_enteredPin.length == 4) {
        if (!_isSubmittingPin) {
          unawaited(_trySubmitPin());
        }
        return;
      }

      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining == 0) {
          timer.cancel();
          _scheduleConfirmIfNeeded();
        }
      }
    });
  }

  void _scheduleConfirmIfNeeded() {
    _confirmTimer?.cancel();
    // Grace period of 1.5s after countdown ends — gives user time to enter the final digit.
    _confirmTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_cancelled) {
        return;
      }

      // Don't confirm if user is mid-entry (any digit entered) or submitting.
      if (_isSubmittingPin || _enteredPin.isNotEmpty) {
        _scheduleConfirmIfNeeded();
        return;
      }

      widget.onConfirm();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confirmTimer?.cancel();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
      });

      if (_enteredPin.length == 4) {
        _confirmTimer?.cancel();
        unawaited(_trySubmitPin());
      }
    }
  }

  Future<void> _trySubmitPin() async {
    if (_isSubmittingPin || _enteredPin.length != 4 || _cancelled) {
      return;
    }

    _isSubmittingPin = true;
    final cachedPin = _enteredPin;
    final isValid = await widget.onPinCompleted(cachedPin);
    _isSubmittingPin = false;

    if (!mounted) {
      return;
    }

    if (isValid) {
      _cancelled = true;
      _timer?.cancel();
      widget.onCancel();
      return;
    }

    setState(() {
      _enteredPin = '';
    });

    if (_secondsRemaining == 0 && !_cancelled) {
      _scheduleConfirmIfNeeded();
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty && !_isSubmittingPin) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _onCancelPressed() {
    if (_isSubmittingPin) {
      return;
    }

    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF5C5C),
            Color(0xFFD63D3D),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 48),
              const Text(
                'SOS Triggering Soon',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'If this is accidental, enter your Emergency PIN to cancel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$_secondsRemaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'EMERGENCY PIN',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? Colors.white : Colors.white.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              _buildKeypad(),
              const SizedBox(height: 24),
              const Text(
                'SOS will activate automatically if no action is taken.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Enter PIN to cancel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map(_buildKey).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map(_buildKey).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map(_buildKey).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey('CLEAR', isSpecial: true, onTap: _onDeletePressed),
            _buildKey('0'),
            _buildKey('CANCEL', isSpecial: true, onTap: _onCancelPressed),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String label, {bool isSpecial = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => _onNumberPressed(label),
      child: Container(
        width: 100,
        height: 56,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSpecial ? 14 : 24,
              fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
