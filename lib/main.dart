import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test01/firebase_options.dart';
import 'package:test01/pages/admin_requests.dart';
import 'package:test01/pages/booking.dart';
import 'package:test01/pages/homepage.dart'; // UserHomepage
import 'package:test01/pages/login.dart';
import 'package:test01/pages/register.dart';
import 'package:test01/pages/settings.dart';
import 'package:test01/pages/admin_homepage.dart';
import 'package:test01/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io'; // Import for network connectivity check

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const SignupPage(),
        '/home': (context) => const UserHomepage(),
        '/booking': (context) => const BookingsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // Check network connectivity
  Future<bool> _hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      debugPrint('No internet connection available');
      return false;
    }
  }

  Future<bool> _isAdmin(String? email) async {
    if (email == null) {
      debugPrint('Email is null, returning false');
      return false;
    }
    
    // Check for network connectivity first
    bool hasNetwork = await _hasNetworkConnection();
    if (!hasNetwork) {
      debugPrint('No network connection, skipping Firestore admin check');
      // Return the cached admin status from provider if available
      // This will be handled by the caller
      return false;
    }
    
    try {
      debugPrint('Checking admin status for email: "$email"');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email.trim())
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final isAdmin = data['isAdmin'] == true;
        debugPrint('Firestore data for $email: $data');
        debugPrint('isAdmin value: $isAdmin');
        return isAdmin;
      } else {
        debugPrint('No document found for email: "$email"');
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final uidDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (uidDoc.exists) {
            final uidData = uidDoc.data() as Map<String, dynamic>;
            final isAdmin = uidData['isAdmin'] == true;
            debugPrint('Firestore UID data for ${user.uid}: $uidData');
            debugPrint('isAdmin value (UID): $isAdmin');
            return isAdmin;
          } else {
            debugPrint('No document found for UID: ${user.uid}');
          }
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          debugPrint('User signed in: "${user.email}"');
          
          // Get the UserProvider to check for cached admin status
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          
          return FutureBuilder<bool>(
            future: _hasNetworkConnection(),
            builder: (context, networkSnapshot) {
              // If we have network issues, use the cached admin status
              if (networkSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              final hasNetwork = networkSnapshot.data ?? false;
              
              // If no network, use the cached admin status from UserProvider
              if (!hasNetwork) {
                debugPrint('No network connection, using cached admin status: ${userProvider.isAdmin}');
                
                // If email matches and we have cached admin status, use it
                if (userProvider.userEmail == user.email) {
                  final isAdmin = userProvider.isAdmin;
                  
                  if (isAdmin) {
                    return const AdminHomepage();
                  } else {
                    return const UserHomepage();
                  }
                } else {
                  // If email doesn't match cached data, default to user homepage
                  debugPrint('Email mismatch or no cached data, defaulting to user homepage');
                  return const UserHomepage();
                }
              }
              
              // If we have network, proceed with Firestore check
              return FutureBuilder<bool>(
                future: _isAdmin(user.email),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (adminSnapshot.hasError) {
                    debugPrint('Admin check error: ${adminSnapshot.error}');
                    return const UserHomepage();
                  }
                  final isAdmin = adminSnapshot.data ?? false;
                  debugPrint('Redirecting - isAdmin: $isAdmin');

                  // Use post-frame callback to avoid calling setUser during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Provider.of<UserProvider>(context, listen: false).setUser(
                      user.email ?? '',
                      isAdmin: isAdmin,
                    );
                  });

                  if (isAdmin) {
                    return const AdminHomepage();
                  } else {
                    return const UserHomepage();
                  }
                },
              );
            },
          );
        } else {
          debugPrint('No user signed in, showing LoginPage');
          return const LoginPage();
        }
      },
    );
  }
}