import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================
// Bio Pet – Email Verification Screen
// Matches the Login / Register green pet-friendly M3 theme.
// Features: 6-box OTP input, countdown timer, resend,
//           fade-in entrance, button loading animation.
// ============================================================

class EmailVerificationScreen extends StatefulWidget {
  /// The email address the code was sent to.
  final String email;

  const EmailVerificationScreen({
    super.key,
    this.email = 'chitsnowoo@gmail.com', // default for standalone preview
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  // ── OTP state ─────────────────────────────────────────────
  static const int _otpLength = 6;
  static const int _countdownSeconds = 59;

  /// One controller per OTP digit box.
  final List<TextEditingController> _otpControllers =
      List.generate(_otpLength, (_) => TextEditingController());

  /// One focus node per OTP digit box.
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  String? _otpError;

  // ── Timer state ───────────────────────────────────────────
  late int _secondsRemaining;
  Timer? _countdownTimer;
  bool _canResend = false;

  // ── Loading / resend state ────────────────────────────────
  bool _isVerifying = false;
  bool _isResending = false;

  // ── Entrance animation ────────────────────────────────────
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // ── Palette (matches Login / Register screens) ────────────
  static const _primary = Color(0xFF2E7D32);
  static const _primaryLight = Color(0xFFE8F5E9);
  static const _primaryMid = Color(0xFF66BB6A);
  static const _textMuted = Color(0xFF78909C);
  static const _textDark = Color(0xFF1B2E1C);
  static const _bgColor = Color(0xFFF0F7F0);
  static const _errorColor = Color(0xFFB71C1C);

  @override
  void initState() {
    super.initState();

    // Entrance animation setup
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    // Start the resend countdown immediately
    _startCountdown();
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _countdownTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Countdown timer logic ─────────────────────────────────

  /// Starts (or restarts) the 59-second resend countdown.
  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = _countdownSeconds;
      _canResend = false;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  // ── OTP helpers ───────────────────────────────────────────

  /// Returns the full OTP string assembled from all boxes.
  String get _otpValue =>
      _otpControllers.map((c) => c.text).join();

  /// Clears every OTP box and moves focus to the first one.
  void _clearOtp() {
    for (final c in _otpControllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() => _otpError = null);
  }

  // ── Actions ───────────────────────────────────────────────

  /// Validates OTP and simulates a verification API call.
  Future<void> _handleVerify() async {
    final code = _otpValue;
    if (code.length < _otpLength) {
      setState(() => _otpError = 'Please enter all 6 digits.');
      return;
    }
    setState(() {
      _otpError = null;
      _isVerifying = true;
    });

    // Simulate network call – replace with real API later.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isVerifying = false);

    // TODO: Navigate to HomeScreen on success.
    // Navigator.pushAndRemoveUntil(context,
    //   MaterialPageRoute(builder: (_) => const HomeScreen()),
    //   (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Email verified! Navigating to Home…'),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Simulates resending the verification code.
  Future<void> _handleResend() async {
    if (!_canResend || _isResending) return;
    setState(() => _isResending = true);

    // Simulate network call – replace with real API later.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isResending = false);
    _clearOtp();
    _startCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('A new code has been sent to your email.'),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark),
          // TODO: Navigator.pop(context) to go back to RegisterScreen.
          onPressed: _isVerifying ? null : () => Navigator.maybePop(context),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 56),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildIllustration(),
                          const SizedBox(height: 28),
                          _buildHeading(),
                          const SizedBox(height: 32),
                          _buildOtpCard(),
                          const Spacer(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Private widget builders ───────────────────────────────

  /// Email/paw illustration – layered circles matching Login branding.
  Widget _buildIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            color: _primaryLight,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.16),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        // Inner circle
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: _primary,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.mark_email_read_outlined,
                color: Colors.white, size: 36),
          ),
        ),
        // Small paw badge
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _primaryMid,
              shape: BoxShape.circle,
              border: Border.all(color: _bgColor, width: 2),
            ),
            child: const Center(
              child: Text('🐾', style: TextStyle(fontSize: 13)),
            ),
          ),
        ),
      ],
    );
  }

  /// Title, instruction message, and masked email address.
  Widget _buildHeading() {
    return Column(
      children: [
        const Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'We have sent a 6-digit verification code\nto your email address.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.55,
            color: _textMuted,
          ),
        ),
        const SizedBox(height: 10),
        // Highlighted email chip
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _primaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCCE5CC), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.email_outlined,
                  size: 15, color: _primary),
              const SizedBox(width: 6),
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// White card containing the OTP boxes, timer, and action buttons.
  Widget _buildOtpCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Enter verification code',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 20),

          // ── 6 OTP digit boxes ──────────────────────────────
          _buildOtpRow(),

          // ── Inline error message ───────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _otpError != null
                ? Padding(
                    key: const ValueKey('otp_error'),
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 14, color: _errorColor),
                        const SizedBox(width: 5),
                        Text(
                          _otpError!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: _errorColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(key: ValueKey('no_error'), height: 10),
          ),

          const SizedBox(height: 16),

          // ── Countdown / Resend ─────────────────────────────
          _buildResendSection(),

          const SizedBox(height: 24),

          // ── Verify button ──────────────────────────────────
          _buildVerifyButton(),
        ],
      ),
    );
  }

  /// Row of 6 individual OTP digit input boxes.
  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        return _OtpBox(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          enabled: !_isVerifying,
          hasError: _otpError != null,
          onChanged: (value) {
            setState(() => _otpError = null);
            if (value.isNotEmpty && index < _otpLength - 1) {
              // Move forward on digit entry
              _focusNodes[index + 1].requestFocus();
            }
          },
          onBackspace: () {
            if (_otpControllers[index].text.isEmpty && index > 0) {
              // Move backward on backspace when box is empty
              _otpControllers[index - 1].clear();
              _focusNodes[index - 1].requestFocus();
            }
          },
        );
      }),
    );
  }

  /// Shows either the countdown label or the Resend Code button.
  Widget _buildResendSection() {
    if (_isResending) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: _primary),
          ),
          SizedBox(width: 8),
          Text(
            'Sending new code…',
            style: TextStyle(fontSize: 13, color: _textMuted),
          ),
        ],
      );
    }

    if (!_canResend) {
      // Countdown label
      return RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: _textMuted),
          children: [
            const TextSpan(text: 'Resend code in '),
            TextSpan(
              text: '$_secondsRemaining seconds',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: _primary),
            ),
          ],
        ),
      );
    }

    // Resend button (shown after countdown reaches 0)
    return TextButton.icon(
      onPressed: _handleResend,
      icon: const Icon(Icons.refresh_rounded, size: 16, color: _primary),
      label: const Text(
        'Resend Code',
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _primary),
      ),
      style: TextButton.styleFrom(
        foregroundColor: _primary,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// Animated Verify button that morphs to a spinner during loading.
  Widget _buildVerifyButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _isVerifying
          ? Container(
              key: const ValueKey('verifying'),
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.85),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                ),
              ),
            )
          : SizedBox(
              key: const ValueKey('verify'),
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Verify Email'),
              ),
            ),
    );
  }
}

