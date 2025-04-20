import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.black,
    selectionHandleColor: Colors.amber,
  ),
  fontFamily: GoogleFonts.nunito().fontFamily,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.black,
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 15,
    ),
  ),
  useMaterial3: true,
  bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(hoverColor: Colors.grey[200]),
  scaffoldBackgroundColor: Colors.white,
  dialogBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
);

ThemeData darkMode = ThemeData(
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionHandleColor: Colors.amber,
    ),
    fontFamily: GoogleFonts.nunito().fontFamily,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Colors.black,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
    ),
    useMaterial3: true,
    floatingActionButtonTheme:
        FloatingActionButtonThemeData(hoverColor: Colors.grey[200]),
    scaffoldBackgroundColor: Colors.black,
    dialogBackgroundColor: Colors.black,
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ));
