import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biopet/services/api_service.dart';
import 'Login_Screen.dart';
import 'email_verification_screen.dart';

// ============================================================
// Bio Pet – Register Screen
// Matches the Login Screen's M3 green pet-friendly theme.
// Supports two roles: User and Shop Owner, each with its own
// dynamic field set revealed via animated cross-fade.
// ============================================================

// ── Role enum ────────────────────────────────────────────────

enum UserRole { user, shopOwner }

// ============================================================
// Register Screen
// ============================================================

/// A [StatefulWidget] that renders the Bio Pet registration screen.
///
/// Handles:
///   • Role selection (User / Shop Owner) with dynamic fields
///   • Form validation for all fields
///   • Password / Confirm Password visibility toggles
///   • Mock register with loading state
///   • Navigation placeholders for HomeScreen and LoginScreen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // Shared controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // User-only controllers
  final _fullNameController = TextEditingController();

  // Shop Owner-only controllers
  final _ownerNameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopAddressController = TextEditingController();

  // ── UI state ──────────────────────────────────────────────
  UserRole _selectedRole = UserRole.user;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // ── Animation ─────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // ── Palette ───────────────────────────────────────────────
  static const _primary = Color(0xFF2E7D32);
  static const _primaryLight = Color(0xFFE8F5E9);
  static const _textMuted = Color(0xFF78909C);
  static const _textDark = Color(0xFF1B2E1C);
  static const _bgColor = Color(0xFFF0F7F0);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
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
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _ownerNameController.dispose();
    _shopNameController.dispose();
    _phoneController.dispose();
    _shopAddressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Mock register logic ───────────────────────────────────

  // /// Validates the form and simulates an API registration call.
  // Future<void> _handleRegister() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _isLoading = true);
  //
  //   // Simulate network delay – replace with real API call later.
  //   await Future.delayed(const Duration(seconds: 2));
  //
  //   if (!mounted) return;
  //   setState(() => _isLoading = false);
  //
  //   // TODO: Replace SnackBar with actual navigation once HomeScreen exists.
  //   // Navigator.pushReplacement(context,
  //   //     MaterialPageRoute(builder: (_) => const HomeScreen()));
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         'Account created! Welcome to Bio Pet'
  //         '${_selectedRole == UserRole.shopOwner ? " (Shop Owner)" : ""}.',
  //       ),
  //       backgroundColor: _primary,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     ),
  //   );
  // }



  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> data;

      if (_selectedRole == UserRole.user) {
        data = await ApiService.registerUser(
          name: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        data = await ApiService.registerShopOwner(
          ownerName: _ownerNameController.text.trim(),
          shopName: _shopNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          shopAddress: _shopAddressController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) return;

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Register Success! Please Login 🐾'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(
                email: _emailController.text.trim(),
              ),
            )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message'] ?? 'Register Fail'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Server cannot connect — Need Backend run '),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }
  /// Navigates back to the Login screen.
  void _handleLogin() {
    // TODO: Replace with Navigator.pushReplacement to LoginScreen.
    // Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (_) => const LoginScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Navigating to Login…'),
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
      // Back button in AppBar for navigation UX
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark),
          onPressed: _isLoading ? null : () => Navigator.maybePop(context),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        top: false, // AppBar already handles the top safe area
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 56),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildFormCard(),
                        const Spacer(),
                        _buildLoginRow(),
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

  /// Paw-print logo – mirrors the Login Screen's layered circle style.
  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _primaryLight,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: _primary,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🐾', style: TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }

  /// Screen title and subtitle.
  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Join the Bio Pet community 🐶🐱',
          style: TextStyle(
            fontSize: 14,
            color: _textMuted,
          ),
        ),
      ],
    );
  }

  /// White rounded card containing the role selector + dynamic form fields.
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
            // ── Role selector ────────────────────────────────
            _buildRoleSelector(),
            const SizedBox(height: 24),

            // ── Dynamic fields per role ──────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              ),
              child: _selectedRole == UserRole.user
                  ? _buildUserFields()
                  : _buildShopOwnerFields(),
            ),

            const SizedBox(height: 24),

            // ── Register button ──────────────────────────────
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  // ── Role selector ─────────────────────────────────────────

  /// Segmented toggle to switch between User and Shop Owner roles.
  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('I am a…'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _buildRoleTab(
                label: '🐾  User',
                role: UserRole.user,
              ),
              _buildRoleTab(
                label: '🏪  Shop Owner',
                role: UserRole.shopOwner,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A single selectable tab inside the role selector.
  Widget _buildRoleTab({required String label, required UserRole role}) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: _isLoading
            ? null
            : () {
                if (_selectedRole != role) {
                  // Reset form errors when switching roles
                  _formKey.currentState?.reset();
                  setState(() => _selectedRole = role);
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── User fields ───────────────────────────────────────────

  /// Fields shown when the User role is selected.
  Widget _buildUserFields() {
    return Column(
      key: const ValueKey('user_fields'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Full Name'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _fullNameController,
          hint: 'Jane Doe',
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          validator: _requiredValidator('Full name'),
        ),
        const SizedBox(height: 18),
        _buildFieldLabel('Email'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          hint: 'you@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: _emailValidator,
        ),
        const SizedBox(height: 18),
        _buildFieldLabel('Password'),
        const SizedBox(height: 8),
        _buildPasswordField(
          controller: _passwordController,
          hint: '••••••••',
          obscure: _obscurePassword,
          onToggle: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          validator: _passwordValidator,
        ),
        const SizedBox(height: 18),
        _buildFieldLabel('Confirm Password'),
        const SizedBox(height: 8),
        _buildPasswordField(
          controller: _confirmPasswordController,
          hint: '••••••••',
          obscure: _obscureConfirmPassword,
          onToggle: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
          textInputAction: TextInputAction.done,
          validator: _confirmPasswordValidator,
        ),

      ],
    );
  }

  // ── Shop Owner fields ─────────────────────────────────────

  /// Fields shown when the Shop Owner role is selected.
  Widget _buildShopOwnerFields() {
    return Column(
      key: const ValueKey('shop_owner_fields'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Owner Name'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _ownerNameController,
          hint: 'John Smith',
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          validator: _requiredValidator('Owner name'),
        ),
        const SizedBox(height: 18),
        _buildFieldLabel('Shop Name'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _shopNameController,
          hint: 'Paws & Claws Pet Store',
          prefixIcon: Icons.storefront_outlined,
          textInputAction: TextInputAction.next,
          validator: _requiredValidator('Shop name'),
        ),
        const SizedBox(height: 18),
        _buildFieldLabel('Email'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          hint: 'shop@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: _emailValidator,
        ),
        const SizedBox(height: 18),
        _buildFieldLabel('Phone Number'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _phoneController,
          hint: '0812345678',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: _phoneValidator,
        ),
        const SizedBox(height: 18),
        _buildFieldLabel('Shop Address'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _shopAddressController,
          hint: '123 Paw Street, Bangkok 10100',
          prefixIcon: Icons.location_on_outlined,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          maxLines: 2,
          validator: _requiredValidator('Shop address'),
        ),
        const SizedBox(height: 18),
        _buildFieldLabel('Password'),
        const SizedBox(height: 8),
        _buildPasswordField(
          controller: _passwordController,
          hint: '••••••••',
          obscure: _obscurePassword,
          onToggle: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          validator: _passwordValidator,
        ),
        const SizedBox(height: 18),
        _buildFieldLabel('Confirm Password'),
        const SizedBox(height: 8),
        _buildPasswordField(
          controller: _confirmPasswordController,
          hint: '••••••••',
          obscure: _obscureConfirmPassword,
          onToggle: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
          textInputAction: TextInputAction.done,
          validator: _confirmPasswordValidator,
        ),
      ],
    );
  }

  // ── Reusable field widgets ────────────────────────────────

  /// Small bold label rendered above each field.
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

  /// Generic reusable [TextFormField].
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: !_isLoading,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
        prefixIcon: Icon(prefixIcon, color: _primary),
      ),
      validator: validator,
    );
  }

  /// Reusable password [TextFormField] with a show/hide suffix icon.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: textInputAction,
      enabled: !_isLoading,
      onFieldSubmitted:
      textInputAction == TextInputAction.done
          ? (_) => _handleRegister()
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
        prefixIcon: const Icon(Icons.lock_outline, color: _primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _textMuted,
          ),
          onPressed: _isLoading ? null : onToggle,
        ),
      ),
      validator: validator,
    );
  }

  /// Animated register button that morphs to a spinner during loading.
  Widget _buildRegisterButton() {
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
              key: const ValueKey('register'),
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Create Account'),
            ),
    );
  }

  /// "Already have an account? Login" row at the bottom.
  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(color: _textMuted, fontSize: 14),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
          child: const Text(
            'Login',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  // ── Validators ────────────────────────────────────────────

  /// Returns a validator that rejects empty values.
  String? Function(String?) _requiredValidator(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName cannot be empty.';
      }
      return null;
    };
  }

  /// Validates email format using a standard RFC-5322–style regex.
  String? _emailValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email cannot be empty.';
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(v)) return 'Please enter a valid email.';
    return null;
  }

  /// Validates that password is at least 6 characters.
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  /// Validates that confirm password matches the password field.
  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  /// Validates that phone contains only digits (enforced also by formatter).
  String? _phoneValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number cannot be empty.';
    if (!RegExp(r'^\d+$').hasMatch(v)) {
      return 'Phone number must contain only digits.';
    }
    return null;
  }
}
