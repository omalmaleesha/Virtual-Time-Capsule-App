import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:untitled/providers/auth_provider.dart';
import 'package:untitled/screens/auth/register_screen.dart';
import 'package:untitled/screens/home/home_screen.dart';
import 'package:untitled/theme/app_theme.dart';
import 'package:untitled/utils/animations.dart';
import 'package:untitled/widgets/animated_button.dart';
import 'package:untitled/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        Animations.fadeTransition(const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo
                  Animate(
                    effects: const [
                      ScaleEffect(
                        duration: Duration(seconds: 1),
                        curve: Curves.elasticOut,
                        begin: Offset(0.5, 0.5),
                        end: Offset(1, 1),
                      ),
                    ],
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hourglass_empty_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Welcome Text
                  Animate(
                    effects: [
                      FadeEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 300),
                      ),
                      SlideEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 300),
                        begin: const Offset(0, 0.2),
                        end: const Offset(0, 0),
                      ),
                    ],
                    child: const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Animate(
                    effects: [
                      FadeEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 400),
                      ),
                      SlideEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 400),
                        begin: const Offset(0, 0.2),
                        end: const Offset(0, 0),
                      ),
                    ],
                    child: const Text(
                      'Sign in to continue to your time capsules',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Error Message
                  if (authProvider.error != null)
                    Animate(
                      effects: const [
                        ShakeEffect(
                          duration: Duration(milliseconds: 500),
                          hz: 4,
                          offset: Offset(5, 0),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Colors.red.shade800,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  if (authProvider.error != null) const SizedBox(height: 24),
                  
                  // Email Field
                  Animate(
                    effects: [
                      FadeEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 500),
                      ),
                      SlideEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 500),
                        begin: const Offset(0, 0.2),
                        end: const Offset(0, 0),
                      ),
                    ],
                    child: CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      labelText: 'Email',
                      showLabel: true,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Password Field
                  Animate(
                    effects: [
                      FadeEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 600),
                      ),
                      SlideEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 600),
                        begin: const Offset(0, 0.2),
                        end: const Offset(0, 0),
                      ),
                    ],
                    child: CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      labelText: 'Password',
                      showLabel: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Forgot Password
                  Animate(
                    effects: [
                      FadeEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 700),
                      ),
                    ],
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Login Button
                  Animate(
                    effects: [
                      FadeEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 800),
                      ),
                      SlideEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 800),
                        begin: const Offset(0, 0.2),
                        end: const Offset(0, 0),
                      ),
                    ],
                    child: AnimatedButton(
                      text: 'Sign In',
                      isLoading: authProvider.isLoading,
                      onPressed: _login,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sign Up Link
                  Animate(
                    effects: [
                      FadeEffect(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 900),
                      ),
                    ],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              Animations.slideTransition(
                                const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
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
