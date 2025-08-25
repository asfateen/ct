//user login
import 'package:care_track/user_signup.dart';
import 'package:care_track/home_user.dart';
import 'package:care_track/home_dr.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';

void main() {
  runApp(const UserLogin());
}

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autoValidateMode = AutovalidateMode.always);
      return;
    }

    setState(() => _loading = true);
    
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    try {
      final success = await appProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Show success message and debug info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful! User type: ${appProvider.userType}'),
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
            MaterialPageRoute(builder: (context) => HomeDr()),
          );
        }
      } else if (mounted) {
        _showError('Login failed', 'Invalid email or password');
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidateMode,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome To CareTrack',
                    style: TextStyle(
                      color: const Color(0xFF0080FF),
                      fontSize: isSmallScreen ? 24 : 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Login With Email',
                    style: TextStyle(
                      color: const Color(0xFF0080FF),
                      fontSize: isSmallScreen ? 20 : 24,
                    ),
                  ),
                  const SizedBox(height: 60),
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
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 30),
                  SizedBox(
                    width: isSmallScreen ? double.infinity : 300,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0080FF),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : Text('Login', style: TextStyle(fontSize: isSmallScreen ? 14 : 18)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?  "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserSignup()),
                          );
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
    );
  }
}