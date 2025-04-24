import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test01/pages/register.dart';
import 'package:test01/pages/admin_homepage.dart';
import 'package:test01/pages/homepage.dart';
import 'package:test01/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  TabController? tabController;
  bool isEmailSelected = true;
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final Color buttonColor = const Color.fromARGB(255, 177, 95, 191);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController?.addListener(() {
      if (mounted) {
        setState(() {
          isEmailSelected = tabController?.index == 0;
        });
      }
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> _isAdmin(String email) async {
    try {
      // Check network connectivity first
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          debugPrint('LoginPage - No internet connection');
          return false;
        }
      } on SocketException catch (_) {
        debugPrint('LoginPage - No internet connection (SocketException)');
        return false;
      }

      debugPrint('LoginPage - Checking admin status for email: "$email"');
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(email.trim())
              .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final isAdmin = data['isAdmin'] == true;
        debugPrint('LoginPage - Firestore data: $data');
        debugPrint('LoginPage - isAdmin value: $isAdmin');
        return isAdmin;
      } else {
        debugPrint('LoginPage - No document found for email: "$email"');
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final uidDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();
          if (uidDoc.exists) {
            final uidData = uidDoc.data() as Map<String, dynamic>;
            final isAdmin = uidData['isAdmin'] == true;
            debugPrint(
              'LoginPage - Firestore UID data for ${user.uid}: $uidData',
            );
            debugPrint('LoginPage - isAdmin value (UID): $isAdmin');
            return isAdmin;
          } else {
            debugPrint('LoginPage - No document found for UID: ${user.uid}');
          }
        }
        return false;
      }
    } catch (e) {
      debugPrint('LoginPage - Error checking admin status: $e');
      return false;
    }
  }

  void handleLogin() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both email and password')),
        );
      }
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (!mounted) return;

      if (userCredential.user?.emailVerified ?? false) {
        // Check network connectivity before admin verification
        bool hasNetwork = true;
        try {
          final result = await InternetAddress.lookup('google.com');
          hasNetwork = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } on SocketException catch (_) {
          hasNetwork = false;
        }

        bool isAdmin = false;
        if (hasNetwork) {
          isAdmin = await _isAdmin(email);
          if (!mounted) return;
        } else {
          // Show network error message but continue with user access
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Network unavailable. Proceeding with limited access.'),
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Only update provider after successful verification
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).setUser(email, isAdmin: isAdmin);

        if (isAdmin && hasNetwork) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomepage()),
          );
        } else {
          // Default to user homepage if not admin or no network
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomepage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please verify your email before logging in.'),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (!mounted) return;
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found with that email.')),
          );
          break;
        case 'wrong-password':
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Incorrect password.')));
          break;
        case 'invalid-email':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email format.')),
          );
          break;
        case 'user-disabled':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This user account has been disabled.'),
            ),
          );
          break;
        case 'too-many-requests':
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Too many attempts. Please try again later.'),
            ),
          );
          break;
        default:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Login failed: ${e.message}')));
      }
    } catch (e) {
      if (!mounted) return;
      print('Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  void handleForgotPassword() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email address')),
        );
      }
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Check your inbox.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found with that email.')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Container(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: "WorkSans",
                      ),
                    ),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.email),
                        SizedBox(width: 8),
                        Text('Email'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.phone),
                        SizedBox(width: 8),
                        Text('Phone Number'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isEmailSelected)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: 'Enter Your Email',
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: 'Enter Your Phone Number',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: 'Enter Your Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: handleForgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    backgroundColor: buttonColor,
                  ),
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
