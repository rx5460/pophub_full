import 'package:flutter/material.dart';

class UserNotifier with ChangeNotifier {
  int _count = 0;
  int get count => _count;
  bool isVerify = false;

  late final TextEditingController phoneController = TextEditingController();
  late final TextEditingController certifiController = TextEditingController();
  late final TextEditingController idController = TextEditingController();
  late final TextEditingController pwController = TextEditingController();
  late final TextEditingController confirmPwController =
      TextEditingController();

  set count(int value) {
    _count = value;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}

UserNotifier userNotifier = UserNotifier();
