import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pophub/model/user.dart';

class AlarmPage extends StatefulWidget {
  final String? payload;
  const AlarmPage({super.key, this.payload});

  @override
  State<AlarmPage> createState() => _AlarmPageState();

  Future<void> showNotification(String title, String body, String time) async {
    var androidDetails = const AndroidNotificationDetails(
      "channelId",
      "Local Notification",
      channelDescription: "Your description",
      importance: Importance.high,
    );
    var generalDetails = NotificationDetails(android: androidDetails);
    await FlutterLocalNotificationsPlugin().show(
      0,
      title,
      body,
      generalDetails,
      payload: time,
    );
  }
}

class _AlarmPageState extends State<AlarmPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.payload != null) {}
  }

  Future<void> showNotification(String title, String body, String time) async {
    var androidDetails = const AndroidNotificationDetails(
      "channelId",
      "Local Notification",
      channelDescription: "Your description",
      importance: Importance.high,
    );
    var generalDetails = NotificationDetails(android: androidDetails);
    await FlutterLocalNotificationsPlugin()
        .show(0, title, body, generalDetails);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '알림',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          dividerColor: const Color(0xFFADD8E6),
          indicatorColor: const Color(0xFFADD8E6),
          indicatorWeight: 3.5,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Colors.black,
          labelStyle: const TextStyle(fontSize: 20),
          tabs: [
            Tab(
                child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.33,
              child: const Center(child: Text('전체')),
            )),
            Tab(
                child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.33,
              child: const Center(child: Text('주문')),
            )),
            Tab(
                child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.33,
              child: const Center(child: Text('대기')),
            )),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildAlarmList('alarms'),
          buildAlarmList('orderAlarms'),
          buildAlarmList('waitAlarms'),
        ],
      ),
    );
  }

  Widget buildAlarmList(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(User().userName)
          .collection(collection)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Text('No data available');
        }
        return ListView(
          children: snapshot.data!.docs.map((document) {
            var data = document.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SizedBox(
                      width: 65,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: data['imageUrl'] != null
                            ? Image.network(
                                data['imageUrl'],
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          data['title'] ?? 'No title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(data['label'] ?? 'No label'),
                        Text(data['time'] ?? 'No time'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      document.reference.delete();
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
