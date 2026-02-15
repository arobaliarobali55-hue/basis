import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  // Password strength calculation
  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    if (strength == 0) return PasswordStrength.weak;
    if (strength <= 2) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(supabaseRepositoryProvider);

      if (_isSignUp) {
        await repository.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          companyName: _companyController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created! Please check your email to verify.',
              ),
              backgroundColor: AppTheme.accentColor,
              duration: Duration(seconds: 5),
            ),
          );
          // Switch to sign in mode
          setState(() {
            _isSignUp = false;
            _passwordController.clear();
          });
        }
      } else {
        await repository.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        String message = e.message;

        // Provide helpful error messages
        if (e.message.contains('Invalid login credentials')) {
          message = 'Invalid email or password. Please try again.';
        } else if (e.message.contains('Email not confirmed')) {
          message =
              'Please verify your email address before signing in. Check your inbox for the verification link.';
        } else if (_isSignUp && e.message.contains('already registered')) {
          message = 'This email is already registered. Switching to Sign In.';
          setState(() {
            _isSignUp = false;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Premium Background Decoration
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.backgroundColor,
                    AppTheme.surfaceColor.withValues(alpha: 0.5),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo & Title
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacing16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surfaceColor,
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/icon.png',
                              height: 64,
                              width: 64,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.account_balance_wallet,
                                    size: 48,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                        Text(
                          AppConstants.appName,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          AppConstants.appTagline,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                letterSpacing: 0.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing48),

                        // Company Name (Sign Up only)
                        if (_isSignUp) ...[
                          TextFormField(
                            controller: _companyController,
                            decoration: const InputDecoration(
                              labelText: 'Company Name',
                              prefixIcon: Icon(Icons.business),
                            ),
                            validator: (value) {
                              if (_isSignUp &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please enter your company name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                        ],

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            // Better email validation
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          onChanged: (value) {
                            if (_isSignUp) {
                              setState(
                                () {},
                              ); // Rebuild to update strength indicator
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (_isSignUp && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        // Password Strength Indicator (Sign Up only)
                        if (_isSignUp &&
                            _passwordController.text.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacing8),
                          _PasswordStrengthIndicator(
                            strength: _calculatePasswordStrength(
                              _passwordController.text,
                            ),
                          ),
                        ],

                        const SizedBox(height: AppTheme.spacing8),

                        // Forgot Password (Sign In only)
                        if (!_isSignUp)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text('Forgot Password?'),
                            ),
                          ),

                        const SizedBox(height: AppTheme.spacing16),

                        // Submit Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuth,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? 'Create Account' : 'Sign In',
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing16),

                        // Toggle Sign In / Sign Up
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _formKey.currentState?.reset();
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign In'
                                : 'Don\'t have an account? Sign Up',
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
}

// Password strength enum
enum PasswordStrength { none, weak, medium, strong }

// Password strength indicator widget
class _PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const _PasswordStrengthIndicator({required this.strength});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    double progress;

    switch (strength) {
      case PasswordStrength.weak:
        color = AppTheme.errorColor;
        text = 'Weak';
        progress = 0.33;
        break;
      case PasswordStrength.medium:
        color = AppTheme.warningColor;
        text = 'Medium';
        progress = 0.66;
        break;
      case PasswordStrength.strong:
        color = AppTheme.accentColor;
        text = 'Strong';
        progress = 1.0;
        break;
      case PasswordStrength.none:
        color = AppTheme.textTertiary;
        text = '';
        progress = 0;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.borderColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ),
            if (text.isNotEmpty) ...[
              const SizedBox(width: AppTheme.spacing8),
              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        if (strength == PasswordStrength.weak ||
            strength == PasswordStrength.medium) ...[
          const SizedBox(height: AppTheme.spacing4),
          Text(
            'Use 8+ characters with uppercase, numbers, and symbols',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ],
    );
  }
}
