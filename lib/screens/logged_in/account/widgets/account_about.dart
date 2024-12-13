import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountAbout extends StatelessWidget {
  const AccountAbout({
    super.key,
    required this.backToRoot,
  });

  final void Function() backToRoot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: backToRoot,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppPading.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppTitle(title: 'About Nutriveat'),
              Stack(
                children: [
                  AppBox(
                    child: Padding(
                      padding: const EdgeInsets.all(AppPading.large),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(),
                          const AppTitle(title: "Created by"),
                          const Text("Webbro Ltd.").h5(),
                          const Text("Flat 7 Marlborough House,").h5(),
                          const Text("Westgate Street,").h5(),
                          const Text("Cardiff,").h5(),
                          const Text("Wales,").h5(),
                          const Text("CF10 1DE").h5(),
                        ],
                      ),
                    ),
                  ),
                  // TODO: Removed for now until we get a proper webbro limited website
                  // Positioned(
                  //   top: AppPading.extraSmall,
                  //   right: AppPading.extraSmall,
                  //   child: IconButton(
                  //     // TODO: Add correct URL
                  //     onPressed: () => _launchUrl(
                  //         "https://nutrisyncai-145173104.hubspotpagebuilder.eu/en-gb/?hs_preview=xpDlnACp-111471759307#about"),
                  //     icon: Icon(
                  //       Icons.open_in_new,
                  //       color: AppColors.primary,
                  //     ),
                  //   ),
                  // )
                ],
              ),
              const SizedBox(height: 20),
              AppBox(
                child: Padding(
                  padding: const EdgeInsets.all(AppPading.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(),
                      const AppTitle(title: "Animations"),
                      ListTile(
                        onTap: () =>
                            _launchUrl("https://lottiefiles.com/alymuhammad"),
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Muhammad Ali").h5(),
                        subtitle:
                            const Text("https://lottiefiles.com/alymuhammad")
                                .h5(),
                        trailing: const Icon(
                          Icons.open_in_new,
                          color: AppColors.primary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppPading.large),
                        child: Divider(
                          height: 0,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      ListTile(
                        onTap: () => _launchUrl("www.pierreblavette.com"),
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Pierre Blavette").h5(),
                        subtitle: const Text("www.pierreblavette.com").h5(),
                        trailing: const Icon(
                          Icons.open_in_new,
                          color: AppColors.primary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppPading.large),
                        child: Divider(
                          height: 0,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      ListTile(
                        onTap: () =>
                            _launchUrl("https://lottiefiles.com/kamaravichow"),
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Aravind Chowdary").h5(),
                        subtitle:
                            const Text("https://lottiefiles.com/kamaravichow")
                                .h5(),
                        trailing: const Icon(
                          Icons.open_in_new,
                          color: AppColors.primary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppPading.large),
                        child: Divider(
                          height: 0,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      ListTile(
                        onTap: () =>
                            _launchUrl("https://lottiefiles.com/lottiefiles_"),
                        contentPadding: EdgeInsets.zero,
                        title: const Text("LottieFiles Mobile").h5(),
                        subtitle:
                            const Text("https://lottiefiles.com/lottiefiles_")
                                .h5(),
                        trailing: const Icon(
                          Icons.open_in_new,
                          color: AppColors.primary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppPading.large),
                        child: Divider(
                          height: 0,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      ListTile(
                        onTap: () => _launchUrl(
                            "https://lottiefiles.com/devashishdeval"),
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Dev Ashish Deval").h5(),
                        subtitle:
                            const Text("https://lottiefiles.com/devashishdeval")
                                .h5(),
                        trailing: const Icon(
                          Icons.open_in_new,
                          color: AppColors.primary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppPading.large),
                        child: Divider(
                          height: 0,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      ListTile(
                        onTap: () =>
                            _launchUrl("https://lottiefiles.com/lottieicon"),
                        contentPadding: EdgeInsets.zero,
                        title: const Text("MD Abdur Rahim").h5(),
                        subtitle:
                            const Text("https://lottiefiles.com/lottieicon")
                                .h5(),
                        trailing: const Icon(
                          Icons.open_in_new,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
