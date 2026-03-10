import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  bool _loading = false;
  String? _error;
  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _animController.forward();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onVerifyOtp() {
    if (_otp.length != 6) {
      setState(() => _error = 'Please enter the complete 6-digit code');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    // TODO: Integrate Firebase OTP verification here
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _loading = false);
      context.go('/');
    });
  }

  void _onResend() {
    if (_resendSeconds > 0) return;
    // TODO: Resend OTP via Firebase
    _startResendTimer();
  }

  void _onDigitChanged(int index, String value) {
    if (_error != null) setState(() => _error = null);
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-verify when all 6 digits are entered
    if (_otp.length == 6) {
      _onVerifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final h = MediaQuery.sizeOf(context).height;
    final masked = widget.phoneNumber.length >= 4
        ? '${'•' * (widget.phoneNumber.length - 4)}${widget.phoneNumber.substring(widget.phoneNumber.length - 4)}'
        : widget.phoneNumber;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480, minHeight: h),
            child: Padding(
              padding: EdgeInsets.fromLTRB(28, top + 16, 28, 32),
              child: Column(
                children: [
                  // ── Back button ──
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF5A3A40,
                          ).withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFE8D5D0,
                            ).withValues(alpha: 0.50),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF2D1B20),
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.06),

                  // ── Lock icon ──
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFB76E79).withValues(alpha: 0.10),
                        border: Border.all(
                          color: const Color(
                            0xFFE8B4B8,
                          ).withValues(alpha: 0.40),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 40,
                        color: Color(0xFFB76E79),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Title ──
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Text(
                      'Verify Your Number',
                      style: TextStyle(
                        fontFamily: AppTheme.playfairFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D1B20),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: _fadeIn,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: const Color(
                            0xFF5A3A40,
                          ).withValues(alpha: 0.60),
                          fontSize: 14,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'We sent a 6-digit code to\n'),
                          TextSpan(
                            text: '+91 $masked',
                            style: const TextStyle(
                              color: Color(0xFF2D1B20),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.05),

                  // ── OTP input card ──
                  SlideTransition(
                    position: _slideUp,
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(
                              0xFFE8D5D0,
                            ).withValues(alpha: 0.50),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFE8B4B8,
                              ).withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // OTP boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (i) {
                                return SizedBox(
                                  width: 46,
                                  child: TextField(
                                    controller: _controllers[i],
                                    focusNode: _focusNodes[i],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: const TextStyle(
                                      color: Color(0xFF2D1B20),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                      filled: true,
                                      fillColor: const Color(0xFFFDF8F5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: _error != null
                                              ? const Color(0xFFFF6B6B)
                                              : const Color(
                                                  0xFFE8D5D0,
                                                ).withValues(alpha: 0.70),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: _error != null
                                              ? const Color(0xFFFF6B6B)
                                              : const Color(
                                                  0xFFE8D5D0,
                                                ).withValues(alpha: 0.70),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFB76E79),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (v) => _onDigitChanged(i, v),
                                  ),
                                );
                              }),
                            ),

                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 14,
                                    color: Color(0xFFFF6B6B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Color(0xFFFF6B6B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 24),

                            // ── Verify button ──
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _onVerifyOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB76E79),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFFB76E79,
                                  ).withValues(alpha: 0.50),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Verify & Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Resend ──
                            _resendSeconds > 0
                                ? Text(
                                    'Resend code in ${_resendSeconds}s',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF5A3A40,
                                      ).withValues(alpha: 0.45),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: _onResend,
                                    child: const Text(
                                      'Resend Code',
                                      style: TextStyle(
                                        color: Color(0xFFB76E79),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Edit number ──
                  FadeTransition(
                    opacity: _fadeIn,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: const Color(
                              0xFF5A3A40,
                            ).withValues(alpha: 0.50),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Change phone number',
                            style: TextStyle(
                              color: const Color(
                                0xFF5A3A40,
                              ).withValues(alpha: 0.55),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
