import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/store/popup_detail.dart';

class StoreListPage extends StatelessWidget {
  final List<PopupModel> popups;
  final String titleName;
  final String mode;

  const StoreListPage(
      {super.key,
      required this.popups,
      this.titleName = "팝업스토어",
      this.mode = "view"});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTitleBar(titleName: titleName),
      body: popups.isEmpty || popups[0].category == null
          ? const Center(
              child: Text(
                '팝업스토어 리스트가 없습니다!',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : ListView.builder(
              itemCount: popups.length,
              itemBuilder: (context, index) {
                final popup = popups[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PopupDetail(
                          storeId: popup.id!,
                          mode: mode,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        popup.image != null && popup.image!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  '${popup.image![0]}',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                popup.name ?? 'No name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              Text(
                                (popup.start != null && popup.start!.isNotEmpty)
                                    ? DateFormat("yyyy.MM.dd")
                                        .format(DateTime.parse(popup.start!))
                                    : '',
                              ),
                              Text(popup.location?.replaceAll("/", " ") ??
                                  'No ID'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
