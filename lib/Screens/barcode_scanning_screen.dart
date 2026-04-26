import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'asset_data_entry_screen.dart';

class BarcodeScanningScreen extends StatefulWidget {
  const BarcodeScanningScreen({super.key});

  @override
  State<BarcodeScanningScreen> createState() => _BarcodeScanningScreenState();
}

class _BarcodeScanningScreenState extends State<BarcodeScanningScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan or Enter ID'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [

          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AssetDataEntryScreen()),
                );
              }
            },
          ),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const Text(
                  'Scan QR Code',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'OR',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AssetDataEntryScreen()),
                      );
                    },
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Enter ID Manually'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.blue.shade900,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}