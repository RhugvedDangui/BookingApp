import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test01/firebase_options.dart';
import 'package:test01/pages/booking.dart';
import 'package:test01/pages/homepage.dart';
import 'package:test01/pages/login.dart';
import 'package:test01/pages/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const SignupPage(),
        '/home': (context) => const Homepage(),
        '/booking': (context) => const BookingsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
