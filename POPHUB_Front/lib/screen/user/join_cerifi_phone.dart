import 'package:flutter/material.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/UserNotifier.dart';
import 'package:pophub/screen/custom/custom_text_form_feild.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/custom/custom_toast.dart';
import 'package:pophub/screen/user/join_user.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';

class CertifiPhone extends StatefulWidget {
  const CertifiPhone({super.key});

  @override
  State<CertifiPhone> createState() => _CertifiPhoneState();
}

class _CertifiPhoneState extends State<CertifiPhone> {
  get http => null;
  final _phoneFormkey = GlobalKey<FormState>();
  final _certifiFormkey = GlobalKey<FormState>();
  bool isDialogShowing = false;

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

    if (!mounted) return;
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
        if (!mounted) return;

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
      }
    } else {
      if (!isDialogShowing) {
        setState(() {
          isDialogShowing = true;
        });
        if (!mounted) return;

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
                    const CustomTitleBar(titleName: "휴대폰 본인 인증"),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: double.infinity,
                      child: const Text(
                        "도용 방지를 위해\n본인 인증을 완료해주세요!",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
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
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                          onPressed: () => {
                                if (userNotifier.isVerify)
                                  {
                                    User().phoneNumber = phoneController.text,
                                    phoneController.text = "",
                                    certifiController.text = "",
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const JoinUser()))
                                  }
                                else
                                  {
                                    showAlert(context, "", "핸드폰 인증을 완료해주세요.",
                                        () {
                                      Navigator.of(context).pop();
                                    })
                                  }
                              },
                          child: const Text("완료")),
                    ),
                  ],
                )),
          ),
        ));
      },
    );
  }
}
