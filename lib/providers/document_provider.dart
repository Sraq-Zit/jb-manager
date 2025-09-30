import 'package:flutter/material.dart';
import 'package:jbmanager/exceptions/http_exception.dart';
import 'package:jbmanager/models/document.dart';
import 'package:jbmanager/services/api_service.dart';

class DocumentProvider with ChangeNotifier {
  Map<int, List<Document>?> _documents = {};
  String? _error;

  List<Document>? get documents => _documents[tabController.index];
  String? get error => _error;
  bool get isLoading => documents == null && _error == null;

  final DocumentCategory category;
  final TabController tabController;

  DocumentProvider(this.tabController, this.category) {
    tabController.addListener(() {
      if (tabController.indexIsChanging) getDocuments();
    });
  }

  Future<void> getDocuments({
    int? status,
    int? user,
    bool force = false,
  }) async {
    if (!force && _documents.containsKey(tabController.index)) {
      return notifyListeners();
    }
    final docType = DocumentType.get(
      category,
      DocumentOption.values[tabController.index],
    ).id;
    try {
      _error = null;
      // _documents[tabController.index] = null;
      notifyListeners();

      final params = {
        'id_type': docType.toString(),
        // 'id_status': status,
        // 'id_user': '743',
        // 'datestart': '01-01-2024',
        // 'dateend': '01-05-2025',
        // 'order': 'contact',
        // 'filter': '',
        // 'desc': '1',
        'start': '0',
        'length': '5',
      }.map((key, value) => MapEntry(key, value ?? ''));

      final response = await apiService.post(
        '/documents',
        auth: true,
        body: params,
      );

      if (response['status'] == true && response['data'] != null) {
        _documents[tabController.index] = (response['data'] as List)
            .map((doc) => Document.fromJson(doc))
            .toList();
      } else {
        _error =
            response['error'] ?? 'Une erreur est survenue, merci de réessayer.';
      }
    } on HttpException catch (e) {
      _error = e.message;
    } finally {
      notifyListeners();
    }
  }
}
