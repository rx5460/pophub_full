library remedi_kopo;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pophub/model/kopo_model.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/utils/log.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RemediKopo extends StatefulWidget {
  static const String PATH = '/alter_kopo';

  const RemediKopo(
      {Key? key,
      this.title = '주소검색',
      this.colour = Colors.white,
      this.apiKey = '',
      this.callback})
      : super(key: key);

  @override
  RemediKopoState createState() => RemediKopoState();

  final String title;
  final Color colour;
  final String apiKey;
  final Function? callback;
}

class RemediKopoState extends State<RemediKopo> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..addJavaScriptChannel("onComplete",
          onMessageReceived: (JavaScriptMessage message) {
        KopoModel result = KopoModel.fromJson(jsonDecode(message.message));

        if (widget.callback != null) {
          widget.callback!(result);
        }

        Navigator.pop(context, result);
      })
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            /// 황지민 : 결제시 intent 버그를 막기위한 작업
            /// 2024/05/20 재 수정 ..
            ///
            Logger.debug("### ${request.url}");
            if (request.url.startsWith('intent')) {
              String parseUrl = request.url;
              if (parseUrl.contains("intent")) {
                parseUrl = parseUrl.replaceAll("intent", "kakaotalk");
              }
              return NavigationDecision.prevent;
            }
            // else if (request.url.startsWith('http://localhost')) {
            //   return NavigationDecision.prevent;
            // }
            else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(
          Uri.parse('https://studio-b-co-kr.github.io/kopo/assets/daum.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomTitleBar(
          titleName: "주소 검색",
        ),
        body: WebViewWidget(controller: _webViewController)

        // WebView(
        //     initialUrl: 'https://studio-b-co-kr.github.io/kopo/assets/daum.html',
        //     javascriptMode: JavascriptMode.unrestricted,
        //     javascriptChannels: Set.from([
        //       JavascriptChannel(
        //           name: 'onComplete',
        //           onMessageReceived: (JavascriptMessage message) {
        //             //This is where you receive message from
        //             //javascript code and handle in Flutter/Dart
        //             //like here, the message is just being printed
        //             //in Run/LogCat window of android studio
        //             KopoModel result =
        //                 KopoModel.fromJson(jsonDecode(message.message));

        //             if (widget.callback != null) {
        //               widget.callback!(result);
        //             }

        //             Navigator.pop(context, result);
        //           }),
        //     ]),
        //     onWebViewCreated: (WebViewController webViewController) async {
        //       _controller = webViewController;
        //     }),
        );
  }
}
