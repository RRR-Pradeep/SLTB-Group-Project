import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIService {

  static const String _apiKey = 'AIzaSyC2SnPUtpiM9UzSvLQRVh9vLjYX8PhajbM';

  static Future<String> predictMaintenance(String assetId) async {
    try {

      final snapshot = await FirebaseFirestore.instance
          .collection('surveys')
          .where('asset_id', isEqualTo: assetId)
          .limit(5)
          .get();

      if (snapshot.docs.isEmpty) return "No data to analyze.";


      String history = snapshot.docs.map((doc) =>
      "Date: ${doc['date_time'].toDate()}, Status: ${doc['condition']}"
      ).join("\n");


      final model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
      final content = [Content.text(
          "You are an SLTB Bus Maintenance AI. Based on this history:\n$history\n"
              "Predict if the bus $assetId needs urgent repair or routine maintenance. "
              "Keep it short and professional in 2 sentences."
      )];

      final response = await model.generateContent(content);
      return response.text ?? "Could not generate prediction.";

    } catch (e) {
      return "AI analysis failed: $e";
    }
  }
}