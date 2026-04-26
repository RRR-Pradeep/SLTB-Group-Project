import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'asset_scan_screen.dart';
import 'view_records_screen.dart';
import 'login_screen.dart';
import 'my_profile_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final String userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Admin';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.blue.shade800,
      title: const Text('SLTB Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      actions: [
        StreamBuilder<List<ConnectivityResult>>(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, snapshot) {
            final results = snapshot.data ?? [ConnectivityResult.none];
            final isOffline = results.contains(ConnectivityResult.none);
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                isOffline ? Icons.cloud_off : Icons.cloud_done,
                color: isOffline ? Colors.redAccent : Colors.greenAccent,
                size: 20,
              ),
            );
          },
        ),
        PopupMenuButton<int>(
          offset: const Offset(0, 50),
          icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.blue)),
          onSelected: (value) {
            if (value == 0) setState(() => _selectedIndex = 3);
            else if (value == 1) _showLogoutDialog();
          },
          itemBuilder: (context) => [
            PopupMenuItem(enabled: false, child: Text(userEmail, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.account_circle, color: Colors.blue, size: 20), SizedBox(width: 10), Text('My Profile')])),
            const PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.logout, color: Colors.red, size: 20), SizedBox(width: 10), Text('Logout', style: TextStyle(color: Colors.red))])),
          ],
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      _buildHomeBody(),
      const ViewRecordsScreen(isReportMode: false),
      const ViewRecordsScreen(isReportMode: true),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: _selectedIndex == 0 ? _buildAppBar() : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: isDark ? Colors.blue.shade400 : Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    final String userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Admin';
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.blue.shade900, Colors.blue.shade700]
                    : [Colors.blue.shade700, Colors.blue.shade400],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_bus, color: Colors.white, size: 40),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome Back,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text(userEmail.split('@')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text('Survey Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 15),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('surveys')
                .where('uid', isEqualTo: currentUid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) return const Center(child: CircularProgressIndicator());

              int totalSurveys = snapshot.data?.docs.length ?? 0;
              int goodCondition = 0;
              int needsRepair = 0;
              for (var doc in snapshot.data?.docs ?? []) {
                String condition = doc['condition'] ?? '';
                if (condition.contains('Working')) goodCondition++; else needsRepair++;
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard('Total', totalSurveys.toString(), Colors.blue),
                  _buildStatCard('Working', goodCondition.toString(), Colors.green),
                  _buildStatCard('Issues', needsRepair.toString(), Colors.orange),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildActionButton(title: 'New Survey', icon: Icons.add_chart, color: Colors.blue.shade700, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AssetScanScreen()));
              })),
              const SizedBox(width: 15),
              Expanded(child: _buildActionButton(title: 'View Records', icon: Icons.folder_shared, color: Colors.indigo.shade600, onTap: () => setState(() => _selectedIndex = 1))),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildActionButton(title: 'Offline Sync', icon: Icons.sync, color: Colors.orange.shade700, onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Firebase will auto-sync when online.')));
              })),
              const SizedBox(width: 15),
              Expanded(child: _buildActionButton(title: 'Settings', icon: Icons.settings, color: Colors.teal.shade600, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 100, padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 5))],
        border: Border(bottom: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey : Colors.grey.shade700, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }
}