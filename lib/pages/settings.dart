import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test01/pages/login.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:test01/pages/login.dart';
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
    final userEmail = Provider.of<UserProvider>(context).userEmail ?? '';
    final userType = Provider.of<UserProvider>(context).userType ?? 'User';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Settings')
                  .animate()
                  .fadeIn(duration: Duration(milliseconds: 600))
                  .scale(),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
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
                  ),
                  // Add a subtle pattern overlay
                  Opacity(
                    opacity: 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        backgroundBlendMode: BlendMode.overlay,
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white54],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white.withOpacity(0.9),
                              child: CircleAvatar(
                                radius: 42,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Icon(Icons.person, size: 40, color: Colors.white),
                              ),
                            ).animate().scale(),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  
                  // Account Section
                  _buildSectionHeader(context, 'Account', Icons.person_outline),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.account_circle,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Profile Settings'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to profile settings
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.password,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Change Password'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to change password
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.security,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Two-Factor Authentication'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to 2FA settings
                          },
                        ),
                      ],
                    ),
                  ).animate().slideX().fadeIn(),

                  const SizedBox(height: 24),
                  
                  // Appearance Section
                  _buildSectionHeader(context, 'Appearance', Icons.palette_outlined),
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
                          secondary: Icon(Icons.dark_mode,
                              color: Theme.of(context).colorScheme.primary),
                          value: _isDarkMode,
                          onChanged: (bool value) async {
                            final prefs = await SharedPreferences.getInstance();
                            setState(() {
                              _isDarkMode = value;
                            });
                            await prefs.setBool('isDarkMode', value);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.font_download,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Text Size'),
                          subtitle: const Text('Adjust app text size'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to text size settings
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.color_lens,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Theme Colors'),
                          subtitle: const Text('Customize app colors'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to theme color settings
                          },
                        ),
                      ],
                    ),
                  ).animate().slideX().fadeIn(),

                  const SizedBox(height: 24),

                  // Notifications Section
                  _buildSectionHeader(context, 'Notifications', Icons.notifications_none),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Push Notifications'),
                          subtitle: const Text('Enable/disable push notifications'),
                          secondary: Icon(Icons.notifications_active,
                              color: Theme.of(context).colorScheme.primary),
                          value: _notificationsEnabled,
                          onChanged: (bool value) async {
                            final prefs = await SharedPreferences.getInstance();
                            setState(() {
                              _notificationsEnabled = value;
                            });
                            await prefs.setBool('notificationsEnabled', value);
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Email Notifications'),
                          subtitle: const Text('Receive updates via email'),
                          secondary: Icon(Icons.mail,
                              color: Theme.of(context).colorScheme.primary),
                          value: true,
                          onChanged: (bool value) {
                            // Handle email notifications
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.schedule,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Quiet Hours'),
                          subtitle: const Text('Set notification-free times'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to quiet hours settings
                          },
                        ),
                      ],
                    ),
                  ).animate().slideX().fadeIn(),

                  const SizedBox(height: 24),

                  // Privacy & Security Section
                  _buildSectionHeader(context, 'Privacy & Security', Icons.security),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.privacy_tip,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Privacy Settings'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to privacy settings
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.lock,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('App Lock'),
                          subtitle: const Text('Secure app with biometrics'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to app lock settings
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.history,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Login History'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to login history
                          },
                        ),
                      ],
                    ),
                  ).animate().slideX().fadeIn(),

                  const SizedBox(height: 24),

                  // Support Section
                  _buildSectionHeader(context, 'Support', Icons.help_outline),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.help,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Help Center'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to help center
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.bug_report,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Report a Bug'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to bug report
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.feedback,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Send Feedback'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to feedback
                          },
                        ),
                      ],
                    ),
                  ).animate().slideX().fadeIn(),

                  const SizedBox(height: 24),

                  // About Section
                  _buildSectionHeader(context, 'About', Icons.info_outline),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.info,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('App Info'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to app info
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.description,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Terms of Service'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to terms
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(Icons.policy,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to privacy policy
                          },
                        ),
                      ],
                    ),
                  ).animate().slideX().fadeIn(),

                  const SizedBox(height: 32),

                  // Logout Section
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
                  ).animate().slideX().fadeIn(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}