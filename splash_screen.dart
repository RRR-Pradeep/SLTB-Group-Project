import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 මේක අනිවාර්යයෙන්ම ඕනේ
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {

        User? user = FirebaseAuth.instance.currentUser;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(

            pageBuilder: (context, animation, secondaryAnimation) =>
            user != null ? const DashboardScreen() : const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_bus, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 25),
            const Text(
              'SLTB SURVEY APP',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Smart Asset Management Solution',
              style: TextStyle(fontSize: 14, color: Colors.white70, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const Spacer(),
            const Text(
              'Sri Lanka Transport Board',
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            const Text(
              'v1.0.5 Beta',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}