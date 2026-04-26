import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// මීළඟට යන Screen එක මෙතන Import කරන්නම ඕනේ
import 'photo_evidence_screen.dart';

class AssetScanScreen extends StatefulWidget {
  const AssetScanScreen({super.key});

  @override
  State<AssetScanScreen> createState() => _AssetScanScreenState();
}

class _AssetScanScreenState extends State<AssetScanScreen> {
  final TextEditingController _assetIdController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;

  Future<void> _scanTextFromImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      setState(() => _isScanning = true);

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        _assetIdController.text = recognizedText.text.replaceAll('\n', ' ');
      });

      textRecognizer.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error scanning text. Please try again.')),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  void dispose() {
    _assetIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Survey Entry'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Equipment / Bus Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter the Asset ID manually or use the AI Scanner to capture it directly from the equipment.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _assetIdController,
              decoration: InputDecoration(
                labelText: 'Asset ID / Number Plate',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.directions_bus),
                suffixIcon: _isScanning
                    ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : IconButton(
                  icon: const Icon(Icons.document_scanner, color: Colors.blue),
                  onPressed: _scanTextFromImage,
                  tooltip: 'Scan with AI',
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {

                  if (_assetIdController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter or scan an Asset ID first!')),
                    );
                    return;
                  }


                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoEvidenceScreen(
                        assetId: _assetIdController.text.trim(),
                      ),
                    ),
                  );
                },
                child: const Text('Proceed to Photos', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}