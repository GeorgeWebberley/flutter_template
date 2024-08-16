import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AccountPrivacy extends StatefulWidget {
  const AccountPrivacy({super.key});

  @override
  State<AccountPrivacy> createState() => _AccountPrivacyState();
}

class _AccountPrivacyState extends State<AccountPrivacy> {
  late WebViewController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadWebController();
  }

  void loadWebController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: WebViewWidget(controller: controller),
    );
  }
}
