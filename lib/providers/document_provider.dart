import 'dart:math';

import 'package:flutter/material.dart' hide Action;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jbmanager/constants/document_states.dart';
import 'package:jbmanager/constants/document_types.dart';
import 'package:jbmanager/exceptions/http_exception.dart';
import 'package:jbmanager/models/document.dart';
import 'package:jbmanager/providers/auth_provider.dart';
import 'package:jbmanager/providers/ui_provider.dart';
import 'package:jbmanager/screens/detail.dart';
import 'package:jbmanager/services/api_service.dart';
import 'package:jbmanager/theme/color_palette.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

const pageLength = 20;

class DocumentProvider with ChangeNotifier {
  final scrollController = ScrollController();
  final UiProvider uiProvider;
  final Map<int, bool> _isFetchingMap = {};
  final Map<int, List<DocumentItem>?> _documents = {};
  final Map<int, int> _pagination = {};
  late List<int> _filters;
  DocumentDetails? _documentDetail;
  String? _error;
  bool _disposed = false;
  bool _isFetchingScroll = false;

  bool get isFetching => _isFetchingMap[tabController.index] ?? false;
  bool get isFetchingScroll => _isFetchingScroll;
  DocumentDetails? get documentDetail => _documentDetail;
  List<DocumentItem>? get documents => _documents[tabController.index];
  int get filter => _filters[tabController.index];
  String? get error => _error;
  bool get isLoading => documents == null && _error == null;
  DocumentType get documentType => DocumentType.get(
    category,
    documentTypes.keys
        .where((key) => key.$1 == category)
        .map((key) => key.$2)
        .toList()[tabController.index],
  );

  final DocumentCategory category;
  final TabController tabController;

  DocumentProvider(this.uiProvider, this.tabController, this.category) {
    _filters = List.generate(tabController.length, (_) => -1);
    tabController.addListener(() {
      if (tabController.indexIsChanging) getDocuments();
    });
  }

  void setFilter(int status) {
    _filters[tabController.index] = status;
    getDocuments(force: true, reset: true);
  }

  void clearDocuments() {
    _documents.clear();
    _pagination.clear();
  }

  static Future<String?> doAction(
    BuildContext context,
    Action action,
    String documentId,
    Function(bool) loadingCallback,
  ) async {
    if (action.download) {
      loadingCallback(true);

      try {
        final file = await apiService.getPrintPdf(documentId, action);
        OpenFilex.open(file.path);
      } on HttpException catch (e) {
        Fluttertoast.showToast(msg: e.message);
        return null;
      }
    }
    // prompt confirmation
    if (action.alert && context.mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirmer l\'action'),
          content: Text('Êtes-vous sûr de vouloir effectuer cette action ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Confirmer'),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        return null;
      }
    }

    loadingCallback(true);
    try {
      final result = await apiService.post(
        '/document/$documentId',
        body: {'action': action.action},
        auth: true,
      );
      return result['data']?['id_document'];
    } on HttpException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    }
    return null;
  }

  static String getTvaRate(BuildContext context, String idTva) {
    final tva = Provider.of<AuthProvider>(
      context,
    ).user!.settings.listTva[idTva]?.taux;
    return tva ?? '';
  }

  static String getUnit(BuildContext context, String idUnit) {
    final provider = Provider.of<AuthProvider>(context);
    final unit = provider.user!.settings.unities[idUnit]?.code;
    return unit ?? '';
  }

  static Future<DocumentDetails> getDocumentDetail(String id) async {
    final response = await apiService.post('/document/$id', auth: true);

    if (response['status'] == true && response['data'] != null) {
      return DocumentDetails.fromJson(response['data']);
    } else {
      throw HttpException(
        response['error'] ?? 'Une erreur est survenue, merci de réessayer.',
      );
    }
  }

  static void navigateToDocumentDetail(
    BuildContext context,
    Function onDocumentUpdated,
    DocumentItem doc,
    MaterialColor color,
  ) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DetailScreen(
          documentItem: doc,
          onDocumentUpdated: onDocumentUpdated,
          color: color,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void addScrollListener(Function(DocumentProvider) onScrollEnd) {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        onScrollEnd(this);
      }
    });
  }

  Future<void> getDocuments({
    int? user,
    bool force = false,
    bool reset = false,
    bool scroll = false,
  }) async {
    if (_disposed) return;
    final index = tabController.index;
    if (!force && !scroll && !reset && _documents.containsKey(index)) {
      return notifyListeners();
    }
    if (scroll && (_isFetchingMap[index] ?? false)) return;
    if (scroll && _pagination[index] != null && _pagination[index] == -1) {
      return;
    }
    final docType = documentType.id;
    try {
      _isFetchingMap[index] = true;
      if (scroll) {
        _isFetchingScroll = true;
      }
      if (reset) {
        _documents[index] = null;
      }
      _error = null;
      // _documents[index] = null;
      notifyListeners();

      var start = _pagination[index] ?? 0;

      if (force) {
        start = 0;
      }

      var params = {
        'id_type': docType.toString(),
        // 'id_status': status,
        // 'id_user': '743',
        // 'datestart': '01-01-2024',
        // 'dateend': '01-05-2025',
        // 'order': 'contact',
        // 'filter': '',
        // 'desc': '1',
        'start': start.toString(),
        'length': pageLength.toString(),
      };
      final status = filter;
      if (documentStates.keys.contains(status)) {
        params['id_status'] = status.toString();
      } else if (status == -2) {
        final start = DateTime.now().subtract(const Duration(days: 30));
        final end = DateTime.now();
        params['datestart'] = DateFormat('dd-MM-yyyy').format(start);
        params['dateend'] = DateFormat('dd-MM-yyyy').format(end);
      } else if (status != -1) {
        throw HttpException('Statut de document invalide.');
      }
      final query = uiProvider.searchNotifier.value;
      if (query.isNotEmpty) {
        params['filter'] = query;
      }

      params = params.map((key, value) => MapEntry(key, value));

      final response = await apiService.post(
        '/documents',
        auth: true,
        body: params,
      );

      if (response['status'] == true && response['data'] != null) {
        final resultDocs = (response['data'] as List)
            .map((doc) => DocumentItem.fromJson(doc))
            .toList();

        if (scroll && _documents[index] != null) {
          _documents[index]?.addAll(resultDocs);
        } else {
          _documents[index] = resultDocs;
        }

        List<Color> colors = [];
        Map<int, Color> colorMap = {};

        _documents[index]?.forEach((doc) {
          if (colors.isEmpty) {
            colors = List<Color>.from(ColorPalette.chartColors);
          }
          final id = doc.societe.hashCode;
          colorMap.putIfAbsent(
            id,
            () => colors.removeAt(min(index, colors.length - 1)),
          );
          doc.color = colorMap[id]!;
        });

        _pagination[index] = start + resultDocs.length;
        if (resultDocs.isEmpty) {
          _pagination[index] = -1;
        }
      } else {
        _error =
            response['error'] ?? 'Une erreur est survenue, merci de réessayer.';
      }
    } on HttpException catch (e) {
      _error = e.message;
    } finally {
      _isFetchingMap[index] = false;
      _isFetchingScroll = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
