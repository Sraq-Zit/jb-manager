import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jbmanager/models/document.dart';
import 'package:jbmanager/pages/dashboard.dart';
import 'package:jbmanager/pages/documents.dart';

enum MenuOption {
  dashboard,
  sales,
  purchases,
  statistics,
  settings,
  help,
  logout,
}

class UiProvider extends ChangeNotifier {
  MenuOption _currentMenuOption = MenuOption.dashboard;

  final Map<String, Uint8List> _cachedImages = {};

  AnimationController? _slideController;
  Animation<Offset>? _slideAnimation;
  bool _isDrawerOpen = false;
  Animation<Offset>? get slideAnimation => _slideAnimation;
  MenuOption get currentMenuOption => _currentMenuOption;
  bool get isDrawerOpen => _isDrawerOpen;

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

  Widget? buildBody() {
    switch (_currentMenuOption) {
      case MenuOption.dashboard:
        return const DashboardPage();
      case MenuOption.sales:
        return const Text('Clients Page');
      case MenuOption.purchases:
        return const DocumentsPage(category: DocumentCategory.purchases);
      case MenuOption.statistics:
        return const Text('Statistics Page');
      case MenuOption.settings:
        return const Text('Settings Page');
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
