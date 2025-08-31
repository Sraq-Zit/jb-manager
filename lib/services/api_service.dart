import 'dart:async';
import 'dart:convert';
import '../exceptions/http_exception.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'https://app.jbmanager.com/api/mobile'});

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url);

    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(url, body: body);

    return _processResponse(response);
  }

  FutureOr<Map> _processResponse(http.Response response) {
    var responseData = {};
    try {
      responseData = jsonDecode(
        response.body.trimLeft().replaceFirst(RegExp(r'^[^{\[]+'), ''),
      );
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw HttpException(
        responseData['error'] ?? 'Unknown error',
        response.statusCode,
      );
    }
  }
}
