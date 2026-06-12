import 'package:biopet/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:biopet/services/api_service.dart';

// ============================================================
// Bio Pet – Login Screen
// Design: Material Design 3, green pet-friendly palette,
//         warm off-white background, Nunito-style rounded feel
// ============================================================

void main() {
  runApp(const BioPetApp());
}

/// Root application widget – sets up the M3 theme.
class BioPetApp extends StatelessWidget {
  const BioPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bio Pet',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const LoginScreen(),
    );
  }

  /// Build the Material Design 3 theme with a green pet-friendly palette.
  ThemeData _buildTheme() {
    const seedColor = Color(0xFF2E7D32); // Deep forest green
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        primary: const Color(0xFF2E7D32),
        secondary: const Color(0xFF66BB6A),
        tertiary: const Color(0xFFA5D6A7),
        surface: const Color(0xFFF8FBF8),
        error: const Color(0xFFB71C1C),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCCE5CC), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCCE5CC), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ============================================================
// Login Screen
// ============================================================

/// A [StatefulWidget] that renders the Bio Pet login screen.
///
/// Handles:
///   • Form validation (email + password)
///   • Password visibility toggle
///   • Mock login with loading state
///   • Navigation placeholders for Home and Register
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ── UI state ──────────────────────────────────────────────
  bool _obscurePassword = true;
  bool _isLoading = false;

  // ── Animation ─────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // ── Palette shortcuts ─────────────────────────────────────
  static const _primary = Color(0xFF2E7D32);
  static const _primaryLight = Color(0xFFE8F5E9);
  static const _textMuted = Color(0xFF78909C);
  static const _textDark = Color(0xFF1B2E1C);

  @override
  void initState() {
    super.initState();
    // Fade-in entrance animation for the whole card
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Mock login logic ──────────────────────────────────────

  // /// Validates the form, simulates an API call, then navigates to HomeScreen.
  // Future<void> _handleLogin() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _isLoading = true);
  //
  //   // Simulate network delay (replace with real API call later)
  //   await Future.delayed(const Duration(seconds: 2));
  //
  //   if (!mounted) return;
  //   setState(() => _isLoading = false);
  //
  //   // TODO: Replace with actual navigation once HomeScreen is implemented.
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: const Text('Login successful! Navigating to Home…'),
  //       backgroundColor: _primary,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     ),
  //   );
  //   // Navigator.pushReplacement(context,
  //   //     MaterialPageRoute(builder: (_) => const HomeScreen()));
  // }



  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (data['success'] == true) {

        await ApiService.saveToken(data['token']);

        final role = data['user']['role'];


        if (!mounted) return;
        if (role == 'admin') {
          // Navigator.pushReplacement(context,
          //   MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
          _showSnack('Go To Admin Home 🛡️', success: true);
        } else if (role == 'business_owner') {
          // Navigator.pushReplacement(context,
          //   MaterialPageRoute(builder: (_) => const ShopHomeScreen()));
          _showSnack('Go To Shop Owner Home  🏪', success: true);
        } else {
          // Navigator.pushReplacement(context,
          //   MaterialPageRoute(builder: (_) => const UserHomeScreen()));
          _showSnack('Go To User Home  🐾', success: true);
        }

      } else {
        _showSnack(data['message'] ?? 'Login Fail');
      }

    } catch (e) {
      _showSnack('Server cannot connect — Need backend running ');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? const Color(0xFF2E7D32) : Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  /// Placeholder for forgot-password flow.
  void _handleForgotPassword() {
    // TODO: Navigate to ForgotPasswordScreen.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Forgot password flow coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Placeholder for register flow.
  void _handleRegister() {
    // TODO: Navigate to RegisterScreen.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Register flow coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F0),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints:
                  BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        _buildLogo(),
                        const SizedBox(height: 28),
                        _buildWelcomeText(),
                        const SizedBox(height: 36),
                        _buildFormCard(),
                        const Spacer(),
                        _buildRegisterRow(),
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
    );
  }

  // ── Private widget builders ───────────────────────────────

  /// Paw-print logo inside a layered circular container.
  Widget _buildLogo() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _primaryLight,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: _primary,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '🐾',
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
      ),
    );
  }

  /// App name + welcome subtitle.
  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Bio Pet',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _textMuted,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  /// White rounded card containing the form fields and action buttons.
  Widget _buildFormCard() {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Email field ──────────────────────────────────
            _buildFieldLabel('Email'),
            const SizedBox(height: 8),
            _buildEmailField(),
            const SizedBox(height: 20),

            // ── Password field ───────────────────────────────
            _buildFieldLabel('Password'),
            const SizedBox(height: 8),
            _buildPasswordField(),

            // ── Forgot password ──────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _handleForgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: _primary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Login button ─────────────────────────────────
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  /// Small bold label shown above each text field.
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _textDark,
        letterSpacing: 0.3,
      ),
    );
  }

  /// Email [TextFormField] with validation.
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enabled: !_isLoading,
      decoration: const InputDecoration(
        hintText: 'you@example.com',
        hintStyle: TextStyle(color: Color(0xFFB0BEC5)),
        prefixIcon: Icon(Icons.email_outlined, color: _primary),
      ),
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) return 'Email cannot be empty.';
        // Basic RFC-5322–style check
        final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(v)) return 'Please enter a valid email.';
        return null;
      },
    );
  }

  /// Password [TextFormField] with show/hide toggle and validation.
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      enabled: !_isLoading,
      onFieldSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
        prefixIcon: const Icon(Icons.lock_outline, color: _primary),
        // Show/hide password toggle
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _textMuted,
          ),
          onPressed: _isLoading
              ? null
              : () => setState(() => _obscurePassword = !_obscurePassword),
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
        ),
      ),
      validator: (value) {
        final v = value ?? '';
        if (v.isEmpty) return 'Password cannot be empty.';
        if (v.length < 6)
          return 'Password must be at least 6 characters.';
        return null;
      },
    );
  }

  /// Animated login button that shows a spinner during loading.
  Widget _buildLoginButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _isLoading
          ? Container(
        key: const ValueKey('loading'),
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
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          ),
        ),
      )
          : ElevatedButton(
        key: const ValueKey('login'),
        onPressed: _handleLogin,
        child: const Text('Log In'),
      ),
    );
  }

  /// "Don't have an account? Register" row at the bottom of the screen.
  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: _textMuted, fontSize: 14),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
          child: const Text(
            'Register',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
