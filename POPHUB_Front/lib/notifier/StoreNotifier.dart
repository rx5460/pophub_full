import 'package:flutter/material.dart';
import 'package:pophub/model/schedule_model.dart';

class StoreModel with ChangeNotifier {
  String name = '';
  String description = '';
  String location = '';
  String locationDetail = '';
  String contact = '';
  String category = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  List<Map<String, dynamic>> images = [];
  int maxCapacity = 0;
  List<Schedule>? schedule = [];
  String id = '';

  void updateLocation(String newLocation) {
    location = newLocation;
    notifyListeners();
  }

  void updateStartDate(DateTime newStartDate) {
    startDate = newStartDate;
    notifyListeners();
  }

  void updateEndDate(DateTime newEndDate) {
    endDate = newEndDate;
    notifyListeners();
  }

  void addImage(Map<String, dynamic> image) {
    images.add(image);
    notifyListeners();
  }

  void removeImage(Map<String, dynamic> image) {
    images.remove(image);
    notifyListeners();
  }

  void addSchedule(Schedule newSchedule) {
    if (schedule != null) {
      schedule!.add(newSchedule);
    }
    notifyListeners();
  }

  void removeSchedule() {
    schedule = [];
    notifyListeners();
  }

  void updateSchedule(String dayOfWeek, String openTime, String closeTime) {
    if (schedule != null) {
      for (var s in schedule!) {
        if (s.dayOfWeek == dayOfWeek) {
          s = Schedule(
              dayOfWeek: dayOfWeek, openTime: openTime, closeTime: closeTime);
          notifyListeners();
          return;
        }
      }
      if (schedule != null) {
        schedule!.add(Schedule(
            dayOfWeek: dayOfWeek, openTime: openTime, closeTime: closeTime));
      }
      notifyListeners();
    }
  }

  void removeScheduleAt(int index) {
    schedule?.removeAt(index);
    notifyListeners();
  }
}
