import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = "English (US)";

  void _changePassword() {
    final TextEditingController emailController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Reset Password',
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your registered email to receive a password reset link.',
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              String enteredEmail = emailController.text.trim();


              if (enteredEmail == currentUserEmail) {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: enteredEmail);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reset link sent to $enteredEmail'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('An error occurred. Try again.'), backgroundColor: Colors.red),
                  );
                }
              } else {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Email does not match your registered account!'),
                      backgroundColor: Colors.orange
                  ),
                );
              }
            },
            child: const Text('Send Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: const Text('English'),
              onTap: () {
                setState(() => _selectedLanguage = "English (US)");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.translate, color: Colors.orange),
              title: const Text('සිංහල (Sinhala)'),
              onTap: () {
                setState(() => _selectedLanguage = "සිංහල (Sinhala)");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.blue.shade800,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const Text("General Settings", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),

          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            trailing: Switch(
              value: isDark,
              activeColor: Colors.blue.shade800,
              onChanged: (val) {
                themeProvider.toggleTheme(val);
              },
            ),
          ),

          _buildSettingsTile(
            icon: Icons.notifications_active,
            title: "Push Notifications",
            trailing: Switch(
              value: _notificationsEnabled,
              activeColor: Colors.blue.shade800,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
          ),

          const SizedBox(height: 20),
          const Text("Account & Security", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),


          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: "Change Password",
            subtitle: "Verify email & reset password",
            onTap: _changePassword,
          ),

          _buildSettingsTile(
            icon: Icons.language,
            title: "Language",
            subtitle: _selectedLanguage,
            onTap: _showLanguageDialog,
          ),

          const SizedBox(height: 20),
          const Text("System", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),

          _buildSettingsTile(
            icon: Icons.info_outline,
            title: "App Version",
            subtitle: "v1.0.5 (Stable)",
            onTap: () {},
          ),

          _buildSettingsTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {},
          ),

          const SizedBox(height: 30),
          Center(
            child: Text(
              'SLTB Asset Management v1.0.5',
              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2)
          )
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withOpacity(isDark ? 0.1 : 1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isDark ? Colors.blue.shade300 : Colors.blue.shade800, size: 22),
        ),
        title: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87
            )
        ),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey)) : null,
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white38 : Colors.grey),
        onTap: onTap,
      ),
    );
  }
}