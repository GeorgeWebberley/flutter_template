import 'package:share_plus/share_plus.dart';

class ShareProvider {
  Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
