import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _buildNotificationCard('New Survey Assigned', 'A new equipment survey has been assigned.', '10 mins ago', Icons.assignment, Colors.blue),
          _buildNotificationCard('Sync Successful', 'Offline survey data has been synced.', '2 hours ago', Icons.sync, Colors.green),
          _buildNotificationCard('System Update', 'SLTB App version 1.0.1 is available.', '1 day ago', Icons.system_update, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String title, String body, String time, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(body),
            const SizedBox(height: 5),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}