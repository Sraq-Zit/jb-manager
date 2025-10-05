import 'package:flutter/material.dart';

class ColorPalette {
  static const MaterialColor blue = Colors.blue;
  static const MaterialColor orange = Colors.orange;
  static const MaterialColor green = Colors.green;
  static const MaterialColor red = Colors.red;
  static const MaterialColor amber = Colors.amber;
  static const MaterialColor purple = Colors.purple;
  static const MaterialColor cyan = Colors.cyan;
  static const MaterialColor pink = Colors.pink;
  static const MaterialColor teal = Colors.teal;
  static const MaterialColor lime = Colors.lime;
  static const MaterialColor indigo = Colors.indigo;
  static const MaterialColor grey = Colors.grey;
  static const MaterialColor brown = Colors.brown;
  static const MaterialColor deepOrange = Colors.deepOrange;
  static const MaterialColor deepPurple = Colors.deepPurple;
  static const MaterialColor lightBlue = Colors.lightBlue;
  static const MaterialColor lightGreen = Colors.lightGreen;
  static const MaterialColor yellow = Colors.yellow;
  static const MaterialColor blueGrey = Colors.blueGrey;

  static const List<MaterialColor> chartColors = [
    blue,
    green,
    orange,
    purple,
    red,
    cyan,
    pink,
    amber,
    teal,
    lime,
    indigo,
    grey,
    brown,
    deepOrange,
    deepPurple,
    lightBlue,
    lightGreen,
    yellow,
    blueGrey,
  ];

  static Color generateColorFromInteger(int hash) {
    final hue = (hash % 360).toDouble();
    // hls to rgb conversion
    return HSLColor.fromAHSL(1.0, hue, 0.5, 0.5).toColor();
  }
}
