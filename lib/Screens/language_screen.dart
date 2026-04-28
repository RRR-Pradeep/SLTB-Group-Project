import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language / භාෂාව'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Select your preferred language:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildLanguageOption('English'),
          _buildLanguageOption('සිංහල (Sinhala)'),
          _buildLanguageOption('தமிழ் (Tamil)'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: RadioListTile<String>(
        title: Text(language, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        value: language,
        groupValue: _selectedLanguage,
        activeColor: Colors.blue.shade800,
        onChanged: (value) {
          setState(() {
            _selectedLanguage = value!;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Language updated to $language')),
          );
        },
      ),
    );
  }
}