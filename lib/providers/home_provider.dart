import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  // Example data for the home screen
  String _title = "Home Data";
  int _counter = 0;

  String get title => _title;
  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  // Add more data and methods as needed
}

