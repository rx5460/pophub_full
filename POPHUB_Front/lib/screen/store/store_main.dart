import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pophub/assets/constants.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/utils/api.dart';

class StoreMain extends StatefulWidget {
  const StoreMain({super.key});

  @override
  State<StoreMain> createState() => _StoreMainState();
}

class _StoreMainState extends State<StoreMain> {
  bool loginCompelete = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String token = "";
  String profileData = "";

  Future<void> testApi() async {
    final data = await Api.pay(User().userId, "zero22", 1, 33000, 3000, 0);
    // Map<String, dynamic> valueMap = json.decode(data);
    profileData = data.toString();
    setState(() {});
  }

  Future<void> popupApi() async {
    final data = await Api.getProfile(User().userId);
    // Map<String, dynamic> valueMap = json.decode(data);
    profileData = data.toString();
    setState(() {});
  }

  Future<void> _showToken() async {
    token = (await _storage.read(key: 'token'))!;
    setState(() {});
  }

  @override
  void initState() {
    _showToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Center(
              child: Padding(
                  // width: double.infinity,
                  padding: const EdgeInsets.all(Constants.DEFAULT_PADDING),
                  child: Column(
                    children: <Widget>[
                      const CustomTitleBar(titleName: "테스트 페이지"),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                        width: 150,
                      ),
                      Text(profileData),
                      Container(
                        width: double.infinity,
                        height: 55,
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        child: OutlinedButton(
                            onPressed: () => {popupApi()},
                            child: const Text("계정정보 가져오기")),
                      ),
                    ],
                  )),
            )));
  }
}
