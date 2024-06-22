import 'package:flutter/material.dart';

class GoodsNotifier with ChangeNotifier {
  String userName = '';
  String productName = '';
  String description = '';
  int quantity = 0;
  List<Map<String, dynamic>> images = [];
  int price = 0;
  void addImage(Map<String, dynamic> image) {
    images.add(image);
    notifyListeners();
  }

  void removeImage(Map<String, dynamic> image) {
    images.remove(image);
    notifyListeners();
  }
}
