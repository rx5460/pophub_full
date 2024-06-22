import 'package:flutter/material.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';

class AlarmSettingsPage extends StatefulWidget {
  const AlarmSettingsPage({super.key});

  @override
  _AlarmSettingsPageState createState() => _AlarmSettingsPageState();
}

class _AlarmSettingsPageState extends State<AlarmSettingsPage> {
  bool _pushNotification = false;
  bool _marketingConsent = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
      appBar: const CustomTitleBar(titleName: "알림 설정"),
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
              '혜택 / 이벤트 및 기타 알림',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('푸시 알림'),
              value: _pushNotification,
              onChanged: (bool value) {
                setState(() {
                  _pushNotification = value;
                });
              },
              activeTrackColor: Constants.DEFAULT_COLOR,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey,
            ),
            SwitchListTile(
              title: const Text('마케팅 수신 동의'),
              value: _marketingConsent,
              onChanged: (bool value) {
                setState(() {
                  _marketingConsent = value;
                });
              },
              activeTrackColor: Constants.DEFAULT_COLOR,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
