import 'dart:convert';

import 'package:http/http.dart' as http;

class SmartboardFlaskApi {
  final String _FixedEndPoint = 'https://smartboard-flask-api-399810.ew.r.appspot.com/api/v1/';

  Future<Map> getSolution(String latextFormula) async {
    String url = _FixedEndPoint + latextFormula;

    print(url);

    final response = await http.get(Uri.parse(url));
    try {
      if (response.statusCode == 200) {
        print(response.body);

        return json.decode(response.body);
      }
    } catch (e) {
      print(e.toString());
      return {};
    }
    return {};
  }
}
