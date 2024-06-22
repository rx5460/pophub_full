import 'package:flutter/material.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/nav/bottom_navigation_page.dart';
import 'package:pophub/screen/setting/withdrawal_page.dart';
import 'package:pophub/utils/http.dart';

class AppSetting extends StatefulWidget {
  const AppSetting({super.key});

  @override
  State<AppSetting> createState() => _AppSettingState();
}

class _AppSettingState extends State<AppSetting> {
  Future<void> logout() async {
    await secureStorage.deleteAll();
    User().clear();

    if (mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const BottomNavigationPage()));
    }
  }

  int count = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          const CustomTitleBar(titleName: "앱 설정"),
          // ListTile(
          //   title: const Text('알림 설정'),
          //   trailing: const Icon(Icons.arrow_forward_ios),
          //   onTap: () {
          //     // 알림 설정 페이지로 이동
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => const AlarmSettingsPage()),
          //     );
          //   },
          // ),
          // ListTile(
          //   title: const Text('약관'),
          //   trailing: const Icon(Icons.arrow_forward_ios),
          //   onTap: () {
          //     // 약관 페이지로 이동
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => Container()),
          //     );
          //   },
          // ),
          ListTile(
            title: const Text('로그아웃'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              logout();
            },
          ),
          ListTile(
            title: const Text('회원탈퇴'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WithdrawalPage()));
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('앱버전 0.1'),
          ),
        ],
      ),
    );
  }
}
