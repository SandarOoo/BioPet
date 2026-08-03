import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_Screen.dart';
import 'services/api_service.dart';

// ============================================================
// BioPet – Email Verification Screen
// Emerald + Mint + Cream theme
// ============================================================

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    this.email = 'user123@gmail.com',
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _countdownSeconds = 59;

  final List<TextEditingController> _otpControllers =
  List.generate(_otpLength, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
  List.generate(_otpLength, (_) => FocusNode());

  String? _otpError;

  late int _secondsRemaining;
  Timer? _countdownTimer;
  bool _canResend = false;

  bool _isVerifying = false;
  bool _isResending = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Emerald + Mint + Cream palette
  static const Color _emerald = Color(0xFF065F46);
  static const Color _emeraldDark = Color(0xFF064E3B);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _mintLight = Color(0xFFECFDF5);
  static const Color _cream = Color(0xFFFFF8E7);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _border = Color(0xFFD1FAE5);
  static const Color _errorColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    _startCountdown();
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    _countdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    if (mounted) {
      setState(() {
        _secondsRemaining = _countdownSeconds;
        _canResend = false;
      });
    } else {
      _secondsRemaining = _countdownSeconds;
      _canResend = false;
    }

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

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  void _clearOtp() {
    for (final controller in _otpControllers) {
      controller.clear();
    }

    if (_focusNodes.isNotEmpty) {
      _focusNodes.first.requestFocus();
    }

    if (mounted) {
      setState(() => _otpError = null);
    }
  }

  Future<void> _handleVerify() async {
    final code = _otpValue;

    if (code.length != _otpLength) {
      setState(() => _otpError = 'Please enter all 6 digits');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isVerifying = true;
      _otpError = null;
    });

    try {
      final result = await ApiService.verifyEmail(
        widget.email,
        code,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        setState(() {
          _otpError = result['message']?.toString() ?? 'Verification failed';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _otpError = 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _handleResend() async {
    if (!_canResend || _isResending) return;

    setState(() => _isResending = true);

    try {
      final result = await ApiService.resendOtp(widget.email);

      if (!mounted) return;

      if (result['success'] == true) {
        _clearOtp();
        _startCountdown();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ?? 'Unable to resend OTP',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          const Positioned(
            top: -95,
            right: -75,
            child: _DecorativeCircle(
              size: 230,
              color: _mint,
            ),
          ),
          const Positioned(
            top: 120,
            left: -80,
            child: _DecorativeCircle(
              size: 170,
              color: Color(0x66A7F3D0),
            ),
          ),
          const Positioned(
            bottom: -110,
            right: -85,
            child: _DecorativeCircle(
              size: 230,
              color: Color(0x88D1FAE5),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight - 36,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 8),
                                  _buildIllustration(),
                                  const SizedBox(height: 26),
                                  _buildHeading(),
                                  const SizedBox(height: 28),
                                  _buildOtpCard(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 18, 4),
      child: Row(
        children: [
          Material(
            color: _surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _isVerifying ? null : () => Navigator.maybePop(context),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _emeraldDark,
                  size: 19,
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _surface.withOpacity(0.78),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets_rounded, color: _emerald, size: 16),
                SizedBox(width: 6),
                Text(
                  'BioPet',
                  style: TextStyle(
                    color: _emeraldDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 138,
          height: 138,
          decoration: BoxDecoration(
            color: _mintLight,
            shape: BoxShape.circle,
            border: Border.all(color: _border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _emerald.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
        ),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_emerald, _emeraldDark],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _emerald.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: Colors.white,
            size: 43,
          ),
        ),
        Positioned(
          bottom: -1,
          right: 2,
          child: Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: _mint,
              shape: BoxShape.circle,
              border: Border.all(color: _cream, width: 4),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: _emeraldDark,
              size: 21,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeading() {
    return Column(
      children: [
        const Text(
          'Verify your email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: _textDark,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 11),
        const Text(
          'Enter the 6-digit verification code\nwe sent to your Gmail account.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.55,
            color: _textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          constraints: const BoxConstraints(maxWidth: 310),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: _mintLight,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.alternate_email_rounded,
                size: 16,
                color: _emerald,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  widget.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _emeraldDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: _emerald.withOpacity(0.09),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: _emerald,
              ),
              SizedBox(width: 7),
              Text(
                'Verification code',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildOtpRow(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _otpError == null
                ? const SizedBox(
              key: ValueKey('no_error'),
              height: 27,
            )
                : Padding(
              key: const ValueKey('otp_error'),
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 15,
                      color: _errorColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      _otpError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: _errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildResendSection(),
          const SizedBox(height: 22),
          _buildVerifyButton(),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: _textMuted,
              ),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Your verification code expires in 5 minutes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final availableWidth = constraints.maxWidth - (gap * 5);
        final boxWidth = (availableWidth / 6).clamp(38.0, 48.0).toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_otpLength, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index == _otpLength - 1 ? 0 : gap,
              ),
              child: _OtpBox(
                width: boxWidth,
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                enabled: !_isVerifying,
                hasError: _otpError != null,
                onChanged: (value) {
                  if (_otpError != null) {
                    setState(() => _otpError = null);
                  }

                  if (value.isNotEmpty && index < _otpLength - 1) {
                    _focusNodes[index + 1].requestFocus();
                  }

                  if (value.isNotEmpty && index == _otpLength - 1) {
                    FocusScope.of(context).unfocus();
                  }
                },
                onBackspace: () {
                  if (_otpControllers[index].text.isEmpty && index > 0) {
                    _otpControllers[index - 1].clear();
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildResendSection() {
    if (_isResending) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _emerald,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Sending a new code...',
            style: TextStyle(
              fontSize: 13,
              color: _textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (!_canResend) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: _mintLight,
          borderRadius: BorderRadius.circular(30),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 12.5,
              color: _textMuted,
              fontWeight: FontWeight.w500,
            ),
            children: [
              const TextSpan(text: 'Resend code in  '),
              TextSpan(
                text: '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _emerald,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return TextButton.icon(
      onPressed: _handleResend,
      icon: const Icon(
        Icons.refresh_rounded,
        size: 18,
        color: _emerald,
      ),
      label: const Text(
        'Resend verification code',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: _emerald,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: _emerald,
        backgroundColor: _mintLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _handleVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: _emerald,
          disabledBackgroundColor: _emerald.withOpacity(0.75),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _isVerifying
              ? const Row(
            key: ValueKey('loading'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 11),
              Text(
                'Verifying...',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          )
              : const Row(
            key: ValueKey('verify'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verify Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final double width;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  static const Color _emerald = Color(0xFF065F46);
  static const Color _mintLight = Color(0xFFECFDF5);
  static const Color _border = Color(0xFFD1FAE5);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _errorColor = Color(0xFFDC2626);

  const _OtpBox({
    required this.width,
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
      width: width,
      height: 57,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
          return KeyEventResult.ignored;
        },
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: _textDark,
          ),
          cursorColor: _emerald,
          decoration: InputDecoration(
            filled: true,
            fillColor: hasError
                ? const Color(0xFFFFF1F2)
                : _mintLight,
            counterText: '',
            contentPadding: EdgeInsets.zero,
            border: _borderStyle(
              hasError ? _errorColor : _border,
              1.5,
            ),
            enabledBorder: _borderStyle(
              hasError ? _errorColor : _border,
              1.5,
            ),
            focusedBorder: _borderStyle(
              hasError ? _errorColor : _emerald,
              2.1,
            ),
            disabledBorder: _borderStyle(
              const Color(0xFFE2E8F0),
              1.4,
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  OutlineInputBorder _borderStyle(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
