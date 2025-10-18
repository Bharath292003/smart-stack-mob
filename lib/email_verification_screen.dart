import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'auth_service.dart';
import 'home_page.dart';
import 'welcome_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  Timer? _timer;
  bool _isResendingEmail = false;
  bool _canResendEmail = true;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user?.emailVerified == true) {
        timer.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                userName: user?.displayName ?? user?.email ?? 'User',
                phoneNumber: '', // Firebase doesn't store phone by default
              ),
            ),
          );
        }
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResendEmail) return;

    setState(() {
      _isResendingEmail = true;
    });

    try {
      await _authService.sendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );

        // Start countdown
        setState(() {
          _canResendEmail = false;
          _resendCountdown = 60;
        });

        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_resendCountdown > 0) {
            setState(() {
              _resendCountdown--;
            });
          } else {
            timer.cancel();
            setState(() {
              _canResendEmail = true;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = _getErrorMessage(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResendingEmail = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF5A52E8),
              Color(0xFF4C46D6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Email verification icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF5A52E8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'We\'ve sent a verification email to:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      user?.email ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Please check your email and click the verification link to continue. This page will automatically update once your email is verified.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Spam folder guidance
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Can\'t find the email? Check your spam or junk folder. Consider adding our domain to your safe sender list.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Resend email button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _canResendEmail ? _resendVerificationEmail : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isResendingEmail
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _canResendEmail 
                                    ? 'Resend Verification Email'
                                    : 'Resend in ${_resendCountdown}s',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Sign out button
                    TextButton(
                      onPressed: _signOut,
                      child: const Text(
                        'Sign out and try with different email',
                        style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Auto-refresh indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Checking verification status...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(String error) {
    if (error.contains('TOO_MANY_ATTEMPTS_TRY_LATER') || error.contains('Too many verification email requests')) {
      return 'Too many verification email requests. Please wait a few minutes before requesting another verification email, or check your spam folder for the previous email.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.contains('user-not-found')) {
      return 'User account not found. Please try signing up again.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address. Please check your email and try again.';
    } else {
      return 'An error occurred while sending verification email. Please try again.';
    }
  }
}