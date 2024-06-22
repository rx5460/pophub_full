import 'package:flutter/material.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/notifier/UserNotifier.dart';
import 'package:pophub/screen/custom/custom_text_form_feild.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/custom/custom_toast.dart';
import 'package:pophub/screen/user/login.dart';
import 'package:pophub/screen/user/reset_passwd.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';

class FindId extends StatefulWidget {
  const FindId({super.key});

  @override
  State<FindId> createState() => _FindIdState();
}

class _FindIdState extends State<FindId> {
  get http => null;
  final _phoneFormkey = GlobalKey<FormState>();
  final _certifiFormkey = GlobalKey<FormState>();
  bool isDialogShowing = false;
  String userId = "";
  bool findSuccess = false;

  late final TextEditingController phoneController = TextEditingController();
  late final TextEditingController certifiController = TextEditingController();

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

    if (data.toString().contains("Successful")) {
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
              isDialogShowing = false;
            });
            userNoti.refresh();
          });
        }

        await findIdApi();
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

  Future<void> findIdApi() async {
    final data = await Api.getId(phoneController.text.toString());
    Logger.debug("### userId = $userId");
    if (!data.toString().contains("fail")) {
      setState(() {
        userId = data["userId"];
        findSuccess = true;
      });
    } else {
      setState(() {
        findSuccess = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
      builder: (_, userNotifier, child) {
        return SafeArea(
            child: Scaffold(
          body: Center(
            child: Padding(
                padding: const EdgeInsets.all(Constants.DEFAULT_PADDING),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const CustomTitleBar(titleName: "아이디 찾기"),
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
                    Visibility(
                      visible: findSuccess,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("회원님의 아이디는"),
                          Text(
                            userId,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const Text("입니다."),
                        ],
                      ),
                    ),
                    Visibility(
                        child: Visibility(
                            visible:
                                findSuccess == false && userNotifier.isVerify,
                            child: Center(
                              child: Text(
                                  "${phoneController.text.toString()} 번호에 해당하는 아이디가 없습니다."),
                            ))),
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
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Login()))
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
                                    child: const Text("로그인")),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child: OutlinedButton(
                                    onPressed: () => {
                                          {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MultiProvider(
                                                            providers: [
                                                              ChangeNotifierProvider(
                                                                  create: (_) =>
                                                                      UserNotifier())
                                                            ],
                                                            child:
                                                                const ResetPasswd())))
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
                                    child: const Text("비밀번호 재설정")),
                              ),
                            )
                          ],
                        ))
                  ],
                )),
          ),
        ));
      },
    );
  }
}
