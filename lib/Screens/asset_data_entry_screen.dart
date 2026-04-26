import 'package:flutter/material.dart';
import 'photo_evidence_screen.dart';

class AssetDataEntryScreen extends StatefulWidget {
  const AssetDataEntryScreen({super.key});

  @override
  State<AssetDataEntryScreen> createState() => _AssetDataEntryScreenState();
}

class _AssetDataEntryScreenState extends State<AssetDataEntryScreen> {
  String selectedCondition = 'Working';

  final TextEditingController _assetIdController = TextEditingController();

  @override
  void dispose() {
    _assetIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Details'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildSectionHeader('General Information'),
            const SizedBox(height: 10),


            _buildTextField('Asset ID / Serial Number', Icons.qr_code_scanner, controller: _assetIdController),
            const SizedBox(height: 15),
            _buildTextField('Equipment Name', Icons.settings_suggest),

            const SizedBox(height: 25),


            _buildSectionHeader('Equipment Condition'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCondition,
                  isExpanded: true,
                  items: ['Working', 'Faulty', 'Under Repair', 'Broken']
                      .map((String value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedCondition = val!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),


            _buildSectionHeader('Additional Remarks'),
            const SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter any other observations here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 40),


            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {

                  String enteredId = _assetIdController.text.trim();
                  if (enteredId.isEmpty) {
                    enteredId = 'Manual Entry';
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoEvidenceScreen(
                        assetId: enteredId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text('Next: Take Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
    );
  }

  Widget _buildTextField(String label, IconData icon, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
        ),
      ),
    );
  }
}