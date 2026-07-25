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

    const seedColor =
    Color(0xFF2E7D32);

    return ThemeData(

      useMaterial3: true,

      colorScheme:
      ColorScheme.fromSeed(

        seedColor:
        seedColor,

        brightness:
        Brightness.light,

        primary:
        const Color(
          0xFF2E7D32,
        ),

        secondary:
        const Color(
          0xFF66BB6A,
        ),

        tertiary:
        const Color(
          0xFFA5D6A7,
        ),

        surface:
        const Color(
          0xFFF8FBF8,
        ),

        error:
        const Color(
          0xFFB71C1C,
        ),
      ),

      inputDecorationTheme:
      InputDecorationTheme(

        filled: true,

        fillColor:
        Colors.white,

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        border:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(
            14,
          ),

          borderSide:
          const BorderSide(
            color:
            Color(
              0xFFCCE5CC,
            ),
            width: 1.5,
          ),
        ),

        enabledBorder:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(
            14,
          ),

          borderSide:
          const BorderSide(
            color:
            Color(
              0xFFCCE5CC,
            ),
            width: 1.5,
          ),
        ),

        focusedBorder:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(
            14,
          ),

          borderSide:
          const BorderSide(
            color:
            Color(
              0xFF2E7D32,
            ),
            width: 2,
          ),
        ),

        errorBorder:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(
            14,
          ),

          borderSide:
          const BorderSide(
            color:
            Color(
              0xFFB71C1C,
            ),
            width: 1.5,
          ),
        ),

        focusedErrorBorder:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(
            14,
          ),

          borderSide:
          const BorderSide(
            color:
            Color(
              0xFFB71C1C,
            ),
            width: 2,
          ),
        ),
      ),

      elevatedButtonTheme:
      ElevatedButtonThemeData(

        style:
        ElevatedButton.styleFrom(

          backgroundColor:
          const Color(
            0xFF2E7D32,
          ),

          foregroundColor:
          Colors.white,

          minimumSize:
          const Size(
            double.infinity,
            56,
          ),

          shape:
          RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(
              14,
            ),
          ),

          elevation:
          0,

          textStyle:
          const TextStyle(
            fontSize: 16,
            fontWeight:
            FontWeight.w700,
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

  static const _primary =
  Color(
    0xFF2E7D32,
  );

  static const _primaryLight =
  Color(
    0xFFE8F5E9,
  );

  static const _textMuted =
  Color(
    0xFF78909C,
  );

  static const _textDark =
  Color(
    0xFF1B2E1C,
  );


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


          Navigator.push(

            context,

            MaterialPageRoute(

              builder:
                  (_) =>
                  EmailVerificationScreen(

                    email:
                    _emailController.text
                        .trim(),

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
        success
            ? const Color(
          0xFF2E7D32,
        )
            : Colors.redAccent,

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
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      const Color(
        0xFFF0F7F0,
      ),

      body:

      SafeArea(

        child:

        FadeTransition(

          opacity:
          _fadeAnimation,

          child:

          LayoutBuilder(

            builder:
                (
                context,
                constraints,
                ) {

              return
                SingleChildScrollView(

                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 24,
                  ),

                  child:

                  ConstrainedBox(

                    constraints:
                    BoxConstraints(

                      minHeight:
                      constraints
                          .maxHeight,

                    ),

                    child:

                    IntrinsicHeight(

                      child:

                      Column(

                        children: [

                          const SizedBox(
                            height: 48,
                          ),

                          _buildLogo(),

                          const SizedBox(
                            height: 28,
                          ),

                          _buildWelcomeText(),

                          const SizedBox(
                            height: 36,
                          ),

                          _buildFormCard(),

                          const Spacer(),

                          _buildRegisterRow(),

                          const SizedBox(
                            height: 24,
                          ),

                        ],

                      ),

                    ),

                  ),

                );

            },

          ),

        ),

      ),

    );
  }


  // ==========================================================
  // LOGO
  // ==========================================================

  Widget _buildLogo() {

    return Container(

      width: 96,

      height: 96,

      decoration:
      BoxDecoration(

        color:
        _primaryLight,

        shape:
        BoxShape.circle,

        boxShadow: [

          BoxShadow(

            color:
            _primary.withOpacity(
              0.18,
            ),

            blurRadius:
            24,

            offset:
            const Offset(
              0,
              8,
            ),

          ),

        ],

      ),

      child:

      Center(

        child:

        Container(

          width: 68,

          height: 68,

          decoration:
          const BoxDecoration(

            color:
            _primary,

            shape:
            BoxShape.circle,

          ),

          child:

          const Center(

            child:

            Text(

              '🐾',

              style:
              TextStyle(
                fontSize: 32,
              ),

            ),

          ),

        ),

      ),

    );
  }


  // ==========================================================
  // WELCOME TEXT
  // ==========================================================

  Widget _buildWelcomeText() {

    return Column(

      children: [

        Text(

          'Bio Pet',

          style:
          TextStyle(

            fontSize:
            28,

            fontWeight:
            FontWeight.w800,

            color:
            _textDark,

            letterSpacing:
            -0.5,

          ),

        ),

        const SizedBox(
          height: 6,
        ),

        const Text(

          'Welcome Back',

          style:
          TextStyle(

            fontSize:
            16,

            fontWeight:
            FontWeight.w400,

            color:
            _textMuted,

            letterSpacing:
            0.2,

          ),

        ),

      ],

    );
  }


  // ==========================================================
  // FORM CARD
  // ==========================================================

  Widget _buildFormCard() {

    return Container(

      padding:
      const EdgeInsets.all(
        24,
      ),

      decoration:
      BoxDecoration(

        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          24,
        ),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black
                .withOpacity(
              0.06,
            ),

            blurRadius:
            20,

            offset:
            const Offset(
              0,
              6,
            ),

          ),

        ],

      ),

      child:

      Form(

        key:
        _formKey,

        child:

        Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            _buildFieldLabel(
              'Email',
            ),

            const SizedBox(
              height: 8,
            ),

            _buildEmailField(),

            const SizedBox(
              height: 20,
            ),

            _buildFieldLabel(
              'Password',
            ),

            const SizedBox(
              height: 8,
            ),

            _buildPasswordField(),

            Align(

              alignment:
              Alignment.centerRight,

              child:

              TextButton(

                onPressed:
                _isLoading
                    ? null
                    : _handleForgotPassword,

                style:
                TextButton.styleFrom(

                  foregroundColor:
                  _primary,

                  padding:
                  const EdgeInsets
                      .symmetric(

                    horizontal:
                    4,

                    vertical:
                    8,

                  ),

                ),

                child:

                const Text(

                  'Forgot Password?',

                  style:
                  TextStyle(

                    fontSize:
                    13,

                    fontWeight:
                    FontWeight.w600,

                  ),

                ),

              ),

            ),

            const SizedBox(
              height: 8,
            ),

            _buildLoginButton(),

          ],

        ),

      ),

    );
  }


  // ==========================================================
  // FIELD LABEL
  // ==========================================================

  Widget _buildFieldLabel(
      String label,
      ) {

    return Text(

      label,

      style:
      const TextStyle(

        fontSize:
        13,

        fontWeight:
        FontWeight.w700,

        color:
        _textDark,

        letterSpacing:
        0.3,

      ),

    );
  }


  // ==========================================================
  // EMAIL FIELD
  // ==========================================================

  Widget _buildEmailField() {

    return TextFormField(

      controller:
      _emailController,

      keyboardType:
      TextInputType.emailAddress,

      textInputAction:
      TextInputAction.next,

      autocorrect:
      false,

      enabled:
      !_isLoading,

      decoration:
      const InputDecoration(

        hintText:
        'you@example.com',

        hintStyle:
        TextStyle(
          color:
          Color(
            0xFFB0BEC5,
          ),
        ),

        prefixIcon:
        Icon(

          Icons.email_outlined,

          color:
          _primary,

        ),

      ),

      validator:
          (value) {

        final v =
            value?.trim() ??
                '';

        if (v.isEmpty) {

          return
            'Email cannot be empty.';
        }

        final emailRegex =
        RegExp(

          r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',

        );

        if (!emailRegex
            .hasMatch(v)) {

          return
            'Please enter a valid email.';
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

      controller:
      _passwordController,

      obscureText:
      _obscurePassword,

      textInputAction:
      TextInputAction.done,

      enabled:
      !_isLoading,

      onFieldSubmitted:
          (_) {

        if (!_isLoading) {

          _handleLogin();

        }

      },

      decoration:
      InputDecoration(

        hintText:
        '••••••••',

        hintStyle:
        const TextStyle(

          color:
          Color(
            0xFFB0BEC5,
          ),

        ),

        prefixIcon:
        const Icon(

          Icons.lock_outline,

          color:
          _primary,

        ),

        suffixIcon:

        IconButton(

          icon:

          Icon(

            _obscurePassword

                ? Icons
                .visibility_outlined

                : Icons
                .visibility_off_outlined,

            color:
            _textMuted,

          ),

          onPressed:

          _isLoading

              ? null

              : () {

            setState(() {

              _obscurePassword =
              !_obscurePassword;

            });

          },

        ),

      ),

      validator:
          (value) {

        final v =
            value ?? '';

        if (v.isEmpty) {

          return
            'Password cannot be empty.';
        }

        if (v.length < 6) {

          return
            'Password must be at least 6 characters.';
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

      duration:
      const Duration(
        milliseconds: 250,
      ),

      child:

      _isLoading

          ? Container(

        key:
        const ValueKey(
          'loading',
        ),

        height:
        56,

        width:
        double.infinity,

        decoration:
        BoxDecoration(

          color:
          _primary
              .withOpacity(
            0.85,
          ),

          borderRadius:
          BorderRadius.circular(
            14,
          ),

        ),

        child:

        const Center(

          child:

          SizedBox(

            width:
            24,

            height:
            24,

            child:

            CircularProgressIndicator(

              strokeWidth:
              2.5,

              color:
              Colors.white,

            ),

          ),

        ),

      )

          : ElevatedButton(

        key:
        const ValueKey(
          'login',
        ),

        onPressed:
        _isLoading
            ? null
            : _handleLogin,

        child:

        const Text(
          'Log In',
        ),

      ),

    );
  }


  // ==========================================================
  // REGISTER ROW
  // ==========================================================

  Widget _buildRegisterRow() {

    return Row(

      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [

        const Text(

          "Don't have an account?",

          style:
          TextStyle(

            color:
            _textMuted,

            fontSize:
            14,

          ),

        ),

        TextButton(

          onPressed:

          _isLoading

              ? null

              : () {

            Navigator.push(

              context,

              MaterialPageRoute(

                builder:
                    (_) =>
                const RegisterScreen(),

              ),

            );

          },

          style:
          TextButton.styleFrom(

            foregroundColor:
            _primary,

            padding:
            const EdgeInsets
                .symmetric(

              horizontal:
              6,

              vertical:
              4,

            ),

          ),

          child:

          const Text(

            'Register',

            style:
            TextStyle(

              fontSize:
              14,

              fontWeight:
              FontWeight.w700,

            ),

          ),

        ),

      ],

    );
  }
}