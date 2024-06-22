import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:pophub/model/user.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // FCM 토큰 얻기
    String? fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      // 서버에 토큰 전송
      await sendTokenToServer(fcmToken);
    }

    // 토큰 갱신 감지
    FirebaseMessaging.instance.onTokenRefresh.listen(sendTokenToServer);
  }

  Future<void> sendTokenToServer(String token) async {
    await http.post(
      Uri.parse('http://pophub-fa05bf3eabc0.herokuapp.com/token_save'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userId': User().userId,
        'fcmToken': token,
      }),
    );
  }
}
