import 'package:flutter/material.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/store/category_page.dart';
import 'package:pophub/screen/store/favorites_page.dart';
import 'package:pophub/screen/store/home_page.dart';
import 'package:pophub/screen/store/map_page.dart';
import 'package:pophub/screen/user/login.dart';
import 'package:pophub/screen/user/profile_add_page.dart';
import 'package:pophub/screen/user/profile_page.dart';
import 'package:pophub/utils/api.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  final List<Widget> _pages = [
    const CategoryPage(),
    const MapPage(),
    const HomePage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];
  final List<IconData> _icons = [
    Icons.menu,
    Icons.map_outlined,
    Icons.home,
    Icons.favorite_border_outlined,
    Icons.person_outline,
  ];
  int _selectedIndex = 2; // 선택된 인덱스를 저장하는 변수 추가
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    // double screenHeight = screenSize.height;
    return WillPopScope(
      onWillPop: () {
        return Future(() => false); // 뒤로가기 막음
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 2,
                color: Color(0xFFADD8E6),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_pages.length, (index) {
              return index == 2
                  ? Transform.translate(
                      offset: Offset(0, -screenWidth * 0.06),
                      child: InkWell(
                        highlightColor: Colors.white,
                        splashColor: Colors.white,
                        onTap: () {
                          _pageController.jumpToPage(index);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: screenWidth * 0.2,
                              width: screenWidth * 0.2,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50),
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: const Color(0xFFADD8E6),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: screenWidth * 1,
                                  height: screenWidth * 1,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : InkWell(
                      highlightColor: Colors.white,
                      splashColor: Colors.white,
                      onTap: () async {
                        if (index == 4) {
                          Map<String, dynamic> data =
                              await Api.getProfile(User().userId);

                          if (!data.toString().contains("fail")) {
                            _pageController.jumpToPage(index);
                          } else {
                            // 에러 처리
                            if (mounted) {
                              if (User().userId != "") {
                                if (context.mounted) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProfileAdd(
                                                refreshProfile: () {},
                                                useCallback: false,
                                                isUser: true,
                                              )));
                                }
                              } else {
                                if (context.mounted) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Login()));
                                }
                              }
                            }
                          }
                        } else {
                          _pageController.jumpToPage(index);
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: screenWidth * 0.25,
                            width: screenWidth * 0.2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: screenWidth * 0.04),
                                  child: Icon(
                                    _icons[index], // 각 페이지에 대한 고유한 아이콘 지정
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
            }),
          ),
        ),
      ),
    );
  }
}
