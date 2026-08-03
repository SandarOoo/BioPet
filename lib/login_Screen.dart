import 'package:flutter/material.dart';

import 'package:biopet/email_verification_screen.dart';
import 'package:biopet/main_navigation.dart';
import 'package:biopet/register_screen.dart';

import 'package:biopet/screens/admin/admin_dashboard_screen.dart';

import 'package:biopet/screens/business/agreement_screen.dart';
import 'package:biopet/screens/business/business_dashboard.dart';
import 'package:biopet/screens/business/business_location_screen.dart';
import 'package:biopet/screens/business/business_pending_screen.dart';
import 'package:biopet/screens/business/business_submit_screen.dart';

import 'package:biopet/services/api_service.dart';


// ============================================================
// BioPet App
// ============================================================

void main() {
  runApp(
    const BioPetApp(),
  );
}


// ============================================================
// ROOT APP
// ============================================================

class BioPetApp extends StatelessWidget {
  const BioPetApp({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return MaterialApp(
      title: 'Bio Pet',

      debugShowCheckedModeBanner: false,

      theme: _buildTheme(),

      home: const LoginScreen(),
    );
  }


  // ==========================================================
  // THEME
  // ==========================================================

  ThemeData _buildTheme() {
    const emerald = Color(0xFF065F46);
    const mint = Color(0xFFA7F3D0);
    const cream = Color(0xFFFFF8E7);
    const ink = Color(0xFF10231D);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: const ColorScheme.light(
        primary: emerald,
        onPrimary: Colors.white,
        secondary: mint,
        onSecondary: ink,
        surface: Color(0xFFFFFDF8),
        onSurface: ink,
        error: Color(0xFFB42318),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: emerald,
        selectionColor: Color(0x55A7F3D0),
        selectionHandleColor: emerald,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3FBF7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF95A39D),
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: emerald,
        suffixIconColor: const Color(0xFF6F8179),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDCEDE5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDCEDE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: emerald, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFB42318)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFB42318), width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emerald,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF7FA99A),
          minimumSize: const Size(double.infinity, 58),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}


// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen
    extends StatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen>
  createState() =>
      _LoginScreenState();
}


// ============================================================
// LOGIN STATE
// ============================================================

