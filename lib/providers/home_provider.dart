import 'package:flutter/material.dart';
import 'package:jbmanager/exceptions/http_exception.dart';
import 'package:jbmanager/models/home_data.dart';
import 'package:jbmanager/services/api_service.dart';

class HomeProvider with ChangeNotifier {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  bool _isDisposed = false;
  String? _error;
  HomeData? _homeData;
  bool isInit = false;

  String? get error => _error;
  HomeData? get homeData => _homeData;
  GlobalKey<RefreshIndicatorState> get refreshKey => _refreshKey;

  HomeProvider();

  Future<void> fetchHomeData() async {
    try {
      _error = null;
      notifyListeners();

      final response = await apiService.post('/home', auth: true);

      if (response['status'] == true && response['result'] != null) {
        _homeData = HomeData.fromJson(response['result']['data']);
      } else {
        _error =
            response['error'] ?? 'Une erreur est survenue, merci de réessayer.';
      }
    } on HttpException catch (e) {
      _error = e.message;
    } finally {
      if (!_isDisposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
