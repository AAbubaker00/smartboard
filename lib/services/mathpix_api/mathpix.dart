import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartboard/services/smartboard_flask_api/smartboard_flask_api.dart';


class MathPix {
  final String token = '5e2feb19a86e8a8c3d9a6bc02634d0165759349527d2faa65b02a7e9db549dac';

  Future<Map> processStrokeData(List xStrokes, List yStrokes) async {
    final String apiUrl = 'https://api.mathpix.com/v3/strokes';
    final String appId = 'cokolabs_a0f94f_96a7de'; // Replace with your actual app ID
    final String appKey =
        '5e2feb19a86e8a8c3d9a6bc02634d0165759349527d2faa65b02a7e9db549dac'; // Replace with your actual app key

    Map<String, dynamic> requestData = {
      "strokes": {
        "strokes": {"x": xStrokes, "y": yStrokes}
      },
      'formats': ['text', 'latex_styled']
    };

    final headers = {
      'app_id': appId,
      'app_key': appKey,
      'Content-Type': 'application/json',
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      Map responsJson = json.decode(response.body);
      printWrapped(responsJson.toString());

      return SmartboardFlaskApi().getSolution(responsJson['latex_styled'].toString());
      // print('Response data: ${response.body}');
      // You can parse and work with the response data here
    } else {
      print('Error: ${response.statusCode}');
      print('Response data: ${response.body}');
    }

    return {};
  }
}
void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

// \\int_{3}^{2} 4 x d x

// \left[\begin{array}{lll}1&2&3\\