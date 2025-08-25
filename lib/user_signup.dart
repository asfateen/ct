//user signup
import 'package:care_track/User_login.dart';
import 'package:care_track/home_user.dart';
import 'package:care_track/home_dr.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';

void main() {
  runApp(UserSignup());
}

class UserSignup extends StatefulWidget {
  const UserSignup({super.key});

  @override
  State<UserSignup> createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      final success = await appProvider.registerPatient(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful! User type: ${appProvider.userType}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate based on user type
        if (appProvider.userType == 'patient') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (appProvider.userType == 'doctor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeDr()),
          );
        }
      } else if (mounted) {
        _showError('Registration failed', 'Unable to create account. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showError('Network error', e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Create account',
                      style: TextStyle(
                        color: const Color(0xFF0080FF),
                        fontSize: isSmallScreen ? 24 : 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'SignUp to continue',
                      style: TextStyle(
                        color: const Color(0xFF0080FF),
                        fontSize: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      child: TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Full name is required';
                          if (value.length < 7) return 'Full name must be at least 7 characters';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email is required';
                          if (!RegExp(r'^[^@]+@(gmail|yahoo|hotmail|outlook)\.(com|net|org)$').hasMatch(value)) {
                            return 'Enter a valid email (gmail, yahoo, hotmail, outlook)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Phone number is required';
                          if (!RegExp(r'^(010|011|012|015)\d{8}$').hasMatch(value)) {
                            return 'Enter valid Egyptian phone number (010/011/012/015)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: isSmallScreen ? double.infinity : 300,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0080FF),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _loading ? null : _register,
                        child: _loading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Create Account',
                              style: TextStyle(fontSize: isSmallScreen ? 14 : 18)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const UserLogin()),
                            );
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}