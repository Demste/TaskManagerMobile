import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: Colors.black),
    headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
    headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black),
    bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.black54),
    // Define other text styles as needed
  ),
  colorScheme: const ColorScheme.light(
    surface: Colors.black,
  ),
  brightness: Brightness.light,
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    color: Colors.white, // Background color of the AppBar
    elevation: 0, // Shadow depth of the AppBar
    titleTextStyle: TextStyle(
      color: Colors.black, // Color of the title text
      fontSize: 20, // Size of the title text
      fontWeight: FontWeight.bold, // Weight of the title text
    ),
    iconTheme: IconThemeData(
      color: Colors.black, // Color of the AppBar icons
    ),
  ),
  scaffoldBackgroundColor: Colors.white,
);
ThemeData darkTheme =ThemeData(
    textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,  color: Colors.white),
    headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
    headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.white),
    bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.white70),
    // Define other text styles as needed
  ),
  colorScheme: const ColorScheme.dark(
    surface: Colors.grey,
  ),
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    color: Colors.black, // Background color of the AppBar
    elevation: 0, // Shadow depth of the AppBar
    titleTextStyle: TextStyle(
      color: Colors.white, // Color of the title text
      fontSize: 20, // Size of the title text
      fontWeight: FontWeight.bold, // Weight of the title text
    ),
    iconTheme: IconThemeData(
      color: Colors.white, // Color of the AppBar icons
    ),
  ),
  scaffoldBackgroundColor: Colors.black,
  iconTheme: const IconThemeData(color: Colors.white),
  
);