import 'package:flutter/material.dart';
import 'package:pophub/assets/constants.dart';

var theme = ThemeData(
  appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'NanumGothicCoding',
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Colors.black,
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white),
          backgroundColor: const Color(0xffadd8e6),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.white),
          padding: const EdgeInsets.all(0),
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.black)),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Constants.BUTTON_GREY,
          width: 1.0,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Constants.DEFAULT_COLOR, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(10))),
    labelStyle: TextStyle(color: Constants.DARK_GREY),
    hintStyle: TextStyle(color: Constants.DARK_GREY),
  ),
);
