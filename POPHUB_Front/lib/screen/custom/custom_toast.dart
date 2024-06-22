import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static void customToastMsg(String message, BuildContext context,
      {ToastGravity gravity = ToastGravity.BOTTOM}) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity:
          isKeyboardOpen ? ToastGravity.CENTER : gravity, // 키보드 상태에 따라 위치 변경
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
