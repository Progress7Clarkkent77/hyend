import 'package:flutter/material.dart';

const Color coinColor = Color.fromARGB(255, 22, 137, 155);

Color getMainColor(BuildContext context) {
  // Detect platform brightness
  bool isDarkMode =
      MediaQuery.of(context).platformBrightness == Brightness.dark;
  // Return the appropriate color based on the brightness
  return isDarkMode ? Colors.black : Colors.black;
}
