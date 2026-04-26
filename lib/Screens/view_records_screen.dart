import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shimmer/shimmer.dart';

class ViewRecordsScreen extends StatefulWidget {
  final bool isReportMode;
  const ViewRecordsScreen({super.key, this.isReportMode = false});

  @override
  State<ViewRecordsScreen> createState() => _ViewRecordsScreenState();
}

class _ViewRecordsScreenState extends State<ViewRecordsScreen> {
  String _searchQuery = "";
  final String _geminiApiKey = 'AIzaSyC2SnPUtpiM9UzSvLQRVh9vLjYX8PhajbM';

  Future<String> _getAiPrediction(String assetId, List<QueryDocumentSnapshot> allDocs) async {
    try {
      var history = allDocs
          .where((doc) => doc['asset_id'] == assetId)
          .take(5)
          .map((doc) => "Date: ${doc['date_time'].toDate().toString().split(' ')[0]}, Status: ${doc['condition']}")
          .join("\n");

      if (history.isEmpty) return "No history found for analysis.";

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
        ],
      );

      final prompt = "As an SLTB expert, analyze history for bus $assetId:\n$history\nPredict if it needs repair or service. 2 short sentences.";
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Analysis unavailable.";
    } catch (e) {
      return "AI Insight currently unavailable.";
    }
  }

  Future<void> _generatePdf(List<QueryDocumentSnapshot> docs) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text("SLTB Asset Survey Report", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Asset ID', 'Condition', 'User', 'Date'],
            data: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return [
                data['asset_id'],
                data['condition'],
                data['user_email'] ?? 'N/A',
                data['date_time'].toDate().toString().split(' ')[0]
              ];
            }).toList(),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Widget _buildShimmerPlaceholder() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const SizedBox(height: 100, width: double.infinity),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? Colors.blue.shade900 : Colors.blue.shade800;
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.isReportMode ? 'AI Reports' : 'Survey History',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: isDark ? Colors.grey.shade900 : Colors.white,
            child: TextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Search Asset ID (e.g. NB-1234)...',
                hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.blue.shade400 : Colors.blue.shade800),
                filled: true,
                fillColor: isDark ? Colors.black : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toUpperCase().trim()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('surveys')
                  .orderBy('date_time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerPlaceholder();
                }

                if (!snapshot.hasData) return const SizedBox();

                final allDocs = snapshot.data!.docs;
                List<QueryDocumentSnapshot> displayDocs;

                if (_searchQuery.isEmpty) {
                  displayDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['uid'] == currentUid;
                  }).toList();
                } else {
                  displayDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    String assetId = data['asset_id'].toString().toUpperCase();
                    return assetId.contains(_searchQuery);
                  }).toList();
                }

                if (displayDocs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("No records found.",
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: displayDocs.length,
                  itemBuilder: (context, index) {
                    var doc = displayDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    List<dynamic>? images = data['images_data'];

                    return Card(
                      elevation: 2,
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        iconColor: isDark ? Colors.white : Colors.black,
                        collapsedIconColor: isDark ? Colors.grey : Colors.black54,
                        leading: (images != null && images.isNotEmpty)
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(base64Decode(images[0]), width: 50, height: 50, fit: BoxFit.cover),
                        )
                            : Icon(Icons.directions_bus, color: isDark ? Colors.blue.shade400 : Colors.blue.shade800),
                        title: Text(data['asset_id'],
                            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(data['condition'],
                                style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 12, color: isDark ? Colors.grey : Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  data['user_email'] ?? 'System User',
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey : Colors.grey.shade700, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ],
                        ),
                        children: [
                          FutureBuilder<String>(
                            future: _getAiPrediction(data['asset_id'], allDocs),
                            builder: (context, aiSnapshot) {
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Icon(Icons.auto_awesome, size: 16, color: isDark ? Colors.blue.shade300 : Colors.blue),
                                      const SizedBox(width: 8),
                                      Text("AI Insight", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade300 : Colors.blue))
                                    ]),
                                    const SizedBox(height: 5),
                                    Text(aiSnapshot.data ?? "Analyzing history...",
                                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (images != null)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: images.length,
                                  itemBuilder: (context, i) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(base64Decode(images[i]), width: 100, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isReportMode ? StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('surveys').snapshots(),
        builder: (context, snapshot) {
          return FloatingActionButton.extended(
            backgroundColor: primaryColor,
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text("Generate Report", style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (snapshot.hasData) {
                final allDocs = snapshot.data!.docs;
                List<QueryDocumentSnapshot> docsToPrint;
                if (_searchQuery.isEmpty) {
                  docsToPrint = allDocs.where((doc) => doc['uid'] == currentUid).toList();
                } else {
                  docsToPrint = allDocs.where((doc) => doc['asset_id'].toString().toUpperCase().contains(_searchQuery)).toList();
                }
                _generatePdf(docsToPrint);
              }
            },
          );
        },
      ) : null,
    );
  }
}