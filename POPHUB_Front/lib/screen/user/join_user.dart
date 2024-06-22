import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/UserNotifier.dart';
import 'package:pophub/screen/custom/custom_text_form_feild.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/user/profile_add_page.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';
import 'package:pophub/utils/utils.dart';
import 'package:provider/provider.dart';

class JoinUser extends StatefulWidget {
  const JoinUser({super.key});

  @override
  State<JoinUser> createState() => _JoinUserState();
}

class _JoinUserState extends State<JoinUser> {
  String? userRole = "General Member";
  final _idFormkey = GlobalKey<FormState>();
  final _pwFormkey = GlobalKey<FormState>();
  final _confirmPwFormkey = GlobalKey<FormState>();
  bool joinComplete = false;

  late final TextEditingController idController = TextEditingController();
  late final TextEditingController pwController = TextEditingController();
  late final TextEditingController confirmPwController =
      TextEditingController();
  TextEditingController nicknameController = TextEditingController();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool checked = false;

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  Future<void> singUpApi() async {
    final data = await Api.signUp(
        idController.text, pwController.text, userRole.toString());

    if (!mounted) return;

    if (data.toString().contains("완료")) {
      joinComplete = true;
      showAlert(context, "확인", "회원가입이 완료되었습니다.", () {
        loginApi();
        // if (mounted) {
        //   Navigator.of(context).pop();
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => const Login()),
        //   );
        // }
      });
    } else {
      joinComplete = false;
      showAlert(context, "경고", "회원가입에 실패했습니다.", () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
    userNotifier.refresh();
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

        Logger.debug(userRole.toString());

        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                                create: (_) => UserNotifier())
                          ],
                          child: ProfileAdd(
                            refreshProfile: () {},
                            useCallback: false,
                            isUser: userRole == "General Member",
                          ))));
        }
      }
    } else {
      if (mounted) {
        showAlert(context, "경고", "로그인 처리에 실패하였습니다.", () {
          Navigator.of(context).pop();
        });
      }
    }
    userNotifier.refresh();
  }

  Future<void> idCheckApi() async {
    if (idController.text == "") {
      showAlert(context, "경고", "아이디를 입력해주세요.", () {
        Navigator.of(context).pop();
      });
    }

    Map<String, dynamic> data = await Api.idCheck(idController.text);

    if (mounted) {
      if (!data.toString().contains("Exists")) {
        showAlert(context, "안내", "아이디 사용 가능합니다.", () {
          Navigator.of(context).pop();
        });
        setState(() {
          checked = true;
        });
      } else {
        showAlert(context, "경고", "아이디가 중복되었습니다.", () {
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return SafeArea(
        child: Scaffold(
            body: Center(
                child: Container(
                    padding: const EdgeInsets.only(
                        left: Constants.DEFAULT_PADDING,
                        right: Constants.DEFAULT_PADDING,
                        top: Constants.DEFAULT_PADDING,
                        bottom: Constants.DEFAULT_PADDING),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const CustomTitleBar(titleName: "회원가입"),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Form(
                                    key: _idFormkey,
                                    child: CustomTextFormFeild(
                                      controller: idController,
                                      hintText: "아이디",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "아이디를 입력해주세요 !";
                                        }
                                        //TODO 황지민 : 중복된 확인
                                        return null;
                                      },
                                      textInputType: TextInputType.text,
                                      onChange: () => {},
                                    ),
                                  )),
                              SizedBox(
                                width: screenWidth * 0.01,
                              ),
                              SizedBox(
                                width: screenWidth * 0.2,
                                height: screenHeight * 0.065,
                                child: OutlinedButton(
                                  onPressed: () {
                                    if (checked) {
                                      setState(() {
                                        checked = false;
                                      });
                                    } else if (idController.text != '') {
                                      idCheckApi();
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      checked ? '수정' : '중복확인',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Form(
                            key: _pwFormkey,
                            child: CustomTextFormFeild(
                              controller: pwController,
                              hintText: "비밀번호",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "비밀번호를 입력해주세요 !";
                                }
                                if (value.length < 8) {
                                  return '비밀번호는 8자 이상으로 입력해주세요.';
                                }
                                //TODO 황지민 : 중복된 확인
                                return null;
                              },
                              textInputType: TextInputType.text,
                              onChange: () => {},
                              isPw: true,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 15, bottom: 15),
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Form(
                            key: _confirmPwFormkey,
                            child: CustomTextFormFeild(
                              controller: confirmPwController,
                              hintText: "비밀번호 재입력",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "비밀번호를 입력해주세요 !";
                                }
                                if (value.length < 8) {
                                  return '비밀번호는 8자 이상으로 입력해주세요.';
                                }
                                if (confirmPwController.text !=
                                    pwController.text) {
                                  return '비밀번호가 일치하지 않습니다.';
                                }
                                return null;
                              },
                              textInputType: TextInputType.text,
                              onChange: () => {},
                              isPw: true,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                            ),
                            const Icon(
                              Icons.info_outline,
                              color: Colors.black87,
                              size: 25,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                "팝업스토어 등록하실 분들은 판매자로 가입부탁드립니다 !",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Radio<String>(
                              value: 'General Member',
                              groupValue: userRole,
                              onChanged: (value) {
                                setState(() {
                                  userRole = value;
                                });
                              },
                              visualDensity: const VisualDensity(
                                  horizontal: -4, vertical: 0),
                            ),
                            const Text('사용자'),
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                            ),
                            Radio<String>(
                              value: 'President',
                              groupValue: userRole,
                              onChanged: (value) {
                                setState(() {
                                  userRole = value;
                                });
                              },
                              visualDensity: const VisualDensity(
                                  horizontal: -4, vertical: 0),
                            ),
                            const Text('판매자'),
                            // Radio<String>(
                            //   value: 'Manager',
                            //   groupValue: userRole,
                            //   onChanged: (value) {
                            //     setState(() {
                            //       userRole = value;
                            //     });
                            //   },
                            //   visualDensity: const VisualDensity(
                            //       horizontal: -4, vertical: 0),
                            // ),
                            // const Text('맛스타'),
                          ],
                        ),
                        const Spacer(flex: 40),
                        Container(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          height: 55,
                          width: double.infinity,
                          child: OutlinedButton(
                              onPressed: () => {
                                    if (_idFormkey.currentState!.validate() &&
                                        _pwFormkey.currentState!.validate() &&
                                        _confirmPwFormkey.currentState!
                                            .validate())
                                      {
                                        if (checked)
                                          {
                                            singUpApi(),
                                          }
                                        else
                                          {
                                            showAlert(context, "경고",
                                                "아이디 중복체크를 해주세요.", () {
                                              Navigator.of(context).pop();
                                            })
                                          }
                                      }
                                  },
                              child: const Text("완료")),
                        ),
                      ],
                    )))));
  }
}
