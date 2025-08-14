import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'HomePage.dart';
import 'Responsiveness.dart';
import 'businessRegistration.dart';
import 'confirmEmail.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (response.user != null) {
          if (response.user!.emailConfirmedAt != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please confirm your email before logging in.'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ConfirmEmailPage()),
            );
          }
        }
      } on AuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } catch (error) {
        setState(() {
          _errorMessage = error.toString();
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 850;

    return Scaffold(
      body: Stack(
        children: [
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
          _buildLoginForm(context),
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
          Expanded(child: _buildLoginForm(context)),
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
          Expanded(child: _buildLoginForm(context)),
        ],
      ),
    );
  }

  Widget _buildLogoAndTitle(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 850;

    return Column(
      crossAxisAlignment: isSmallScreen
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Track • Manage • Grow",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 11:16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isLoading,
          child: Opacity(
            opacity: _isLoading ? 0.5 : 1.0,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobile)
                    const SizedBox(height: 0)
                  else
                    const SizedBox(height: 20),
                  Text(
                    "Log In to your Account",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 15),
                      filled: true,
                      fillColor: const Color(0xFFF5FCF9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 15),
                      filled: true,
                      fillColor: const Color(0xFFF5FCF9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: isMobile ? double.infinity : 350,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _signIn(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BF6D),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 2,
                        minimumSize: const Size(double.infinity - 10, 60),
                      ),
                      child: Text(
                        "Log In",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 20,),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BusinessRegistrationPage()),
                          );
                        },
                        child: Text(
                          "Sign Up",
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
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Center(
              child: SizedBox(
                height: 100,
                child: Lottie.asset('assets/images/loadingtwodots.json'),
              ),
            ),
          ),
      ],
    );
  }
}