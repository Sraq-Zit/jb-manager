import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jbmanager/models/document.dart';
import 'package:jbmanager/pages/dashboard.dart';
import 'package:jbmanager/pages/documents.dart';
import 'package:jbmanager/pages/settings_page.dart';

enum MenuOption {
  dashboard,
  sales,
  purchases,
  activities,
  settings,
  help,
  logout,
}

const List<MenuOption> menusWithSearchIcon = [
  MenuOption.sales,
  MenuOption.purchases,
];

class UiProvider extends ChangeNotifier {
  MenuOption _currentMenuOption = MenuOption.dashboard;

  final Map<String, Uint8List> _cachedImages = {};

  final _searchNotifier = ValueNotifier<String>('');
  Timer? _searchDebounce;
  AnimationController? _slideController;
  Animation<Offset>? _slideAnimation;
  bool _isDrawerOpen = false;
  Animation<Offset>? get slideAnimation => _slideAnimation;
  MenuOption get currentMenuOption => _currentMenuOption;
  bool get isDrawerOpen => _isDrawerOpen;
  String get searchQuery => _searchNotifier.value;
  ValueNotifier<String> get searchNotifier => _searchNotifier;

  Animation<Offset> initializeAnimation(TickerProvider vsync) {
    if (_slideController == null && _slideAnimation == null) {
      _slideController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: vsync,
      );
      _slideAnimation =
          Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: _slideController!, curve: Curves.easeOut),
          );
    }

    return _slideAnimation!;
  }

  void search(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _searchNotifier.value = query;
    });
  }

  Widget? buildBody() {
    switch (_currentMenuOption) {
      case MenuOption.dashboard:
        return const DashboardPage();
      case MenuOption.sales:
        return const DocumentsPage(
          key: Key('sales_page'),
          category: DocumentCategory.sales,
        );
      case MenuOption.purchases:
        return const DocumentsPage(
          key: Key('purchases_page'),
          category: DocumentCategory.purchases,
        );
      case MenuOption.activities:
        return const DocumentsPage(
          key: Key('activities_page'),
          title: 'activité',
          feminine: true,
          category: DocumentCategory.activities,
        );
      case MenuOption.settings:
        return SettingsPage();
      case MenuOption.help:
        return const Text('Help Page');
      case MenuOption.logout:
        return const Text('Logout Page');
    }
  }

  void toggleDrawer() {
    if (_slideController == null) return;
    if (_slideController!.isCompleted) {
      _slideController!.reverse();
      _isDrawerOpen = false;
    } else {
      _slideController!.forward();
      _isDrawerOpen = true;
    }
    notifyListeners();
  }

  void openDrawer() {
    if (_slideController == null) return;
    _slideController!.forward();
    _isDrawerOpen = true;
    notifyListeners();
  }

  void closeDrawer() {
    if (_slideController == null) return;
    _slideController!.reverse();
    _isDrawerOpen = false;
    notifyListeners();
  }

  void selectMenuOption(MenuOption o) {
    _currentMenuOption = o;
    notifyListeners();
  }

  void cacheImage(String key, Uint8List imageData) {
    _cachedImages[key] = imageData;
  }

  Uint8List? getCachedImage(String key) {
    return _cachedImages[key];
  }
}
