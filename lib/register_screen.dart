import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:biopet/services/api_service.dart';
import 'Login_Screen.dart';
import 'email_verification_screen.dart';

enum UserRole { user, shopOwner }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameController = TextEditingController();

  final _ownerNameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopAddressController = TextEditingController();

  UserRole _selectedRole = UserRole.user;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Emerald + Mint + Cream theme
  static const Color _emerald = Color(0xFF065F46);
  static const Color _emeraldDark = Color(0xFF064E3B);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _mintSoft = Color(0xFFE9FBF3);
  static const Color _cream = Color(0xFFFFF8E7);
  static const Color _surface = Color(0xFFFFFEFA);
  static const Color _textDark = Color(0xFF102A22);
  static const Color _textMuted = Color(0xFF6C7E77);
  static const Color _border = Color(0xFFD9ECE4);

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

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      late final Map<String, dynamic> data;

      final email = _emailController.text.trim();

      if (_selectedRole == UserRole.user) {
        data = await ApiService.registerUser(
          name: _fullNameController.text.trim(),
          email: email,
          password: _passwordController.text,
        );
      } else {
        data = await ApiService.registerShopOwner(
          ownerName: _ownerNameController.text.trim(),
          shopName: _shopNameController.text.trim(),
          email: email,
          phone: _phoneController.text.trim(),
          shopAddress: _shopAddressController.text.trim(),
          password: _passwordController.text,
        );
      }

      debugPrint('REGISTER RESPONSE => $data');

      if (!mounted) return;

      if (data['success'] == true) {
        // Get OTP returned from backend
        final otp = data['otp']?.toString() ?? '';

        debugPrint('OTP FROM SERVER => $otp');

        if (otp.isEmpty) {
          _showMessage(
            'Registration successful, but OTP was not generated.',
            isError: true,
          );
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              email: email,
              otp: otp,
            ),
          ),
        );
      } else {
        _showMessage(
          data['message']?.toString() ?? 'Registration failed.',
          isError: true,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('REGISTER ERROR => $error');
      debugPrint('STACK TRACE => $stackTrace');

      if (mounted) {
        _showMessage(
          'Error: $error',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? const Color(0xFFB42318) : _emerald,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          onPressed: _isLoading ? null : () => Navigator.maybePop(context),
          tooltip: 'Back',
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _surface.withOpacity(0.94),
              shape: BoxShape.circle,
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: _textDark,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const _BackgroundDecoration(),
          SafeArea(
            top: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      4,
                      20,
                      24 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          children: [
                            _buildBrandHeader(),
                            const SizedBox(height: 24),
                            _buildFormCard(),
                            const SizedBox(height: 20),
                            _buildLoginRow(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 86,
          height: 86,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.92),
            shape: BoxShape.circle,
            border: Border.all(color: _mint, width: 2),
            boxShadow: [
              BoxShadow(
                color: _emerald.withOpacity(0.16),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_emerald, _emeraldDark],
              ),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Create your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textDark,
            fontSize: 29,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Join BioPet and make pet care easier every day.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _textMuted,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.97),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _emerald.withOpacity(0.10),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.90),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: _mintSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: _emerald,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account details',
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choose an account type and fill in your information.',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _buildRoleSelector(),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: _selectedRole == UserRole.user
                  ? _buildUserFields()
                  : _buildShopOwnerFields(),
            ),
            const SizedBox(height: 26),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Account type'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _mintSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              _buildRoleTab(
                role: UserRole.user,
                icon: Icons.person_outline_rounded,
                label: 'Pet Owner',
              ),
              _buildRoleTab(
                role: UserRole.shopOwner,
                icon: Icons.storefront_outlined,
                label: 'Shop Owner',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleTab({
    required UserRole role,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedRole == role;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading
              ? null
              : () {
            if (_selectedRole == role) return;
            _formKey.currentState?.reset();
            setState(() => _selectedRole = role);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? _emerald : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: _emerald.withOpacity(0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : _emerald,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserFields() {
    return Column(
      key: const ValueKey('user_fields'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledTextField(
          label: 'Full name',
          controller: _fullNameController,
          hint: 'Enter your full name',
          prefixIcon: Icons.person_outline_rounded,
          validator: _requiredValidator('Full name'),
        ),
        const SizedBox(height: 17),
        _buildEmailField(),
        const SizedBox(height: 17),
        _buildPasswordFields(),
      ],
    );
  }

  Widget _buildShopOwnerFields() {
    return Column(
      key: const ValueKey('shop_owner_fields'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledTextField(
          label: 'Owner name',
          controller: _ownerNameController,
          hint: 'Enter owner name',
          prefixIcon: Icons.person_outline_rounded,
          validator: _requiredValidator('Owner name'),
        ),
        const SizedBox(height: 17),
        _buildLabeledTextField(
          label: 'Shop name',
          controller: _shopNameController,
          hint: 'Enter your shop name',
          prefixIcon: Icons.storefront_outlined,
          validator: _requiredValidator('Shop name'),
        ),
        const SizedBox(height: 17),
        _buildEmailField(hint: 'shop@example.com'),
        const SizedBox(height: 17),
        _buildLabeledTextField(
          label: 'Phone number',
          controller: _phoneController,
          hint: '09xxxxxxxxx',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: _phoneValidator,
        ),
        const SizedBox(height: 17),
        _buildLabeledTextField(
          label: 'Shop address',
          controller: _shopAddressController,
          hint: 'Enter your shop address',
          prefixIcon: Icons.location_on_outlined,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          maxLines: 2,
          validator: _requiredValidator('Shop address'),
        ),
        const SizedBox(height: 17),
        _buildPasswordFields(),
      ],
    );
  }

  Widget _buildEmailField({String hint = 'you@example.com'}) {
    return _buildLabeledTextField(
      label: 'Email address',
      controller: _emailController,
      hint: hint,
      prefixIcon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      validator: _emailValidator,
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Password'),
        const SizedBox(height: 8),
        _buildPasswordField(
          controller: _passwordController,
          hint: 'At least 6 characters',
          obscure: _obscurePassword,
          onToggle: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          validator: _passwordValidator,
        ),
        const SizedBox(height: 17),
        _buildFieldLabel('Confirm password'),
        const SizedBox(height: 8),
        _buildPasswordField(
          controller: _confirmPasswordController,
          hint: 'Re-enter your password',
          obscure: _obscureConfirmPassword,
          onToggle: () {
            setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
            );
          },
          textInputAction: TextInputAction.done,
          validator: _confirmPasswordValidator,
        ),
      ],
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller,
          hint: hint,
          prefixIcon: prefixIcon,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _textDark,
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }

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
      cursorColor: _emerald,
      style: const TextStyle(
        color: _textDark,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: _inputDecoration(
        hint: hint,
        prefixIcon: prefixIcon,
      ),
      validator: validator,
    );
  }

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
      cursorColor: _emerald,
      style: const TextStyle(
        color: _textDark,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
      onFieldSubmitted: textInputAction == TextInputAction.done
          ? (_) => _handleRegister()
          : null,
      decoration: _inputDecoration(
        hint: hint,
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          onPressed: _isLoading ? null : onToggle,
          splashRadius: 20,
          tooltip: obscure ? 'Show password' : 'Hide password',
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _textMuted,
            size: 21,
          ),
        ),
      ),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9AA9A3),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(prefixIcon, color: _emerald, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _mintSoft.withOpacity(0.56),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(_border),
      disabledBorder: border(_border.withOpacity(0.65)),
      focusedBorder: border(_emerald, width: 1.6),
      errorBorder: border(const Color(0xFFE0716B), width: 1.2),
      focusedErrorBorder: border(const Color(0xFFB42318), width: 1.5),
      errorStyle: const TextStyle(
        color: Color(0xFFB42318),
        fontSize: 11.5,
        height: 1.25,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: _isLoading
          ? Container(
        key: const ValueKey('loading'),
        width: double.infinity,
        height: 57,
        decoration: BoxDecoration(
          color: _emerald,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      )
          : SizedBox(
        key: const ValueKey('register'),
        width: double.infinity,
        height: 57,
        child: ElevatedButton(
          onPressed: _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: _emerald,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _emerald.withOpacity(0.65),
            elevation: 0,
            shadowColor: _emerald.withOpacity(0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(
            color: _textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: _emerald,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  String? Function(String?) _requiredValidator(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName cannot be empty.';
      }
      return null;
    };
  }

  String? _emailValidator(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email cannot be empty.';

    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final String phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Phone number cannot be empty.';
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return 'Phone number must contain only digits.';
    }
    if (phone.length < 7) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  static const Color _emerald = Color(0xFF065F46);
  static const Color _mint = Color(0xFFA7F3D0);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -95,
            right: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _mint.withOpacity(0.34),
              ),
            ),
          ),
          Positioned(
            top: 130,
            left: -92,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _emerald.withOpacity(0.055),
              ),
            ),
          ),
          Positioned(
            bottom: 95,
            right: -105,
            child: Container(
              width: 245,
              height: 245,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _mint.withOpacity(0.22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
