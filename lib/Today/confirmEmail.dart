// confirmEmail.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homePage.dart'; // Replace with your actual home page

class ConfirmEmailPage extends StatefulWidget {
  const ConfirmEmailPage({super.key});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  DateTime? _lastChecked;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _listenToAuthChanges();
  }

  // Listen to auth state changes (e.g., if user logs in from another device)
  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      final user = session?.user;

      if (event == AuthChangeEvent.signedIn && user != null) {
        if (user.emailConfirmedAt != null) {
          _navigateToHome();
        }
      }

      if (event == AuthChangeEvent.userUpdated) {
        // This may fire after email confirmation
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser?.emailConfirmedAt != null) {
          _navigateToHome();
        }
      }
    });
  }

  // Poll server periodically in case onAuthStateChange doesn't catch it
  void _startPolling() {
    _lastChecked = DateTime.now();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _checkEmailConfirmation();
      }
    });
  }

  Future<void> _checkEmailConfirmation() async {
    if (_isConfirmed) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    if (user.emailConfirmedAt != null) {
      if (mounted) {
        _navigateToHome();
      }
      return;
    }

    // Retry every 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      _checkEmailConfirmation();
    }
  }

  void _navigateToHome() {
    if (_isConfirmed) return;
    _isConfirmed = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      color: Color(0xFF00BF6D),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Confirm Your Email",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      "We've sent a confirmation link to ${Supabase.instance.client.auth.currentUser?.email}. Click it to verify your account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () {
                      // Optional: Resend confirmation email
                      _resendConfirmationEmail();
                    },
                    child: Text(
                      "Resend Confirmation Email",
                      style: TextStyle(color: const Color(0xFF00BF6D), fontSize: 14),
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

  Future<void> _resendConfirmationEmail() async {
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email == null) return;

    try {
      await Supabase.instance.client.auth.resend(
        email: email,
        type: OtpType.signup,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Confirmation email resent!")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resend: $error")),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}