import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_root.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_settings.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/state/account_state.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:provider/provider.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> with SingleTickerProviderStateMixin {
  String currentScreen = 'root';
  Widget secondScreen = Container();
  PageController pageController = PageController();
  int pageViewIndex = 0;

  // void changeScreen(String screen) {
  //   setState(() {
  //     currentScreen = screen;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    return StreamBuilder<UserData>(
        stream: UserService(uid: user?.uid).userDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (snapshot.hasData) {
            UserData? userData = snapshot.data;

            AccountSettings(
              user: userData!,
              backToRoot: backToRoot,
            );

            List<Widget> screens = [
              AccountRoot(
                user: userData,
                setScreen: setScreen,
                backToRoot: backToRoot,
              ),
              secondScreen
            ];

            return ChangeNotifierProvider<AccountState>(
              create: (_) => AccountState(),
              child:
                  Consumer<AccountState>(builder: (context, accountState, _) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: pageViewIndex == 1
                        ? IconButton(
                            onPressed: backToRoot,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                          )
                        : null,
                  ),
                  body: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppPading.page,
                        0,
                        AppPading.page,
                        AppPading.page,
                      ),
                      child: PageView(
                        controller: pageController,
                        children: screens,
                      )),
                );
              }),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.secondary,
              ),
            );
          }
        });
  }

  void setScreen(Widget screen) async {
    setState(() {
      secondScreen = screen;
      pageViewIndex = 1;
    });
    await pageController.animateToPage(1,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  backToRoot() async {
    await pageController.animateToPage(0,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
    setState(() {
      pageViewIndex = 0;
    });
  }
}
