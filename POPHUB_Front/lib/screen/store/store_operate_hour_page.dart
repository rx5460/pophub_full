import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/notifier/StoreNotifier.dart';

class StoreOperatingHoursModal extends StatefulWidget {
  final StoreModel storeModel;

  const StoreOperatingHoursModal({super.key, required this.storeModel});

  @override
  _StoreOperatingHoursModalState createState() =>
      _StoreOperatingHoursModalState();
}

class _StoreOperatingHoursModalState extends State<StoreOperatingHoursModal> {
  final List<String> daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];
  final Map<String, bool> selectedDays = {
    '월': false,
    '화': false,
    '수': false,
    '목': false,
    '금': false,
    '토': false,
    '일': false,
  };
  final Map<String, String> operatingHours = {
    '월': '',
    '화': '',
    '수': '',
    '목': '',
    '금': '',
    '토': '',
    '일': '',
  };
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    final storeModel = widget.storeModel;
    if (storeModel.schedule != null) {
      for (var schedule in storeModel.schedule!) {
        String dayKor = _translateDay(schedule.dayOfWeek);
        if (daysOfWeek.contains(dayKor)) {
          selectedDays[dayKor] = true;
          operatingHours[dayKor] =
              '${schedule.openTime} : ${schedule.closeTime}';
        }
        setState(() {});
      }
    }
  }

  String _translateDay(String day) {
    switch (day) {
      case 'Monday':
      case 'Mon':
        return '월';
      case 'Tuesday':
      case 'Tue':
        return '화';
      case 'Wednesday':
      case 'Wed':
        return '수';
      case 'Thursday':
      case 'Thu':
        return '목';
      case 'Friday':
      case 'Fri':
        return '금';
      case 'Saturday':
      case 'Sat':
        return '토';
      case 'Sunday':
      case 'Sun':
        return '일';
      default:
        return '';
    }
  }

  String _reverseTranslateDay(String day) {
    switch (day) {
      case '월':
        return 'Monday';
      case '화':
        return 'Tuesday';
      case '수':
        return 'Wednesday';
      case '목':
        return 'Thursday';
      case '금':
        return 'Friday';
      case '토':
        return 'Saturday';
      case '일':
        return 'Sunday';
      default:
        return '';
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 350,
          color: Constants.LIGHT_GREY,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    isStartTime ? (startTime?.hour ?? 0) : (endTime?.hour ?? 0),
                    isStartTime
                        ? (startTime?.minute ?? 0)
                        : (endTime?.minute ?? 0),
                  ),
                  onDateTimeChanged: (DateTime date) {
                    setState(() {
                      if (isStartTime) {
                        startTime =
                            TimeOfDay(hour: date.hour, minute: date.minute);
                      } else {
                        endTime =
                            TimeOfDay(hour: date.hour, minute: date.minute);
                      }
                    });
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('완료'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateOperatingHours() {
    if (startTime != null && endTime != null) {
      final String start =
          '${startTime!.hour.toString().padLeft(2, '0')}시 ${startTime!.minute.toString().padLeft(2, '0')}분';
      final String end =
          '${endTime!.hour.toString().padLeft(2, '0')}시 ${endTime!.minute.toString().padLeft(2, '0')}분';
      if (mounted) {
        setState(() {
          selectedDays.forEach((day, selected) {
            if (selected) {
              operatingHours[day] = '$start : $end';
            }
          });
        });
      }
    }
  }

  void _complete() {
    _updateOperatingHours();
    final storeModel = widget.storeModel;
    storeModel.removeSchedule();
    operatingHours.forEach((day, hours) {
      if (hours.isNotEmpty) {
        List<String> times = hours.split(' : ');
        storeModel.updateSchedule(
          _reverseTranslateDay(day),
          times[0],
          times[1],
        );
      }
    });

    Navigator.pop(context);
  }

  void _selectWeekdays() {
    setState(() {
      bool allSelected =
          ['월', '화', '수', '목', '금'].every((day) => selectedDays[day]!);
      selectedDays.forEach((day, selected) {
        if (['월', '화', '수', '목', '금'].contains(day)) {
          selectedDays[day] = !allSelected;
        }
      });
    });
  }

  void _selectWeekend() {
    setState(() {
      bool allSelected = ['토', '일'].every((day) => selectedDays[day]!);
      selectedDays.forEach((day, selected) {
        if (['토', '일'].contains(day)) {
          selectedDays[day] = !allSelected;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '운영일',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: daysOfWeek.map((day) {
                  return Container(
                    width: screenWidth * 0.13,
                    height: screenHeight * 0.05,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            selectedDays[day]! ? Colors.white : Colors.black,
                        backgroundColor: selectedDays[day]!
                            ? Constants.DEFAULT_COLOR
                            : Colors.white,
                        side: const BorderSide(
                          color: Constants.DEFAULT_COLOR,
                          width: 1.0,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedDays[day] = !selectedDays[day]!;
                        });
                      },
                      child: Text(
                        day,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: screenWidth * 0.2,
                  height: screenHeight * 0.05,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Constants.DEFAULT_COLOR,
                        width: 1.0,
                      ),
                    ),
                    onPressed: _selectWeekdays,
                    child: const Text(
                      '평일',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth * 0.2,
                  height: screenHeight * 0.05,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Constants.DEFAULT_COLOR,
                        width: 1.0,
                      ),
                    ),
                    onPressed: _selectWeekend,
                    child: const Text(
                      '주말',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              '운영 시간',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(
              width: screenWidth,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectTime(context, true),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Constants.LIGHT_GREY),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12), // 패딩 설정
                      ),
                      child: Text(startTime == null
                          ? '시작 시간'
                          : '${startTime!.hour.toString().padLeft(2, '0')}시 ${startTime!.minute.toString().padLeft(2, '0')}분'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('~'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectTime(context, false),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Constants.LIGHT_GREY),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: Text(endTime == null
                          ? '종료 시간'
                          : '${endTime!.hour.toString().padLeft(2, '0')}시 ${endTime!.minute.toString().padLeft(2, '0')}분'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.35,
                  child: OutlinedButton(
                    onPressed: _complete,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text('완료'),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.01,
                ),
                SizedBox(
                  width: screenWidth * 0.35,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Constants.LIGHT_GREY),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      '닫기',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
