import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String apiUrl =
      'https://api.example.com/login'; // Replace with your actual API URL

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['token']; // Assuming the token is returned under 'token'
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
