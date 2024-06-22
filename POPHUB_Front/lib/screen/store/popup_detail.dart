import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/goods_model.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/review_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/StoreNotifier.dart';
import 'package:pophub/screen/alarm/alarm_page.dart';
import 'package:pophub/screen/goods/goods_detail.dart';
import 'package:pophub/screen/goods/goods_list.dart';
import 'package:pophub/screen/reservation/reserve_date.dart';
import 'package:pophub/screen/store/pending_reject_page.dart';
import 'package:pophub/screen/store/popup_review.dart';
import 'package:pophub/screen/store/store_add_page.dart';
import 'package:pophub/screen/store/store_list_page.dart';
import 'package:pophub/screen/user/login.dart';
import 'package:pophub/screen/user/profile_page.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';
import 'package:pophub/utils/utils.dart';
import 'package:provider/provider.dart';

class PopupDetail extends StatefulWidget {
  final String storeId;
  final String mode;
  const PopupDetail({Key? key, required this.storeId, this.mode = "view"})
      : super(key: key);

  @override
  State<PopupDetail> createState() => _PopupDetailState();
}

class _PopupDetailState extends State<PopupDetail> {
  late KakaoMapController mapController;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  PopupModel? popup;
  List<ReviewModel>? reviewList;
  List<GoodsModel>? goodsList;
  bool isLoading = true;
  double rating = 0;
  bool like = false;
  bool allowSuccess = false;
  LatLng center = LatLng(37.5248570991105, 126.92683967042);
  Set<Marker> markers = {};
  bool timeVisible = false;

  Future<void> getPopupData() async {
    try {
      PopupModel? data =
          await Api.getPopup(widget.storeId, true, User().userName);

      setState(() {
        popup = data;

        double? xCoord = double.tryParse(popup!.y.toString());
        double? yCoord = double.tryParse(popup!.x.toString());

        if (xCoord != null && yCoord != null) {
          center = LatLng(double.parse(popup!.y.toString()),
              double.parse(popup!.x.toString()));
          markers.add(Marker(markerId: '마커', latLng: center));
        }

        isLoading = false;
        like = data.bookmark!;
      });
    } catch (error) {
      // 오류 처리
      Logger.debug('Error fetching popup data: $error');
    }
  }

