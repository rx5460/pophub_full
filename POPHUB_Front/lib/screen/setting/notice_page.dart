import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/notice_model.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/utils/api.dart';
import 'package:pophub/utils/log.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  @override
  void initState() {
    getPopupData();
    super.initState();
  }

  List<NoticeModel> notices = [];
  Future<void> getPopupData() async {
    try {
      final data = await Api.getNoticeList();
      setState(() {
        notices = data;
      });
      Logger.debug("### $data");
    } catch (error) {
      // 오류 처리
      Logger.debug('Error fetching popup data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleBar(titleName: "공지 사항"),
      body: notices.isNotEmpty
          ? ListView.builder(
              itemCount: notices.length,
              itemBuilder: (BuildContext context, int index) {
                return NoticeTile(
                  title: notices[index].title,
                  date: notices[index].time,
                  content: notices[index].content,
                );
              },
            )
          : const Center(
              child: Text(
              "공지사항이 없습니다.",
              style: TextStyle(fontSize: 16),
            )),
    );
  }
}

class NoticeTile extends StatelessWidget {
  final String title;
  final String date;
  final String content;

  const NoticeTile(
      {super.key,
      required this.title,
      required this.date,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
            border: Border.all(
              color: Constants.LIGHT_GREY,
              width: 0.5,
            ),
            borderRadius: const BorderRadius.all(Radius.zero)),
        child: ExpansionTile(
          title: Text(title),
          subtitle: Text(DateFormat("yyyy.MM.dd").format(DateTime.parse(date))),
          children: <Widget>[
            Container(
              color: Constants.LIGHT_GREY,
              padding: const EdgeInsets.all(16.0),
              child: Text(content),
            ),
          ],
        ));
  }
}
