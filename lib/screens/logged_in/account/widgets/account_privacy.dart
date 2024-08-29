import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AccountPrivacy extends StatefulWidget {
  const AccountPrivacy({super.key});

  @override
  State<AccountPrivacy> createState() => _AccountPrivacyState();
}

class _AccountPrivacyState extends State<AccountPrivacy> {
  late WebViewController controller;
  bool isLoading = true;

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
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://nutrisyncai-145173104.hubspotpagebuilder.eu/en-gb/?hs_preview=xpDlnACp-111471759307#about'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : WebViewWidget(controller: controller),
    );
  }
}
