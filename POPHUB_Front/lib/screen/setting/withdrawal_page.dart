import 'package:flutter/material.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/nav/bottom_navigation_page.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/http.dart';
import 'package:pophub/utils/utils.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  _WithdrawalPageState createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  Future<void> resetPasswdApi() async {
    final data = await Api.userDelete();
    if (!data.toString().contains("fail")) {
      await secureStorage.deleteAll();
      User().clear();
      if (mounted) {
        showAlert(context, "성공", "회원탈퇴에 성공했습니다.", () {
          // 여기서 실제 회원탈퇴 로직을 구현

          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BottomNavigationPage()));
        });
      }
    } else {
      if (mounted) {
        showAlert(context, "실패", "회원탈퇴에 실패하였습니다.", () {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
      appBar: const CustomTitleBar(titleName: "회원탈퇴"),
      body: Padding(
          padding: EdgeInsets.only(
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              top: screenHeight * 0.05,
              bottom: screenHeight * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '개인정보 처리 방침',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '회원탈퇴 시 개인정보는 다음과 같이 처리됩니다.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '• 보유 기간: 탈퇴 신청일로부터 1개월 동안 회원님의 개인정보를 보유합니다.\n'
                '• 목적: 이 기간 동안 법적 의무 이행을 위해 개인정보를 보유합니다.\n'
                '• 삭제: 보유 기간이 만료되면 회원님의 개인정보는 안전하게 삭제됩니다.',
              ),
              const SizedBox(height: 16),
              const Text(
                '유의 사항',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• 탈퇴하면 보유 포인트는 사라지게 됩니다.\n'),
              const Spacer(),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    // 회원탈퇴 처리 로직
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('회원탈퇴'),
                          content: const Text('정말로 회원탈퇴를 하시겠습니까?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                resetPasswdApi();
                              },
                              child: const Text('탈퇴하기'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('탈퇴하기',
                      style: TextStyle(
                        fontSize: 18,
                      )),
                ),
              ),
            ],
          )),
    );
  }
}
