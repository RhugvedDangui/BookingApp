import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test01/pages/login.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:test01/providers/user_provider.dart'; // Adjust path as needed

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _logout() async {
    try {
      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // Clear Provider state
      Provider.of<UserProvider>(context, listen: false).clearUser();

      // Clear SharedPreferences (optional, if you still want to use it for other settings)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      // Navigate to LoginPage and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access user data from UserProvider
    final userEmail = Provider.of<UserProvider>(context).userEmail ?? '';
    final userType =
        Provider.of<UserProvider>(context).userType ??
        'User'; // Default to 'User' if not set

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Settings').animate().fadeIn().scale(),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40),
                      ).animate().scale(),
                      const SizedBox(height: 8),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ).animate().fadeIn().slideY(),
                      Text(
                        'Account Type: $userType',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ).animate().fadeIn().slideY(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Toggle dark/light theme'),
                          secondary: const Icon(Icons.dark_mode),
                          value: _isDarkMode,
                          onChanged: (bool value) async {
                            final prefs = await SharedPreferences.getInstance();
                            setState(() {
                              _isDarkMode = value;
                            });
                            await prefs.setBool('isDarkMode', value);
                            // Implement theme change functionality here if needed
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Notifications'),
                          subtitle: const Text(
                            'Enable/disable push notifications',
                          ),
                          secondary: const Icon(Icons.notifications),
                          value: _notificationsEnabled,
                          onChanged: (bool value) async {
                            final prefs = await SharedPreferences.getInstance();
                            setState(() {
                              _notificationsEnabled = value;
                            });
                            await prefs.setBool('notificationsEnabled', value);
                            // Implement notification settings functionality here if needed
                          },
                        ),
                      ],
                    ),
                  ).animate().scale(),
                  const SizedBox(height: 24),
                  Text(
                    'Support',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.security),
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to privacy policy page
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: const Text('Terms of Service'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to terms of service page
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('About'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to about page
                          },
                        ),
                      ],
                    ),
                  ).animate().scale(),
                  const SizedBox(height: 24),
                  Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => _logout(),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.logout,
                          label: 'Confirm',
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: Text('Slide left to confirm logout'),
                      ),
                    ),
                  ).animate().scale(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
