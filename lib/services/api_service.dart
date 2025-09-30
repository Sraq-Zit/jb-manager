import 'dart:async';
import 'dart:convert';
import 'package:jbmanager/main.dart';
import 'package:jbmanager/providers/auth_provider.dart';
import 'package:jbmanager/services/user_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../exceptions/http_exception.dart';
import 'package:http/http.dart' as http;

const apiService = ApiService();

class ApiService {
  final String baseUrl;

  const ApiService({this.baseUrl = 'https://app.jbmanager.com/api/mobile'});

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? params,
    bool auth = false,
  }) async {
    if (auth) {
      final token = (await UserStorage().getUser())?.token;
      params ??= {};
      params['token'] = token;
    }
    String queryString = Uri(queryParameters: params).query;
    queryString = queryString.isNotEmpty ? '?$queryString' : '';
    final url = Uri.parse('$baseUrl$endpoint$queryString');
    final response = await http.get(url);

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    body ??= {};

    if (auth) {
      body['token'] = (await UserStorage().getUser())?.token;
    }

    final response = await http.post(url, body: body);

    return _processResponse(response);
  }

  FutureOr<Map<String, dynamic>> _processResponse(
    http.Response response,
  ) async {
    Map<String, dynamic> responseData = {};
    try {
      responseData = jsonDecode(
        response.body.trimLeft().replaceFirst(RegExp(r'^[^{\[]+'), ''),
      );
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData['token'] != null) {
        UserStorage().updateToken(responseData['token']);
      }
      return responseData;
    } else {
      if (responseData['error_code'] == -1) {
        responseData['error'] =
            'Votre session a expiré, merci de vous reconnecter.';

        final provider = Provider.of<AuthProvider>(
          navigatorKey.currentContext!,
          listen: false,
        );

        if (provider.isLoggedIn) {
          await provider.logout();
          // Show toast
          Fluttertoast.showToast(
            msg: responseData['error'],
            // toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            fontSize: 16.0,
          );
        }
      }
      throw HttpException(
        responseData['error'] ?? 'Une erreur est survenue, merci de réessayer.',
        response.statusCode,
      );
    }
  }
}
