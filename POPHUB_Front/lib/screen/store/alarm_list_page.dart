import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/reservation_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/store/popup_detail.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';
import 'package:pophub/utils/utils.dart';

class AlarmListPage extends StatefulWidget {
  final String mode;
  final String titleName;
  const AlarmListPage({super.key, required this.mode, required this.titleName});

  @override
  _AlarmListPageState createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> {
  List<ReservationModel> reserveList = [];
  List<String> imageList = [];
  List<String> storeName = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (widget.mode == "name") {
        await getReserveList();
      } else {
        await getReservePresidentList();
      }
    } catch (e) {
      Logger.debug('Error initializing data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getReserveList() async {
    try {
      final data = await Api.getReservationByUserName();
      if (!data.toString().contains("fail")) {
        setState(() {
          reserveList = data;
        });
        await getPopupData(reserveList);
      } else {
        Logger.debug('Error fetching reservation data');
      }
    } catch (e) {
      Logger.debug('Error in getReserveList: $e');
    }
  }

  Future<void> getReservePresidentList() async {
    try {
      List<dynamic> data = await Api.getMyPopup(User().userName);
      if (!data.toString().contains("fail") &&
          !data.toString().contains("없습니다")) {
        PopupModel popup = PopupModel.fromJson(data[0]);
        final listData = await Api.getReservationByStoreId(popup.id.toString());
        setState(() {
          reserveList = listData;
        });
        await getPopupData(reserveList);
      } else {
        Logger.debug('Error fetching getReservePresidentList data');
      }
    } catch (e) {
      Logger.debug('Error in getReservePresidentList: $e');
    }
  }

  Future<void> alarmDelete(reserveId) async {
    try {
      final data = await Api.reserveDelete(reserveId);
      if (!data.toString().contains("fail") && mounted) {
        showAlert(context, "성공", "알림이 삭제되었습니다.", () {
          Navigator.of(context).pop();
          setState(() {
            reserveList
                .removeWhere((element) => element.reservationId == reserveId);
          });
        });
      }
    } catch (e) {
      Logger.debug('Error in alarmDelete: $e');
    }
  }

  Future<void> getPopupData(List<ReservationModel> list) async {
    imageList = [];
    storeName = [];
    for (ReservationModel reserve in list) {
      try {
        PopupModel? popup = await Api.getPopup(
            reserve.store.toString(), false, reserve.userName.toString());
        setState(() {
          imageList.add(popup.image != null && popup.image!.isNotEmpty
              ? popup.image![0]
              : 'assets/images/logo.png');
          storeName.add(popup.name ?? 'No name');
        });
      } catch (error) {
        Logger.debug('Error fetching popup data: $error');
        setState(() {
          imageList.add('assets/images/logo.png');
          storeName.add('No name');
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTitleBar(titleName: widget.titleName),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : reserveList.isEmpty
                ? const Center(
                    child: Text(
                      '예약 리스트가 없습니다!',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )
                : ListView.builder(
                    itemCount: reserveList.length,
                    itemBuilder: (context, index) {
                      final reserve = reserveList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PopupDetail(
                                storeId: reserve.store!,
                                mode: "view",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: imageList.length > index
                                    ? Image.network(
                                        imageList[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/logo.png',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      storeName.length > index
                                          ? storeName[index]
                                          : 'No name',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          (reserve.date != null &&
                                                  reserve.date!.isNotEmpty)
                                              ? DateFormat("yyyy.MM.dd").format(
                                                  DateTime.parse(reserve.date!))
                                              : '',
                                        ),
                                        const SizedBox(width: 5.0), // 간격 추가
                                        Text((reserve.time != null &&
                                                reserve.time!.isNotEmpty)
                                            ? DateFormat("HH:mm").format(
                                                DateFormat("HH:mm:ss")
                                                    .parse(reserve.time!))
                                            : ''),
                                      ],
                                    ),
                                    Visibility(
                                      visible: widget.mode == "store",
                                      child: Row(
                                        children: [
                                          Text(
                                              "아이디: ${reserve.userName != null ? reserve.userName.toString() : ""}"),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                            "인원: ${(reserve.capacity != null) ? reserve.capacity.toString() : ''}명"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('삭제'),
                                        content: const Text('알림 삭제를 하시겠습니까?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('취소'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              alarmDelete(
                                                  reserve.reservationId);
                                            },
                                            child: const Text('삭제'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 25,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
