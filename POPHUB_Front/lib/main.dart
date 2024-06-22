import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:pophub/screen/nav/bottom_navigation_page.dart';
import 'package:pophub/utils/log.dart';
import 'package:pophub/screen/alarm/alarm_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'assets/style.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log("백그라운드 메시지 처리: ${message.notification!.body!}",
      name: 'app.background');
}

void initializeNotification() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const channel = AndroidNotificationChannel(
    'PopHub_channel',
    'PopHub Notification',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings("@mipmap/ic_launcher"),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        navigatorKey.currentState?.pushNamed('/alarm');
      }
    },
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNotified = prefs.getBool('isNotified') ?? false;

    if (!isNotified) {
      developer.log("포그라운드 메시지 처리: ${message.notification!.body!}",
          name: 'app.foreground');
      _showNotification(message, flutterLocalNotificationsPlugin);

      // 플래그 설정
      await prefs.setBool('isNotified', true);
    }
  });
}

Future<void> _showNotification(
    RemoteMessage message, FlutterLocalNotificationsPlugin plugin) async {
  const androidDetails = AndroidNotificationDetails(
    "PopHub_channel",
    "PopHub Notification",
    importance: Importance.high,
  );
  const generalDetails = NotificationDetails(android: androidDetails);

  await plugin.show(
    message.hashCode, // 각 메시지에 대한 고유 해시코드를 사용하여 한 번만 알림
    message.notification!.title,
    message.notification!.body,
    generalDetails,
    payload: message.data['time'],
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  // FCM 알림 초기화
  // initializeNotification();

  await dotenv.load(fileName: 'assets/config/.env');

  AuthRepository.initialize(
    appKey: dotenv.env['APP_KEY'] ?? '',
  );

  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Logger.setLogLevel(LogLevel.debug); // 로그 레벨 설정
    Logger.debug('APP start ! ');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'pophub',
      theme: theme,
      home: const BottomNavigationPage(),
      routes: {
        '/alarm': (context) => const AlarmPage(), // 라우트 설정
      },
    );
  }
}
