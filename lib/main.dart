import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test01/firebase_options.dart';
import 'package:test01/pages/admin_HomePage.dart';
import 'package:test01/pages/booking.dart';
import 'package:test01/pages/homepage.dart';
import 'package:test01/pages/login.dart';
import 'package:test01/pages/register.dart';
import 'package:test01/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      home: AuthWrapper(), // Use AuthWrapper to determine initial screen
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

// Widget to handle authentication state and routing
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading screen while checking auth state
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // User is signed in
          final user = snapshot.data!;
          // Set the email in UserProvider
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).setUser(user.email ?? '');
          return const UserHomepage(); // Navigate directly to BookingsPage
        } else {
          // User is not signed in
          return const LoginPage(); // Show LoginPage
        }
      },
    );
  }
}
