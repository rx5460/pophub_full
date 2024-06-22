import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/reservation_model.dart';
import 'package:pophub/screen/reservation/reserve_count.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';

class ReserveDate extends StatefulWidget {
  final PopupModel popup;
  const ReserveDate({super.key, required this.popup});

  @override
  State<ReserveDate> createState() => _ReserveDateState();
}

class _ReserveDateState extends State<ReserveDate> {
  DateTime selectedDate = DateTime.now();
  int selectedHour = 1; // Default starting hour
  List<int> availableHours = [];
  List<ReservationModel>? reserve;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _updateAvailableHours();
      });
    }
  }

  Future<void> getReserveStatus() async {
    try {
      List<ReservationModel>? data =
          await Api.getReserveStatus(widget.popup.id!);
      setState(() {
        reserve = data;
      });
    } catch (error) {
      // 오류 처리
      Logger.debug('Error fetching reservationStatus data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getReserveStatus();
    _updateAvailableHours();
  }

  void _updateAvailableHours() {
    String dayOfWeek = DateFormat('EEE').format(selectedDate);

    int? openHour;
    int? closeHour;
    for (int i = 0; i < widget.popup.schedule!.length; i++) {
      print(widget.popup.schedule!.length);
      if (widget.popup.schedule![i].dayOfWeek == dayOfWeek) {
        openHour = int.parse(widget.popup.schedule![i].openTime.split(':')[0]);
        closeHour =
            int.parse(widget.popup.schedule![i].closeTime.split(':')[0]);
      }
    }

    setState(() {
      availableHours = [];
      if (openHour != null && closeHour != null) {
        for (int i = openHour; i <= closeHour; i++) {
          availableHours.add(i);
        }
        selectedHour = availableHours.isNotEmpty ? availableHours.first : 1;
      }
      print(availableHours);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('예약하기'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                top: screenHeight * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '예약 날짜 및 시간을',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  '설정해 주세요.',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                GestureDetector(
                  onTap: () async {
                    _selectDate(context);
                  },
                  child: Container(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.05,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat("yyyy.MM.dd").format(selectedDate)),
                          const Icon(
                            Icons.keyboard_arrow_down_outlined,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: availableHours.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    int hour = availableHours[index];
                    bool abled = true;
                    if (reserve != null && reserve!.isNotEmpty) {
                      for (int i = 0; i < reserve!.length; i++) {
                        if (reserve![i].time != null &&
                                DateFormat('HH:mm')
                                        .format(DateFormat('HH:mm:ss')
                                            .parse(reserve![i].time.toString()))
                                        .toString() ==
                                    "${hour.toString().padLeft(2, '0')}:00" ||
                            reserve![i].status == true) {
                          abled = false;
                          break;
                        }
                      }
                    }
                    return GestureDetector(
                      onTap: () {
                        if (abled) {
                          setState(() {
                            selectedHour = hour;
                            print(selectedHour);
                            print(selectedDate);
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: abled
                              ? selectedHour == hour
                                  ? const Color(0xFFADD8E6)
                                  : Colors.white
                              : Colors.grey,
                          border: Border.all(
                            width: 1,
                            color: selectedHour == hour
                                ? Colors.white
                                : Colors.grey,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${hour.toString().padLeft(2, '0')}:00",
                            style: TextStyle(
                              color: abled
                                  ? selectedHour == hour
                                      ? Colors.white
                                      : Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          SizedBox(
            width: screenWidth * 0.8,
            height: screenHeight * 0.08,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReserveCount(
                            date: DateFormat("yyyy-MM-dd").format(selectedDate),
                            popup: widget.popup.id!,
                            time:
                                "${selectedHour.toString().padLeft(2, '0')}:00",
                          )),
                );
              },
              child: const Text('다음'),
            ),
          ),
        ],
      ),
    );
  }
}
