import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/UserNotifier.dart';
import 'package:pophub/screen/custom/custom_text_form_feild.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/custom/custom_toast.dart';
import 'package:pophub/screen/user/login.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/http.dart';
import 'package:pophub/utils/log.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';

class ResetPasswd extends StatefulWidget {
  const ResetPasswd({super.key});

  @override
  State<ResetPasswd> createState() => _ResetPasswdState();
}

class _ResetPasswdState extends State<ResetPasswd> {
  get http => null;
  final _phoneFormkey = GlobalKey<FormState>();
  final _certifiFormkey = GlobalKey<FormState>();
  bool isDialogShowing = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String token = "";
  String userId = "";
  final _pwFormkey = GlobalKey<FormState>();
  final _confirmPwFormkey = GlobalKey<FormState>();

  late final TextEditingController phoneController = TextEditingController();
  late final TextEditingController certifiController = TextEditingController();
  late final TextEditingController pwController = TextEditingController();
  late final TextEditingController confirmPwController =
      TextEditingController();

  String realAuthCode = "";

  @override
  void dispose() {
    phoneController.dispose();
    certifiController.dispose();
    super.dispose();
  }

  Future<void> certifiApi() async {
    final data = await Api.sendCertifi(phoneController.text.toString());

    if (!data.toString().contains("fail")) {
      realAuthCode = data["Number"];
      if (mounted) {
        ToastUtil.customToastMsg("전송되었습니다.", context);
      }
      setState(() {});
    } else {
      if (mounted) {
        ToastUtil.customToastMsg("전송에 실패하였습니다.", context);
      }
    }
  }

  Future<void> verifyApi(String certifi, UserNotifier userNoti) async {
    final data = await Api.sendVerify(certifi, realAuthCode);
    //= {"data": "Successful"};

    if (!data.toString().contains("fail")) {
      if (!isDialogShowing) {
        setState(() {
          isDialogShowing = true;
        });

        if (mounted) {
          showAlert(context, "확인", "인증되었습니다.", () {
            Navigator.of(context).pop();
            FocusManager.instance.primaryFocus?.unfocus();
            userNoti.isVerify = true;
            setState(() {
              isDialogShowing = true;
            });
            userNoti.refresh();
          });
        }
      }
    } else {
      if (!isDialogShowing) {
        setState(() {
          isDialogShowing = true;
        });
        if (mounted) {
          showAlert(context, "경고", "인증번호를 다시 확인해주세요.", () {
            Navigator.of(context).pop();
            FocusManager.instance.primaryFocus?.unfocus();

            setState(() {
              isDialogShowing = false;
            });
          });
        }
      }
    }
    Logger.debug("${userNoti.isVerify} userNotifier.isVerify");
  }

  Future<void> resetPasswdApi() async {
    final data = await Api.getId(phoneController.text.toString());
    Logger.debug("### userId = $userId");
    if (!data.toString().contains("fail")) {
      userId = data["userId"];
      final passwdData =
          await Api.changePasswd(userId, pwController.text.toString());
      if (!passwdData.toString().contains("fail")) {
        await secureStorage.deleteAll();
        User().clear();
        if (mounted) {
          showAlert(context, "확인", "비밀번호 재설정이 완료되었습니다.", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          });
        }
      }
    } else {
      if (mounted) {
        showAlert(context, "확인", "비밀번호 재설정에 실패했습니다.", () {
          Navigator.of(context).pop();
          setState(() {});
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Consumer<UserNotifier>(
      builder: (_, userNotifier, child) {
        return SafeArea(
            child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(
            child: SizedBox(
              child: Padding(
                  padding: const EdgeInsets.all(Constants.DEFAULT_PADDING),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const CustomTitleBar(titleName: "비밀번호 재설정"),
                      Form(
                          key: _phoneFormkey,
                          child: CustomTextFormFeild(
                            controller: phoneController,
                            hintText: "핸드폰 번호 입력",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "번호를 입력해주세요 !";
                              } else if (!isValidPhoneNumber(value)) {
                                return "전화번호 형식에 맞게 입력해주세요 !";
                              }
                              return null;
                            },
                            textInputType: TextInputType.number,
                            onChange: () => {},
                          )),
                      Container(
                        width: double.infinity,
                        height: 55,
                        margin: const EdgeInsets.only(top: 15),
                        child: OutlinedButton(
                            onPressed: () => {
                                  if (_phoneFormkey.currentState!.validate())
                                    {certifiApi()}
                                },
                            child: const Text("전송")),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Form(
                                  key: _certifiFormkey,
                                  child: CustomTextFormFeild(
                                    controller: certifiController,
                                    hintText: "인증번호 입력",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "인증번호를 입력해주세요!";
                                      }
                                      if (value.length < 6) {
                                        return "인증번호 6자리를 입력해주세요 !";
                                      }
                                      return null;
                                    },
                                    maxlength: 6,
                                    textInputType: TextInputType.number,
                                    onChange: () => {},
                                  ))),
                          Container(
                            width: 80,
                            height: 55,
                            margin: const EdgeInsets.only(
                                top: 18, bottom: 18, left: 10),
                            child: OutlinedButton(
                                onPressed: () => {
                                      if (_certifiFormkey.currentState!
                                              .validate() &&
                                          certifiController.text.length == 6)
                                        {
                                          verifyApi(
                                              certifiController.text.toString(),
                                              userNotifier),
                                        }
                                    },
                                child: const Text(
                                  "확인",
                                  textAlign: TextAlign.center,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Visibility(
                        visible: isDialogShowing && userNotifier.isVerify,
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
                      SizedBox(height: screenHeight * 0.02),
                      Visibility(
                        visible: isDialogShowing,
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
                      const Spacer(),
                      SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 55,
                                  child: OutlinedButton(
                                      onPressed: () => {
                                            {
                                              if (_pwFormkey.currentState!
                                                      .validate() &&
                                                  _confirmPwFormkey
                                                      .currentState!
                                                      .validate())
                                                {
                                                  resetPasswdApi(),
                                                }
                                            }
                                          },
                                      style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Colors.white),
                                          backgroundColor:
                                              const Color(0xffadd8e6),
                                          foregroundColor: Colors.white,
                                          textStyle: const TextStyle(
                                              color: Colors.white),
                                          padding: const EdgeInsets.all(0),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)))),
                                      child: const Text("완료")),
                                ),
                              ),
                            ],
                          ))
                    ],
                  )),
            ),
          ),
        ));
      },
    );
  }
}
