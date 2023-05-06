import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme(brightness) {
  var baseTheme = ThemeData(brightness: brightness);

  return baseTheme.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
    primaryColor: Colors.black,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.white),
      ),
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 13,
      ),
    ),
  );
}
