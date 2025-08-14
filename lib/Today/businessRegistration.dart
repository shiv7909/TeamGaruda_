import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'Responsiveness.dart';
import 'confirmEmail.dart';
import 'loginView2.dart'; // Assuming this is your LoginPage

class BusinessRegistrationPage extends StatefulWidget {
  const BusinessRegistrationPage({super.key});

  @override
  _BusinessRegistrationPageState createState() => _BusinessRegistrationPageState();
}

class _BusinessRegistrationPageState extends State<BusinessRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reEnterPasswordController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _registerBusiness(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text.trim() != _reEnterPasswordController.text.trim()) {
        setState(() {
          _errorMessage = 'Passwords do not match';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final AuthResponse response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );


        final user = response.user;

        if (user == null) {
          setState(() {
            _errorMessage = 'Registration failed. User not created.';
          });
          return;
        }

        // ✅ User created, now insert into businesses table
        final String userId = user.id;

        await Supabase.instance.client.from('businesses').insert({
          'id': userId,
          'business_name': _businessNameController.text.trim(),
          'business_type': _businessTypeController.text.trim(),
          'contact_person': _contactPersonController.text.trim(),
          'phone_number': _phoneNumberController.text.trim(),
        });

        // ✅ Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please check your email to confirm your account.'),
            backgroundColor: Colors.green,
          ),
        );

        // 🔐 Navigate to confirm email page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ConfirmEmailPage()),
        );

      } on AuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } catch (error) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: ${error.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _reEnterPasswordController.dispose();
    _businessTypeController.dispose();
    _contactPersonController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 850;

    return Scaffold(
      body: Stack(
        children: [
          // Blurred background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                SafeArea(
                  minimum: EdgeInsets.all(size.height * 0.1),
                  child: Responsive(
                    mobile: _buildMobileLayout(context),
                    tablet: _buildTabletLayout(context),
                    desktop: _buildDesktopLayout(context),
                  ),
                ),
                if (!isMobile)
                  const SizedBox(height: 89)
                else
                  const SizedBox(height: 10),
              ],
            ),
          ),

          // Global loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: SizedBox(
                    height: 100,
                    child: Lottie.asset('assets/images/loadingtwodots.json'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLogoAndTitle(context),
          const SizedBox(height: 40),
          _buildRegistrationForm(context),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45.0),
      child: Row(
        children: [
          Expanded(child: _buildLogoAndTitle(context)),
          Expanded(child: _buildRegistrationForm(context)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64.0),
      child: Row(
        children: [
          Expanded(child: _buildLogoAndTitle(context)),
          Expanded(child: _buildRegistrationForm(context)),
        ],
      ),
    );
  }

  Widget _buildLogoAndTitle(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 850;

    return Column(
      crossAxisAlignment: isSmallScreen ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.asset(
            "assets/images/circle_logo.png",
            height: isSmallScreen ? 100 : 120,
            width: isSmallScreen ? 100 : 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Revenue Radar",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 25 : 29,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Track • Manage • Grow",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontSize: isSmallScreen ? 11 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile) const SizedBox(height: 20),
            Text(
              "Register your Business",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),

            // Business Name
            TextFormField(
              controller: _businessNameController,
              decoration: _inputDecoration('Business Name'),
              validator: (value) => value?.isEmpty == true ? 'Enter business name' : null,
            ),
            const SizedBox(height: 16),

            // Business Type
            TextFormField(
              controller: _businessTypeController,
              decoration: _inputDecoration('Business Type (e.g., Retail, Service)'),
              validator: (value) => value?.isEmpty == true ? 'Enter business type' : null,
            ),
            const SizedBox(height: 16),

            // Contact Person
            TextFormField(
              controller: _contactPersonController,
              decoration: _inputDecoration('Contact Person Name'),
              validator: (value) => value?.isEmpty == true ? 'Enter contact person name' : null,
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Phone Number'),
              validator: (value) {
                if (value?.isEmpty == true) return 'Enter phone number';
                if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value!)) return 'Invalid phone number';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Email'),
              validator: (value) {
                if (value?.isEmpty == true) return 'Enter your email';
                if (!value!.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration('Password'),
              validator: (value) {
                if (value?.isEmpty == true) return 'Enter password';
                if (value!.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Re-enter Password
            TextFormField(
              controller: _reEnterPasswordController,
              obscureText: true,
              decoration: _inputDecoration('Re-enter Password'),
              validator: (value) {
                if (value?.isEmpty == true) return 'Please re-enter password';
                if (value != _passwordController.text.trim()) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Error Message
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            const SizedBox(height: 16),

            // Register Button
            SizedBox(
              width: isMobile ? double.infinity : 350,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _registerBusiness(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BF6D),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Register",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Login Prompt
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: Text(
                    "Sign In",
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF00BF6D),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Reusable input decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 15),
      filled: true,
      fillColor: const Color(0xFFF5FCF9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}