import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/GoodsNotifier.dart';
import 'package:pophub/notifier/StoreNotifier.dart';
import 'package:pophub/screen/alarm/alarm_page.dart';
import 'package:pophub/screen/goods/goods_add_page.dart';
import 'package:pophub/screen/store/popup_detail.dart';
import 'package:pophub/screen/store/store_add_page.dart';
import 'package:pophub/screen/store/store_list_page.dart';
import 'package:pophub/screen/user/login.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  TextEditingController searchController = TextEditingController();
  String? searchInput;
  List<PopupModel> poppularList = [];
  List<PopupModel> recommandList = [];
  List<PopupModel> willBeOpenList = [];
  List<PopupModel> willBeCloseList = [];
  bool _isExpanded = false;
  bool addGoodsVisible = false;
  List imageList = [];
  PopupModel? popup;

  Future<void> profileApi() async {
    Map<String, dynamic> data = await Api.getProfile(User().userId);

    if (!data.toString().contains("fail")) {
      User().userName = data['userName'];
      User().phoneNumber = data['phoneNumber'];
      User().age = data['age'];
      User().gender = data['gender'];
      User().file = data['userImage'] ?? '';
      User().role = data['userRole'] ?? '';
      checkStoreApi();
    }
  }

  Future<void> fetchPopupData() async {
    try {
      List<PopupModel>? dataList = await Api.getPopupList();

      if (dataList.isNotEmpty) {
        setState(() {
          poppularList = dataList;
        });
      }
    } catch (error) {
      Logger.debug('Error fetching popup data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    fetchPopupData();
    await profileApi();
    getRecommandPopup();
    await getWillBeOpenPopup();
    await getWillBeClosePopup();
  }

  Future<void> checkStoreApi() async {
    List<dynamic> data = await Api.getMyPopup(User().userName);

    if (!data.toString().contains("fail") &&
        !data.toString().contains("없습니다")) {
      setState(() {
        addGoodsVisible = true;

        if (mounted) {
          popup = PopupModel.fromJson(data[0]);
        }
      });
    } else {
      setState(() {
        addGoodsVisible = false;
      });
    }
  }

  Future<void> getPopupByStoreName(String storeName) async {
    final data = await Api.getPopupByName(storeName);
    if (!data.toString().contains("fail") && mounted) {
      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (_) => StoreModel())
                        ],
                        child: StoreListPage(
                          popups: data,
                          titleName: "검색 결과",
                        ))));
      }
    } else {}
    setState(() {});
  }

  Future<void> getRecommandPopup() async {
    try {
      if (User().userName != "") {
        List<PopupModel>? dataList = await Api.getRecommandPopupList();

        if (dataList.isNotEmpty) {
          setState(() {
            recommandList = dataList;
          });
        }
      }
    } catch (error) {
      Logger.debug('Error getRecommandPopup popup data: $error');
    }
  }

  Future<void> getWillBeOpenPopup() async {
    try {
      List<PopupModel>? dataList = await Api.getWillBeOpenPopupList();

      if (dataList.isNotEmpty) {
        willBeOpenList = dataList;
        if (willBeOpenList.isNotEmpty) {
          for (PopupModel popup in willBeOpenList) {
            if (popup.image != null) {
              setState(() {
                imageList.add(popup.image![0]);
              });
            }
          }
        }
      }
    } catch (error) {
      Logger.debug('Error getRecommandPopup popup data: $error');
    }
  }

  Future<void> getWillBeClosePopup() async {
    try {
      List<PopupModel>? dataList = await Api.getWillBeOpenPopupList();

      if (dataList.isNotEmpty) {
        setState(() {
          willBeCloseList = dataList;
        });
      }
    } catch (error) {
      Logger.debug('Error getRecommandPopup popup data: $error');
    }
  }

  Widget _buildCollapsedFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _isExpanded = true;
        });
      },
      backgroundColor: Constants.DEFAULT_COLOR,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  Widget _buildExpandedFloatingButtons() {
    return Transform.translate(
      offset: Offset(MediaQuery.of(context).size.width * 0.04,
          MediaQuery.of(context).size.height * 0.02),
      child: Stack(
        fit: StackFit.expand, // Stack이 화면 전체를 차지하도록 설정
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = false;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white.withOpacity(0.85), // 반투명 배경
              child: Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.04,
                    bottom: MediaQuery.of(context).size.height * 0.02),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    addGoodsVisible
                        ? _buildFloatingButtonWithText(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiProvider(
                                              providers: [
                                                ChangeNotifierProvider(
                                                    create: (_) =>
                                                        GoodsNotifier())
                                              ],
                                              child: GoodsCreatePage(
                                                  mode: "add",
                                                  popup: popup!))));
                            },
                            icon: Icons.check_box_outlined,
                            text: '굿즈',
                          )
                        : const SizedBox(),
                    addGoodsVisible
                        ? const SizedBox(height: 16)
                        : const SizedBox(),
                    _buildFloatingButtonWithText(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiProvider(
                                        providers: [
                                          ChangeNotifierProvider(
                                              create: (_) => StoreModel())
                                        ],
                                        child: const StoreCreatePage(
                                            mode: "add"))));
                      },
                      icon: Icons.calendar_today,
                      text: '팝업스토어',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtonWithText({
    required Function onPressed,
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          onPressed: onPressed as void Function()?,
          heroTag: null,
          backgroundColor: const Color(0xFF1C77E4),
          shape: const CircleBorder(),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    bool isUserGeneral = User().role == 'general';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: User().userId != ""
            ? Text(
                "반갑습니다, ${User().userName}님 !",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            : Image.asset(
                'assets/images/logo.png',
                width: screenWidth * 0.14,
              ),
        actions: [
          GestureDetector(
            onTap: () {
              if (User().userName != "") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlarmPage()),
                );
              } else {
                if (context.mounted) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                }
              }
            },
            child: const Icon(Icons.notifications_outlined,
                size: 32, color: Colors.black),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      floatingActionButton: User().role == 'President'
          ? (_isExpanded
              ? _buildExpandedFloatingButtons()
              : _buildCollapsedFloatingButton())
          : null,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: screenWidth * 0.9,
                height: screenHeight * 0.055,
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchInput = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                        color: Color(0xFFADD8E6),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0,
                        color: Color(0xFFADD8E6),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    labelText: '어떤 정보를 찾아볼까요?',
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'recipe',
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    suffixIcon: IconButton(
                      onPressed: () {
                        getPopupByStoreName(searchController.text);
                      },
                      icon: const Icon(
                        Icons.search_sharp,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: imageList.isNotEmpty ? sliderWidget() : Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Transform.translate(
                    offset: Offset(0, -screenWidth * 0.1),
                    child: Container(
                      width: screenWidth * 0.17,
                      height: screenWidth * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Text(
                          '${(_current + 1).toString()}/${imageList.length}',
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
              SizedBox(
                width: screenWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '인기 있는 팝업스토어',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MultiProvider(
                                          providers: [
                                            ChangeNotifierProvider(
                                                create: (_) => StoreModel())
                                          ],
                                          child: StoreListPage(
                                            popups: poppularList,
                                            titleName: "인기 팝업스토어",
                                          ))));
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth,
                    height: screenWidth * 0.7,
                    child: ListView.builder(
                      itemCount: poppularList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final popup = poppularList[index];
                        return Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth * 0.05,
                              right: poppularList.length == index + 1
                                  ? screenWidth * 0.05
                                  : 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PopupDetail(
                                    storeId: popup.id!,
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: screenWidth * 0.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  popup.image != null && popup.image!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            '${popup.image![0]}',
                                            width: screenWidth * 0.5,
                                            height: screenWidth * 0.5,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            width: screenWidth * 0.5,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${popup.name}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat("yy.MM.dd").format(DateTime.parse(popup.start!))} ~ ${DateFormat("yy.MM.dd").format(DateTime.parse(popup.end!))}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: screenWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '종료 예정 팝업스토어',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MultiProvider(
                                          providers: [
                                            ChangeNotifierProvider(
                                                create: (_) => StoreModel())
                                          ],
                                          child: StoreListPage(
                                            popups: willBeCloseList,
                                            titleName: "종료 예정 팝업스토어",
                                          ))));
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth,
                    height: screenWidth * 0.7,
                    child: ListView.builder(
                      itemCount: willBeCloseList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final popup = willBeCloseList[index];

                        return Padding(
                          padding: EdgeInsets.only(
                              left: screenWidth * 0.05,
                              right: willBeCloseList.length == index + 1
                                  ? screenWidth * 0.05
                                  : 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PopupDetail(
                                    storeId: popup.id!,
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: screenWidth * 0.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  popup.image != null && popup.image!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            '${popup.image![0]}',
                                            width: screenWidth * 0.5,
                                            height: screenWidth * 0.5,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            width: screenWidth * 0.5,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '${popup.name}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat("yy.MM.dd").format(DateTime.parse(popup.start!))} ~ ${DateFormat("yy.MM.dd").format(DateTime.parse(popup.end!))}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: recommandList != [] && User().userName != "",
                child: SizedBox(
                  width: screenWidth * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '추천 팝업스토어',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (context.mounted) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiProvider(
                                            providers: [
                                              ChangeNotifierProvider(
                                                  create: (_) => StoreModel())
                                            ],
                                            child: StoreListPage(
                                              popups: recommandList,
                                              titleName: "추천 팝업스토어",
                                            ))));
                          }
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: recommandList != [] && User().userName != "",
                child: const SizedBox(
                  height: 10,
                ),
              ),
              Visibility(
                visible: recommandList != [] && User().userName != "",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: screenWidth,
                      height: screenWidth * 0.7,
                      child: ListView.builder(
                        itemCount: recommandList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final popup = recommandList[index];
                          return Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth * 0.05,
                                right: recommandList.length == index + 1
                                    ? screenWidth * 0.05
                                    : 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PopupDetail(
                                      storeId: popup.id!,
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: screenWidth * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    popup.image != null &&
                                            popup.image!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              '${popup.image![0]}',
                                              width: screenWidth * 0.5,
                                              height: screenWidth * 0.5,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              'assets/images/logo.png',
                                              width: screenWidth * 0.5,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${popup.name}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${DateFormat("yy.MM.dd").format(DateTime.parse(popup.start!))} ~ ${DateFormat("yy.MM.dd").format(DateTime.parse(popup.end!))}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: imageList.map(
        (img) {
          return Builder(
            builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.network(
                  img,
                  fit: BoxFit.fill,
                ),
                // Image.asset(
                //   img,
                //   fit: BoxFit.fill,
                // ),
              );
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