// ============================================================
// _OtpBox – reusable single-digit input widget
// ============================================================

/// A single OTP digit box with focus, backspace, and error styling.
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  static const _primary = Color(0xFF2E7D32);
  static const _primaryLight = Color(0xFFE8F5E9);
  static const _errorColor = Color(0xFFB71C1C);

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 54,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        // Intercept physical backspace key for navigation
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B2E1C),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: hasError
                ? const Color(0xFFFFF0F0)
                : _primaryLight,
            counterText: '',
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? _errorColor : const Color(0xFFCCE5CC),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? _errorColor : const Color(0xFFCCE5CC),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? _errorColor : _primary,
                width: 2.2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0), width: 1.5),
            ),
          ),
          onChanged: (value) {
            // If pasting a full code, distribute across boxes
            if (value.length > 1) {
              final digits = value.replaceAll(RegExp(r'\D'), '');
              final boxes = context
                  .findAncestorStateOfType<_EmailVerificationScreenState>();
              if (boxes != null && digits.isNotEmpty) {
                for (int i = 0; i < _EmailVerificationScreenState._otpLength; i++) {
                  boxes._otpControllers[i].text =
                      i < digits.length ? digits[i] : '';
                }
                final lastFilled =
                    (digits.length - 1).clamp(0, _EmailVerificationScreenState._otpLength - 1);
                boxes._focusNodes[lastFilled].requestFocus();
              }
              return;
            }
            onChanged(value);
          },
        ),
      ),
    );
  }
}
