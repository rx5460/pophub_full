import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/UserNotifier.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/nav/bottom_navigation_page.dart';
import 'package:pophub/screen/user/find_id.dart';
import 'package:pophub/screen/user/join_cerifi_phone.dart';
import 'package:pophub/screen/user/reset_passwd.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/utils.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loginCompelete = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final TextEditingController idController = TextEditingController();
  late final TextEditingController pwController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  Future<void> loginApi() async {
    Map<String, dynamic> data =
        await Api.login(idController.text, pwController.text);

    if (!data.toString().contains("fail")) {
      if (data['token'].isNotEmpty) {
        // 토큰 추가
        await _storage.write(key: 'token', value: data['token']);
        // User 싱글톤에 user_id 추가
        User().userId = data['user_id'];

        //await Api.profileAdd();

        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MultiProvider(providers: [
                        ChangeNotifierProvider(create: (_) => UserNotifier())
                      ], child: const BottomNavigationPage())));
        }
      }
    } else {
      if (mounted) {
        showAlert(context, "경고", "아이디와 비밀번호를 확인해주세요.", () {
          Navigator.of(context).pop();
        });
      }
    }
    userNotifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Center(
              child: Padding(
                  // width: double.infinity,
                  padding: const EdgeInsets.all(Constants.DEFAULT_PADDING),
                  child: Column(
                    children: <Widget>[
                      CustomTitleBar(
                          titleName: "로그인",
                          onBackPressed: () {
                            if (context.mounted) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiProvider(
                                              providers: [
                                                ChangeNotifierProvider(
                                                    create: (_) =>
                                                        UserNotifier())
                                              ],
                                              child:
                                                  const BottomNavigationPage())));
                            }
                          }),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                        width: 150,
                      ),
                      TextField(
                          controller: idController,
                          decoration: const InputDecoration(hintText: "아이디")),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                      ),
                      TextField(
                          controller: pwController,
                          obscureText: true,
                          decoration: const InputDecoration(hintText: "비밀번호")),
                      Container(
                        margin: const EdgeInsets.only(top: 0, bottom: 10),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MultiProvider(
                                                    providers: [
                                                      ChangeNotifierProvider(
                                                          create: (_) =>
                                                              UserNotifier())
                                                    ],
                                                    child: const FindId())))
                                  },
                              child: const Text("아이디 찾기")),
                          TextButton(
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MultiProvider(providers: [
                                                  ChangeNotifierProvider(
                                                      create: (_) =>
                                                          UserNotifier())
                                                ], child: const ResetPasswd())))
                                  },
                              child: const Text("비밀번호 재설정")),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 55,
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: OutlinedButton(
                            onPressed: () => {loginApi()},
                            child: const Text("로그인")),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("계정이 없으신가요?"),
                          TextButton(
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MultiProvider(
                                                    providers: [
                                                      ChangeNotifierProvider(
                                                          create: (_) =>
                                                              UserNotifier())
                                                    ],
                                                    child:
                                                        const CertifiPhone())))
                                  },
                              child: const Text(
                                "회원가입",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                    ],
                  )),
            )));
  }
}