class _LoginScreenState
    extends State<LoginScreen>
    with SingleTickerProviderStateMixin {


  // ==========================================================
  // FORM
  // ==========================================================

  final _formKey =
  GlobalKey<FormState>();

  final _emailController =
  TextEditingController();

  final _passwordController =
  TextEditingController();


  // ==========================================================
  // UI STATE
  // ==========================================================

  bool _obscurePassword =
  true;

  bool _isLoading =
  false;


  // ==========================================================
  // ANIMATION
  // ==========================================================

  late final AnimationController
  _fadeController;

  late final Animation<double>
  _fadeAnimation;


  // ==========================================================
  // COLORS
  // ==========================================================

  static const _primary = Color(0xFF065F46);
  static const _mint = Color(0xFFA7F3D0);
  static const _cream = Color(0xFFFFF8E7);
  static const _surface = Color(0xFFFFFDF8);
  static const _textMuted = Color(0xFF6F8179);
  static const _textDark = Color(0xFF10231D);


  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {

    super.initState();

    _fadeController =
    AnimationController(

      vsync:
      this,

      duration:
      const Duration(
        milliseconds: 700,
      ),
    )
      ..forward();

    _fadeAnimation =
        CurvedAnimation(

          parent:
          _fadeController,

          curve:
          Curves.easeOutCubic,
        );
  }


  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    _fadeController.dispose();

    super.dispose();
  }


  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> _handleLogin() async {

    print(
      "================================",
    );

    print(
      "STEP 1: LOGIN BUTTON PRESSED",
    );

    print(
      "================================",
    );


    // ========================================================
    // VALIDATE FORM
    // ========================================================

    if (!_formKey.currentState!
        .validate()) {

      print(
        "❌ FORM VALIDATION FAILED",
      );

      return;
    }


    setState(() {

      _isLoading =
      true;

    });


    try {

      // ======================================================
      // CALL LOGIN API
      // ======================================================

      print(
        "STEP 2: CALLING ApiService.login()",
      );


      final data =
      await ApiService.login(

        _emailController.text
            .trim(),

        _passwordController.text
            .trim(),

      );


      print(
        "STEP 3: LOGIN API RETURNED",
      );


      print(
        "LOGIN RESPONSE => $data",
      );


      // ======================================================
      // LOGIN FAILED
      // ======================================================

      if (data['success'] != true) {

        print(
          "❌ LOGIN FAILED",
        );


        // ----------------------------------------------------
        // EMAIL NOT VERIFIED
        // ----------------------------------------------------

        if (data['code'] ==
            'NOT_VERIFIED') {

          if (!mounted) {
            return;
          }

          final String otp =
              data['otp']?.toString() ?? '';


          Navigator.push(

            context,

            MaterialPageRoute(

              builder:
                  (_) =>
                  EmailVerificationScreen(

                    email:
                    _emailController.text
                        .trim(),
                    otp: otp,

                  ),

            ),

          );


          return;
        }


        // ----------------------------------------------------
        // OTHER LOGIN ERROR
        // ----------------------------------------------------

        if (!mounted) {
          return;
        }


        _showSnack(

          data['message'] ??
              'Login failed',

        );


        return;
      }


      // ======================================================
      // LOGIN SUCCESS
      // ======================================================

      print(
        "✅ LOGIN SUCCESS",
      );


      // ======================================================
      // CHECK TOKEN
      // ======================================================

      print(
        "STEP 4: CHECKING SAVED TOKEN",
      );


      final token =
      await ApiService.getToken();


      print(
        "TOKEN AFTER LOGIN => $token",
      );


      // ======================================================
      // TOKEN MISSING
      // ======================================================

      if (token == null ||
          token.isEmpty) {

        print(
          "❌ TOKEN IS NULL OR EMPTY AFTER LOGIN",
        );


        if (!mounted) {
          return;
        }


        _showSnack(

          "Login failed: Authentication token was not saved.",

        );


        return;
      }


      // ======================================================
      // TOKEN SUCCESS
      // ======================================================

      print(
        "✅ TOKEN SAVED SUCCESSFULLY",
      );


      // ======================================================
      // USER DATA
      // ======================================================

      final user =
      data['user']
      as Map<String, dynamic>?;


      if (user == null) {

        print(
          "❌ USER DATA IS NULL",
        );


        if (!mounted) {
          return;
        }


        _showSnack(

          "Login failed: User information not found.",

        );


        return;
      }


      // ======================================================
      // USER ROLE
      // ======================================================

      final role =
          user['role']
              ?.toString() ??
              '';


      print(
        "USER ROLE => $role",
      );


      // ======================================================
      // SUCCESS MESSAGE
      // ======================================================

      if (!mounted) {
        return;
      }


      _showSnack(

        "Login Successful",

        success:
        true,

      );


      // ======================================================
      // ADMIN
      // ======================================================

      if (role ==
          "admin") {

        print(
          "NAVIGATE => ADMIN DASHBOARD",
        );


        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder:
                (_) =>
            const AdminDashboardScreen(),

          ),

        );


        return;
      }


      // ======================================================
      // BUSINESS OWNER
      // ======================================================

      if (role ==
          "business_owner") {

        print(
          "BUSINESS OWNER LOGIN",
        );


        // ====================================================
        // BUSINESS PROFILE
        // ====================================================

        final business =
            user["businessProfile"]
            as Map<String, dynamic>? ??
                {};


        print(
          "BUSINESS PROFILE => $business",
        );


        // ====================================================
        // AGREEMENT
        // ====================================================

        final bool agreementAccepted =
            business["agreementAccepted"] ==
                true;


        // ====================================================
        // LATITUDE
        // ====================================================

        final double? latitude =
        (business["latitude"]
        as num?)
            ?.toDouble();


        // ====================================================
        // VERIFICATION STATUS
        // ====================================================

        final String status =
            business["verificationStatus"]
                ?.toString() ??
                "draft";


        print(
          "AGREEMENT ACCEPTED => "
              "$agreementAccepted",
        );


        print(
          "LATITUDE => $latitude",
        );


        print(
          "VERIFICATION STATUS => "
              "$status",
        );


        // ====================================================
        // AGREEMENT NOT ACCEPTED
        // ====================================================

        if (!agreementAccepted) {

          print(
            "NAVIGATE => AGREEMENT SCREEN",
          );


          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder:
                  (_) =>
              const AgreementScreen(),

            ),

          );


          return;
        }


        // ====================================================
        // LOCATION NOT SET
        // ====================================================

        if (latitude == null) {

          print(
            "NAVIGATE => BUSINESS LOCATION",
          );


          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder:
                  (_) =>
              const BusinessLocationScreen(),

            ),

          );


          return;
        }


        // ====================================================
        // DRAFT
        // ====================================================

        if (status ==
            "draft") {

          print(
            "NAVIGATE => BUSINESS SUBMIT",
          );


          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder:
                  (_) =>
              const BusinessSubmitScreen(),

            ),

          );


          return;
        }


        // ====================================================
        // PENDING
        // ====================================================

        if (status ==
            "pending") {

          print(
            "NAVIGATE => BUSINESS PENDING",
          );


          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder:
                  (_) =>
              const BusinessPendingScreen(),

            ),

          );


          return;
        }


        // ====================================================
        // APPROVED
        // ====================================================

        if (status ==
            "approved") {

          print(
            "NAVIGATE => BUSINESS DASHBOARD",
          );


          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder:
                  (_) =>
              const BusinessDashboard(),

            ),

          );


          return;
        }


        // ====================================================
        // REJECTED / OTHER
        // ====================================================

        print(
          "NAVIGATE => MAIN NAVIGATION",
        );


        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder:
                (_) =>
            const MainNavigation(),

          ),

        );


        return;
      }


      // ======================================================
      // NORMAL USER
      // ======================================================

      print(
        "NORMAL USER LOGIN",
      );


      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder:
              (_) =>
          const MainNavigation(),

        ),

      );

    } catch (e) {

      // ======================================================
      // LOGIN ERROR
      // ======================================================

      print(
        "❌ LOGIN ERROR => $e",
      );


      if (!mounted) {
        return;
      }


      _showSnack(

        "Error: $e",

      );

    } finally {

      if (mounted) {

        setState(() {

          _isLoading =
          false;

        });

      }

    }
  }


  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void _showSnack(
      String msg, {
        bool success =
        false,
      }) {

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(

        content:
        Text(msg),

        backgroundColor:
        success ? _primary : const Color(0xFFB42318),

        behavior:
        SnackBarBehavior.floating,

        shape:
        RoundedRectangleBorder(

          borderRadius:
          BorderRadius.circular(
            10,
          ),

        ),

      ),

    );
  }


  // ==========================================================
  // FORGOT PASSWORD
  // ==========================================================

  void _handleForgotPassword() {

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(

        content:
        const Text(
          'Forgot password flow coming soon!',
        ),

        behavior:
        SnackBarBehavior.floating,

        shape:
        RoundedRectangleBorder(

          borderRadius:
          BorderRadius.circular(
            10,
          ),

        ),

      ),

    );
  }


  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          const Positioned(
            top: -90,
            right: -70,
            child: _DecorativeCircle(
              size: 230,
              color: Color(0x55A7F3D0),
            ),
          ),
          const Positioned(
            top: 118,
            left: -76,
            child: _DecorativeCircle(
              size: 160,
              color: Color(0x22065F46),
            ),
          ),
          const Positioned(
            bottom: -90,
            left: -30,
            child: _DecorativeCircle(
              size: 210,
              color: Color(0x44A7F3D0),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(22, 18, 22, 24 + bottomInset),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 24),
                        _buildHeroPanel(),
                        const SizedBox(height: 24),
                        _buildFormCard(),
                        const SizedBox(height: 20),
                        _buildRegisterRow(),
                        const SizedBox(height: 12),
                        const Text(
                          'Healthy pets. Happy homes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TOP BAR
  // ==========================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.20),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.pets_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BioPet',
              style: TextStyle(
                color: _textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Pet care made simple',
              style: TextStyle(
                color: _textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE5EEE9)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco_rounded, color: _primary, size: 16),
              SizedBox(width: 5),
              Text(
                'Secure',
                style: TextStyle(
                  color: _primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // HERO PANEL
  // ==========================================================

  Widget _buildHeroPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 18, 20),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -28,
            child: Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                color: Color(0x1FFFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 68,
            bottom: -46,
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0x18A7F3D0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.9,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sign in to keep your pet’s care, records and daily moments close.',
                      style: TextStyle(
                        color: Color(0xDFFFFFFF),
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 92,
                height: 112,
                decoration: BoxDecoration(
                  color: _mint,
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.55),
                    width: 1.2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned(
                      top: 14,
                      left: 15,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: _primary,
                        size: 16,
                      ),
                    ),
                    Container(
                      width: 59,
                      height: 59,
                      decoration: const BoxDecoration(
                        color: _surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: _primary,
                        size: 34,
                      ),
                    ),
                    const Positioned(
                      bottom: 12,
                      child: Text(
                        'CARE',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FORM CARD
  // ==========================================================

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8EEE9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123B2D).withOpacity(0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Login to your account',
              style: TextStyle(
                color: _textDark,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Enter your details below to continue.',
              style: TextStyle(
                color: _textMuted,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),
            _buildFieldLabel('Email address'),
            const SizedBox(height: 8),
            _buildEmailField(),
            const SizedBox(height: 17),
            _buildFieldLabel('Password'),
            const SizedBox(height: 8),
            _buildPasswordField(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _handleForgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: _primary,
                  padding: const EdgeInsets.fromLTRB(8, 8, 2, 8),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _textDark,
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.15,
      ),
    );
  }

  // ==========================================================
  // EMAIL FIELD
  // ==========================================================

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      enabled: !_isLoading,
      style: const TextStyle(
        color: _textDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: const InputDecoration(
        hintText: 'you@example.com',
        prefixIcon: Icon(Icons.alternate_email_rounded),
      ),
      validator: (value) {
        final v = value?.trim() ?? '';

        if (v.isEmpty) {
          return 'Email cannot be empty.';
        }

        final emailRegex = RegExp(
          r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
        );

        if (!emailRegex.hasMatch(v)) {
          return 'Please enter a valid email.';
        }

        return null;
      },
    );
  }

  // ==========================================================
  // PASSWORD FIELD
  // ==========================================================

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      enabled: !_isLoading,
      style: const TextStyle(
        color: _textDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      onFieldSubmitted: (_) {
        if (!_isLoading) {
          _handleLogin();
        }
      },
      decoration: InputDecoration(
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
        ),
      ),
      validator: (value) {
        final v = value ?? '';

        if (v.isEmpty) {
          return 'Password cannot be empty.';
        }

        if (v.length < 6) {
          return 'Password must be at least 6 characters.';
        }

        return null;
      },
    );
  }

  // ==========================================================
  // LOGIN BUTTON
  // ==========================================================

  Widget _buildLoginButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: _isLoading
          ? Container(
              key: const ValueKey('loading'),
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.84),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : ElevatedButton(
              key: const ValueKey('login'),
              onPressed: _handleLogin,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Log in'),
                  SizedBox(width: 9),
                  Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // REGISTER ROW
  // ==========================================================

  Widget _buildRegisterRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EEE9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Flexible(
            child: Text(
              "New to BioPet?",
              style: TextStyle(
                color: _textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
            style: TextButton.styleFrom(
              foregroundColor: _primary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text(
              'Create account',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
