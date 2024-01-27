import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

/// A wrapper around the http package, to make requests simpler
class HttpService {
  final Map<String, String> headers;
  final String baseUrl;

  HttpService({required this.headers, required this.baseUrl});

  Future get(String urlPath) async {
    Uri url = Uri.parse('$baseUrl$urlPath');

    log('here 1');
    http.Response response = await http.get(url, headers: headers);
    log('here 2');

    log(response.toString());

    if (response.statusCode == 200) {
      log('here 3');

      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