  Future<void> popupDelete() async {
    try {
      final data = await Api.popupDelete(widget.storeId);

      if (!data.toString().contains("fail") && mounted) {
        showAlert(context, "성공", "팝업스토어가 삭제되었습니다.", () {
          Navigator.of(context).pop();

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProfilePage()));
        });
      }
    } catch (error) {
      // 오류 처리
      Logger.debug('Error fetching popup data: $error');
    }
  }

  Future<void> popupStoreAllow() async {
    try {
      final response = await Api.popupAllow(widget.storeId);
      final responseString = response.toString();
      final applicantUsername =
          RegExp(r'\{data: (.+?)\}').firstMatch(responseString)?.group(1) ??
              ''; // userName 찾는 정규식

      if (applicantUsername.isNotEmpty && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('승인 완료되었습니다.'),
          ),
        );

        final Map<String, String> alarmDetails = {
          'title': '팝업 승인 완료',
          'label': '성공적으로 팝업 등록이 완료되었습니다.',
          'time': DateFormat('MM월 dd일 HH시 mm분').format(DateTime.now()),
          'active': 'true',
          'storeId': widget.storeId,
        };

        // 서버에 알람 추가
        await http.post(
          Uri.parse(
              'https://pophub-fa05bf3eabc0.herokuapp.com/alarm/alarm_add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userName': applicantUsername,
            'type': 'alarms',
            'alarmDetails': alarmDetails,
          }),
        );

        // Firestore에 알람 추가
        await FirebaseFirestore.instance
            .collection('users')
            .doc(applicantUsername)
            .collection('alarms')
            .add(alarmDetails);

        // 로컬 알림 발송
        await const AlarmPage().showNotification(alarmDetails['title']!,
            alarmDetails['label']!, alarmDetails['time']!);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('승인 완료되었습니다.'),
          ),
        );
        Navigator.of(context).pop();

        final data = await Api.pendingList();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StoreListPage(
                      popups: data,
                      titleName: "승인 리스트",
                    )));

        setState(() {
          allowSuccess = true;
          isLoading = false;
        });
      } else {
        Logger.debug("승인에 실패했습니다.");
      }
    } catch (error) {
      // 오류 처리
      Logger.debug('Error fetching popup data: $error');
    }
  }

  Future<void> fetchReviewData() async {
    try {
      List<ReviewModel>? dataList = await Api.getReviewList(widget.storeId);

      if (dataList.isNotEmpty) {
        setState(() {
          reviewList = dataList;
          for (int i = 0; i < dataList.length; i++) {
            rating += dataList[i].rating!;
          }
          rating = rating / dataList.length;
        });
      }
    } catch (error) {
      Logger.debug('Error fetching review data: $error');
    }
  }

  Future<void> popupLike() async {
    Map<String, dynamic> data =
        await Api.storeLike(User().userName, widget.storeId);

    if (data.toString().contains("추가")) {
      await getPopupData();
      setState(() {
        like = true;
      });
    } else {
      await getPopupData();
      setState(() {
        like = false;
      });
    }
  }

  Future<void> fetchGoodsData() async {
    try {
      List<GoodsModel>? dataList = await Api.getPopupGoodsList(widget.storeId);

      if (dataList.isNotEmpty) {
        setState(() {
          goodsList = dataList;
        });
      }
    } catch (error) {
      Logger.debug('Error fetching goods data: $error');
    }
  }

  @override
  void initState() {
    initializeData();
    super.initState();
  }

  void refreshReviewData() async {
    await getPopupData();
    await fetchReviewData();
    await fetchGoodsData();
  }

  Future<void> initializeData() async {
    print('refresh');
    await getPopupData(); // getPopupData가 완료될 때까지 기다립니다.
    fetchReviewData(); // fetchReviewData를 호출합니다.
    fetchGoodsData();

    Logger.debug("###### $markers");
    Logger.debug("###### $center");
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      body: !isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: screenHeight * 0.9,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: screenWidth,
                          height: AppBar().preferredSize.height,
                          decoration: const BoxDecoration(color: Colors.white),
                        ),
                        Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                sliderWidget(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Transform.translate(
                                      offset: Offset(0, -screenWidth * 0.1),
                                      child: Container(
                                        width: screenWidth * 0.17,
                                        height: screenHeight * 0.01,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${(_current + 1).toString()}/${popup!.image!.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: screenWidth * 0.05,
                                          right: screenWidth * 0.05,
                                          bottom: screenHeight * 0.005),
                                      child: Text(
                                        popup?.name ?? '',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: screenWidth * 0.05,
                                        right: screenWidth * 0.05,
                                        bottom: screenHeight * 0.005,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            (popup?.start != null &&
                                                    popup!.start!.isNotEmpty)
                                                ? DateFormat("yyyy.MM.dd")
                                                    .format(DateTime.parse(
                                                        popup!.start!))
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Text(
                                            ' ~ ',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            (popup?.end != null &&
                                                    popup!.end!.isNotEmpty)
                                                ? DateFormat("yyyy.MM.dd")
                                                    .format(DateTime.parse(
                                                        popup!.end!))
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    for (int i = 0;
                                        i < popup!.schedule!.length;
                                        i++)
                                      if (popup!.schedule![i].dayOfWeek ==
                                          DateFormat('EEE')
                                              .format(DateTime.now()))
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: screenWidth * 0.05,
                                            right: screenWidth * 0.05,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                DateFormat('HH:mm')
                                                    .format(
                                                        DateFormat('HH:mm:ss')
                                                            .parse(popup!
                                                                .schedule![i]
                                                                .openTime))
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Text(
                                                '~',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('HH:mm')
                                                    .format(
                                                        DateFormat('HH:mm:ss')
                                                            .parse(popup!
                                                                .schedule![i]
                                                                .closeTime))
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    timeVisible = !timeVisible;
                                                  });
                                                },
                                                child: Icon(
                                                  timeVisible
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    Visibility(
                                        visible: timeVisible,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: screenWidth * 0.05,
                                              right: screenWidth * 0.05),
                                          child: Column(
                                            children: [
                                              for (int i = 0;
                                                  i < popup!.schedule!.length;
                                                  i++)
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 30,
                                                      child: Text(
                                                        popup!.schedule![i]
                                                            .dayOfWeek,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      DateFormat('HH:mm')
                                                          .format(DateFormat(
                                                                  'HH:mm:ss')
                                                              .parse(popup!
                                                                  .schedule![i]
                                                                  .openTime))
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const Text(
                                                      '~',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat('HH:mm')
                                                          .format(DateFormat(
                                                                  'HH:mm:ss')
                                                              .parse(popup!
                                                                  .schedule![i]
                                                                  .closeTime))
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            ],
                                          ),
                                        )),
                                    Container(
                                      padding: EdgeInsets.only(
                                        left: screenWidth * 0.05,
                                        right: screenWidth * 0.05,
                                        top: screenHeight * 0.005,
                                        bottom: screenHeight * 0.01,
                                      ),
                                      width: screenWidth * 0.9,
                                      child: Text(
                                        popup?.description ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: screenWidth * 0.05,
                                        right: screenWidth * 0.05,
                                      ),
                                      child: SizedBox(
                                        height: screenHeight * 0.2,
                                        width: screenWidth * 0.9,
                                        child: KakaoMap(
                                          onMapCreated: ((controller) async {
                                            mapController = controller;

                                            Logger.debug(center.toString());
                                            Logger.debug(markers.toString());

                                            setState(() {});
                                          }),
                                          markers: markers.toList(),
                                          center: center,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: screenWidth * 0.05,
                                          right: screenWidth * 0.05,
                                          top: 8.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 20,
                                          ),
                                          popup!.location != ""
                                              ? Expanded(
                                                  // Expanded로 감싸서 공간을 제한
                                                  child: Text(
                                                    popup!.location
                                                        .toString()
                                                        .replaceAll("/", "  "),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                )
                                              : const Text("")
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: screenWidth * 0.05,
                                        right: screenWidth * 0.05,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PopupReview(
                                                      storeId: widget.storeId,
                                                      storeName: popup!.name!,
                                                      popupDetailRefresh:
                                                          refreshReviewData,
                                                    )),
                                          );
                                        },
                                        child: SizedBox(
                                          width: screenWidth * 0.9,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Row(
                                                    children: List.generate(
                                                      5,
                                                      (starIndex) => Icon(
                                                        starIndex <
                                                                (rating) // null 대비
                                                            ? Icons.star
                                                            : Icons
                                                                .star_border_outlined,
                                                        size: 20,
                                                        color: Constants
                                                            .REVIEW_STAR_CLOLR,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                      '(${rating.toStringAsFixed(1)}점) ${reviewList != null ? reviewList!.length : 0}개'),
                                                ],
                                              ),
                                              const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        // 최근 리뷰 3개 만 보여줌
                                        for (int index = 0;
                                            index <
                                                (reviewList?.length ?? 0)
                                                    .clamp(0, 3);
                                            index++)
                                          if (reviewList != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 12),
                                              child: Container(
                                                width: screenWidth * 0.9,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(15)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8.0),
                                                            child: Text(
                                                              reviewList![index]
                                                                      .user ??
                                                                  '',
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: List.generate(
                                                          5,
                                                          (starIndex) => Icon(
                                                            starIndex <
                                                                    (reviewList![index]
                                                                            .rating ??
                                                                        0)
                                                                ? Icons.star
                                                                : Icons
                                                                    .star_border_outlined,
                                                            size: 20,
                                                            color: Constants
                                                                .REVIEW_STAR_CLOLR,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(reviewList![index]
                                                              .content ??
                                                          ''),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, bottom: 10),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GoodsList(
                                                          popup: popup!,
                                                        )),
                                              );
                                            },
                                            child: SizedBox(
                                              width: screenWidth * 0.9,
                                              child: const Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '굿즈',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (goodsList != null)
                                              SizedBox(
                                                  width: screenWidth,
                                                  height: screenWidth * 0.8,
                                                  // ListView
                                                  child: ListView.builder(
                                                      itemCount:
                                                          goodsList?.length ??
                                                              0, // null 체크 추가
                                                      // physics: const NeverScrollableScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final goods =
                                                            goodsList![index];

                                                        return Padding(
                                                          padding: EdgeInsets.only(
                                                              left:
                                                                  screenWidth *
                                                                      0.05,
                                                              right: goodsList!
                                                                          .length ==
                                                                      index + 1
                                                                  ? screenWidth *
                                                                      0.05
                                                                  : 0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          GoodsDetail(
                                                                    popupName:
                                                                        popup!
                                                                            .name!,
                                                                    popupId:
                                                                        popup!
                                                                            .id!,
                                                                    goodsId: goods
                                                                        .product,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.5,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    child: Image
                                                                        .network(
                                                                      '${goods.image![0]}',
                                                                      // width: screenHeight * 0.07 - 5,
                                                                      width:
                                                                          screenWidth *
                                                                              0.5,
                                                                      height:
                                                                          screenWidth *
                                                                              0.5,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    //     Image.asset(
                                                                    //   'assets/images/Untitled.png',
                                                                    //   width:
                                                                    //       screenWidth *
                                                                    //           0.5,
                                                                    // ),
                                                                    //   fit: BoxFit.cover,)
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            8.0),
                                                                    child: Text(
                                                                      goods
                                                                          .productName,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${goods.quantity.toString()}개',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      })),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: -AppBar().preferredSize.height + 20,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.transparent,
                                child: AppBar(
                                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  leading: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                    ),
                                  ),
                                  actions: [
                                    Visibility(
                                      visible:
                                          User().userName == popup?.username,
                                      child: PopupMenuButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                        ),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            child: const Text('스토어 삭제'),
                                            onTap: () {
                                              popupDelete();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    width: screenWidth,
                    height: screenHeight * 0.1,
                    decoration: const BoxDecoration(
                        border: Border(
                      top: BorderSide(
                        width: 2,
                        color: Color(0xFFADD8E6),
                      ),
                    )),
                    child: Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05,
                            bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Visibility(
                              visible: widget.mode == "view",
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (User().userName != "") {
                                        popupLike();
                                      } else {
                                        if (context.mounted) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Login()));
                                        }
                                      }
                                    },
                                    child: Icon(
                                      like
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 30,
                                      color: like ? Colors.red : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    popup!.mark.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: widget.mode == "view",
                              child: const Spacer(),
                            ),
                            Visibility(
                              visible: widget.mode == "view",
                              child: Container(
                                width: screenWidth * 0.3,
                                height: screenHeight * 0.05,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  border: Border.all(
                                    width: 2,
                                    color: const Color(0xFFADD8E6),
                                  ),
                                  color: const Color(0xFFADD8E6),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    if (User().userName != "") {
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReserveDate(
                                              popup: popup!,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const Login(),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Center(
                                    child: Text(
                                      '예약하기',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: widget.mode == "pending" &&
                                  User().role == "Manager",
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    width: screenWidth * 0.45,
                                    height: screenHeight * 0.06,
                                    child: OutlinedButton(
                                      onPressed: () => {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('팝업 승인'),
                                              content: const Text('승인 하시겠습니까?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('취소'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    popupStoreAllow();
                                                  },
                                                  child: const Text('승인하기'),
                                                ),
                                              ],
                                            );
                                          },
                                        )
                                      },
                                      child: const Text("승인하기"),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    width: screenWidth * 0.45,
                                    height: screenHeight * 0.06,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        disabledForegroundColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: Constants.DEFAULT_COLOR,
                                          width: 1.0,
                                        ),
                                      ),
                                      onPressed: () => {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MultiProvider(
                                                        providers: [
                                                          ChangeNotifierProvider(
                                                              create: (_) =>
                                                                  StoreModel())
                                                        ],
                                                        child:
                                                            PendingRejectPage(
                                                          id: popup!.id
                                                              .toString(),
                                                        ))))
                                      },
                                      child: const Text(
                                        "거절하기",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: widget.mode == "modify",
                              child: Container(
                                width: screenWidth * 0.9,
                                height: screenHeight * 0.06,
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: OutlinedButton(
                                    onPressed: () => {
                                          if (mounted)
                                            {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MultiProvider(
                                                              providers: [
                                                                ChangeNotifierProvider(
                                                                    create: (_) =>
                                                                        StoreModel())
                                                              ],
                                                              child:
                                                                  StoreCreatePage(
                                                                mode: "modify",
                                                                popup: popup,
                                                              ))))
                                            }
                                        },
                                    child: const Text("수정하기")),
                              ),
                            )
                          ],
                        ))),
              ],
            )
          : const SizedBox(),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: popup!.image!.map(
        (img) {
          return Builder(
            builder: (context) {
              return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Image.network(
                        img,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        top: 0, // 그림자의 위치 조정
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 30, // 그림자의 높이 조정
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 50,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ));
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: 300,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }
}
