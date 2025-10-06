import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:jbmanager/main.dart';
import 'package:jbmanager/models/document.dart';
import 'package:jbmanager/providers/auth_provider.dart';
import 'package:jbmanager/services/user_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../exceptions/http_exception.dart';
import 'package:http/http.dart' as http;

const defaultBaseUrl = 'https://app.jbmanager.com/api/mobile';
const apiService = ApiService();

class ApiService {
  final String baseUrl;

  const ApiService({this.baseUrl = defaultBaseUrl});

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? params,
    bool auth = false,
    bool absoluteUrl = false,
  }) async {
    final baseUrl =
        (await SharedPreferences.getInstance()).getString('api_base_url') ??
        this.baseUrl;
    if (auth) {
      final token = (await UserStorage().getUser())?.token;
      params ??= {};
      params['token'] = token;
    }
    String queryString = Uri(queryParameters: params).query;
    queryString = queryString.isNotEmpty ? '?$queryString' : '';
    endpoint = absoluteUrl ? endpoint : '$baseUrl$endpoint';
    final url = Uri.parse('$endpoint$queryString');
    final response = await http.get(url);

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool auth = false,
    bool absoluteUrl = false,
  }) async {
    final baseUrl =
        (await SharedPreferences.getInstance()).getString('api_base_url') ??
        this.baseUrl;
    endpoint = absoluteUrl ? endpoint : '$baseUrl$endpoint';
    final url = Uri.parse(endpoint);

    body ??= {};

    if (auth) {
      body['token'] = (await UserStorage().getUser())?.token;
    }
    late http.Response response;
    try {
      response = await http.post(url, body: body);
    } on http.ClientException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw HttpException('Erreur de connexion au serveur');
    }

    return _processResponse(response);
  }

  Future<File> getPrintPdf(String id, Action action) async {
    final url = Uri.parse(action.urlFormatted(id));

    final body = {
      'action': action.action,
      'token': (await UserStorage().getUser())?.token,
    };
    // save result pdf file to tmp file
    final response = await http.post(url, body: body);
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/document.pdf').create();
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw HttpException('Erreur lors de la génération du PDF');
    }
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
