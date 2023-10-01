import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatGpt {

  void test() async {
    final String apiUrl = 'https://api.openai.com/v1/chat/completions';
    final String openaiApiKey = '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'; // Replace with your actual OpenAI API key

    Map<String, dynamic> requestData = {
      "model": "gpt-4",
      "messages": [
        {"role": "user", "content": 'can you solve: "latex_styled":"\\int_{3}^{2} 4 x d x"'}
      ],
      "temperature": 0.7
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openaiApiKey',
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      print('Response data: ${response.body}');
      // You can parse and work with the response data here
    } else {
      print('Error: ${response.statusCode}');
      print('Response data: ${response.body}');
    }
  }
}
