import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/social_auth_button.dart';
import '../../../core/widgets/ocean_backdrop.dart';
import '../../../core/widgets/aura_logo.dart';
import 'auth_provider.dart';
import '../../../core/theme/theme_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool startWithRegister;
  const LoginScreen({super.key, this.startWithRegister = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscureText = true;

  // Register Controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  bool _registerObscureText = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.startWithRegister ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  void _handleLogin() {
    if (_loginFormKey.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .signIn(
            _loginEmailController.text.trim(),
            _loginPasswordController.text,
          );
    }
  }

  void _handleRegister() {
    if (_registerFormKey.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .signUp(
            _registerEmailController.text.trim(),
            _registerPasswordController.text,
            _registerNameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    // Listen for authenticated status to navigate to home
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        // Check if mood is already persisted — skip mood selection
        final themeState = ref.read(themeProvider);
        if (themeState.hasMoodSelected) {
          context.go('/home');
        } else {
          context.go('/mood-selection');
        }
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: OceanBackdrop(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top banner with brand logo
              Container(
                width: double.infinity,
                height: size.height * 0.32,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AuraLogo.icon(size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Aura AI',
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.oceanNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your Personal AI Companion',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: AppColors.oceanBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // White form card overlay
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1C24) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.skyBlue.withValues(alpha: 0.25),
                        width: 2.5,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.oceanBlue.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      // Tab Bar Custom Design
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF141318)
                              : AppColors.blueWhite,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          labelColor: isDark
                              ? AppColors.skyBlue
                              : AppColors.clearBlue,
                          unselectedLabelColor: AppColors.secondaryText,
                          labelStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: const [
                            Tab(text: 'Sign In'),
                            Tab(text: 'Register'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tab View Content
                      SizedBox(
                        height: 600,
                        child: TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            // Sign In Form View
                            SingleChildScrollView(
                              child: _buildSignInForm(authState),
                            ),

                            // Register Form View
                            SingleChildScrollView(
                              child: _buildRegisterForm(authState),
                            ),
                          ],
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
    );
  }

  Widget _buildSignInForm(AuthState authState) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Email Address',
            hintText: 'name@example.com',
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Password',
            hintText: '••••••••',
            controller: _loginPasswordController,
            obscureText: _loginObscureText,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            suffixIcon: IconButton(
              icon: Icon(
                _loginObscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.lightTextSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _loginObscureText = !_loginObscureText;
                });
              },
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 12),

          // Forgot Password Link Row
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/forgot-password'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: isDark ? AppColors.skyBlue : AppColors.clearBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Primary Sign In Button
          PrimaryButton(
            text: 'Sign In',
            isLoading: authState.status == AuthStatus.authenticating,
            onPressed: _handleLogin,
            gradient: AppColors.oceanGradient,
          ),
          const SizedBox(height: 24),

          // Divider Section
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark
                      ? AppColors.darkCardBorder
                      : AppColors.skyBlue.withValues(alpha: 0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or continue with',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark
                      ? AppColors.darkCardBorder
                      : AppColors.skyBlue.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Social Login Buttons
          SocialAuthButton(
            text: 'Google',
            icon: const GoogleLogo(),
            onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
          ),
          const SizedBox(height: 16),
          SocialAuthButton(
            text: 'Apple',
            icon: const Icon(Icons.apple, color: Colors.black, size: 20),
            onPressed: () => ref.read(authProvider.notifier).signInWithApple(),
          ),
          const SizedBox(height: 32),

          // Sign In Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => _tabController.animateTo(1),
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    color: isDark ? AppColors.skyBlue : AppColors.clearBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthState authState) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Full Name',
            hintText: 'Your Name',
            controller: _registerNameController,
            prefixIcon: Icons.person_outline_rounded,
            validator: _validateName,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Email Address',
            hintText: 'name@example.com',
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Password',
            hintText: '••••••••',
            controller: _registerPasswordController,
            obscureText: _registerObscureText,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
            suffixIcon: IconButton(
              icon: Icon(
                _registerObscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.lightTextSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _registerObscureText = !_registerObscureText;
                });
              },
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 28),

          // Primary Register Button
          PrimaryButton(
            text: 'Sign Up',
            isLoading: authState.status == AuthStatus.authenticating,
            onPressed: _handleRegister,
            gradient: AppColors.oceanGradient,
          ),
          const SizedBox(height: 24),

          // Divider Section
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark
                      ? AppColors.darkCardBorder
                      : AppColors.skyBlue.withValues(alpha: 0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or continue with',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark
                      ? AppColors.darkCardBorder
                      : AppColors.skyBlue.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Social Login Buttons
          SocialAuthButton(
            text: 'Google',
            icon: const GoogleLogo(),
            onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
          ),
          const SizedBox(height: 16),
          SocialAuthButton(
            text: 'Apple',
            icon: const Icon(Icons.apple, color: Colors.black, size: 20),
            onPressed: () => ref.read(authProvider.notifier).signInWithApple(),
          ),
          const SizedBox(height: 32),

          // Register Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => _tabController.animateTo(0),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: isDark ? AppColors.skyBlue : AppColors.clearBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
