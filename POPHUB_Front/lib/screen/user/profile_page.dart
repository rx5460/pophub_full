import 'package:flutter/material.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/review_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/StoreNotifier.dart';
import 'package:pophub/screen/setting/app_setting_page.dart';
import 'package:pophub/screen/setting/inquiry_page.dart';
import 'package:pophub/screen/setting/notice_page.dart';
import 'package:pophub/screen/store/alarm_list_page.dart';
import 'package:pophub/screen/store/popup_detail.dart';
import 'package:pophub/screen/store/store_add_page.dart';
import 'package:pophub/screen/store/store_list_page.dart';
import 'package:pophub/screen/user/acount_info.dart';
import 'package:pophub/screen/user/login.dart';
import 'package:pophub/screen/user/profile_add_page.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profile; // profile 변수를 nullable로 선언
  bool isLoading = true; // 로딩 상태 변수 추가
  List<ReviewModel>? reviewList;

  Future<void> profileApi() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = await Api.getProfile(User().userId);

    if (!data.toString().contains("fail")) {
      profile = data;
      User().userName = data['userName'];
      User().phoneNumber = data['phoneNumber'];
      User().age = data['age'];
      User().gender = data['gender'];
      User().file = data['userImage'] ?? '';
      User().role = data['userRole'] ?? '';
    } else {
      // 에러 처리
      if (mounted) {
        if (User().userId != "") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileAdd(
                        refreshProfile: profileApi,
                        useCallback: true,
                        isUser: true,
                      )));
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Login()));
        }
      }
    }

    setState(() {
      isLoading = false; // 로딩 상태 변경
    });
  }

  Future<void> checkStoreApi() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> data = await Api.getMyPopup(User().userName);

    if (!data.toString().contains("fail") &&
        !data.toString().contains("없습니다")) {
      //TODO : 황지민 팝업 가져오는경우 처리
      PopupModel popup;
      popup = PopupModel.fromJson(data[0]);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PopupDetail(
              storeId: popup.id!,
              mode: "modify",
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(providers: [
                      ChangeNotifierProvider(create: (_) => StoreModel())
                    ], child: const StoreCreatePage(mode: "add"))));
      }
    }

    setState(() {
      isLoading = false; // 로딩 상태 변경
    });
  }

  Future<void> fetchReviewData() async {
    try {
      List<ReviewModel>? dataList =
          await Api.getReviewListUser(User().userName);

      if (dataList.isNotEmpty) {
        setState(() {
          reviewList = dataList;
        });
      }
    } catch (error) {
      Logger.debug('Error fetching review data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    profileApi(); // API 호출
    fetchReviewData();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AppSetting()));
            },
          ),
          SizedBox(
            width: screenWidth * 0.05,
          )
        ],
        backgroundColor: const Color(0xFFADD8E6),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    Container(
                      width: screenWidth,
                      height: screenHeight * 0.2,
                      decoration: const BoxDecoration(
                        color: Color(0xFFADD8E6),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: Offset(0, screenHeight * 0.025),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        width: screenWidth,
                        height: screenHeight * 1,
                        child: Center(
                            child: Container(
                          width: screenWidth * 0.9,
                          height: screenHeight * 0.65,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                              color: Colors.grey,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: screenWidth * 0.1),
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AcountInfo(
                                                refreshProfile: profileApi,
                                              )),
                                    );
                                  },
                                  child: SizedBox(
                                    // width: screenWidth * 0.4,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 20),
                                        Text(
                                          // 닉네임으로 수정
                                          profile?['userName'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: screenHeight * 0.03),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: (screenWidth * 0.3) - 2,
                                        child: Column(
                                          children: [
                                            Text(
                                              profile?['pointScore']
                                                      .toString() ??
                                                  '',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              '포인트',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: screenWidth * 0.15,
                                        width: 1,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(
                                        width: (screenWidth * 0.3) - 2,
                                        child: const Column(
                                          children: [
                                            Text(
                                              '0',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              '방문',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: screenWidth * 0.15,
                                        width: 1,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(
                                        width: (screenWidth * 0.3) - 2,
                                        child: Column(
                                          children: [
                                            Text(
                                              reviewList?.length.toString() ??
                                                  '0',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              '리뷰',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MenuList(
                                  icon: Icons.info_outline,
                                  text: '공지사항',
                                  onClick: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const NoticePage()));
                                  },
                                ),
                                MenuList(
                                  icon: Icons.help_outline,
                                  text: '문의내역',
                                  onClick: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const InquiryPage()));
                                  },
                                ),
                                // MenuList(
                                //   icon: Icons.credit_card,
                                //   text: '결제 내역',
                                //   onClick: () {
                                //     Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //             builder: (context) =>
                                //                 const PaymentHistoryPage()));
                                //   },
                                // ),
                                Visibility(
                                  visible: User().role == "President",
                                  child: MenuList(
                                    icon: Icons.message_outlined,
                                    text: '내 팝업스토어',
                                    onClick: () {
                                      checkStoreApi();
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible: User().role == "Manager",
                                  child: MenuList(
                                    icon: Icons.assignment_turned_in_outlined,
                                    text: '팝업스토어 승인 대기',
                                    onClick: () async {
                                      final data = await Api.pendingList();
                                      if (context.mounted) {
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
                                                        child: StoreListPage(
                                                          popups: data,
                                                          titleName: "승인 리스트",
                                                          mode: "pending",
                                                        ))));
                                      }
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible: User().role == "General Member" ||
                                      User().role == "President",
                                  child: MenuList(
                                    icon: Icons.event_note,
                                    text: '예약 내역',
                                    onClick: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AlarmListPage(
                                                    mode: "name",
                                                    titleName: "예약 내역",
                                                  )));
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible: User().role == "President",
                                  child: MenuList(
                                    icon: Icons.event_note,
                                    text: '내 팝업스토어 예약 내역',
                                    onClick: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AlarmListPage(
                                                    mode: "store",
                                                    titleName: "내 팝업스토어 예약 내역",
                                                  )));
                                    },
                                  ),
                                ),

                                // MenuList(
                                //   icon: Icons.message_outlined,
                                //   text: '장바구니',
                                //   onClick: () {},
                                // ),
                              ],
                            ),
                          ),
                        )),
                      )
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // SizedBox(
                    //   width: screenWidth,
                    //   child: CircleAvatar(
                    //     backgroundImage: NetworkImage(profile['userImage'] ?? ''),
                    //     radius: 50,
                    //   ),
                    // ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.26,
                          height: screenWidth * 0.26,
                          child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(1000),
                              ),
                              child: profile?['userImage'] != null
                                  ? Image.network(
                                      profile?['userImage'] ?? '',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset('assets/images/goods.png')),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
    );
  }
}

class MenuList extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function() onClick;
  const MenuList({
    super.key,
    required this.icon,
    required this.text,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Padding(
      padding: EdgeInsets.only(
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          top: screenHeight * 0.022,
          bottom: screenHeight * 0.022),
      child: GestureDetector(
        onTap: onClick,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
