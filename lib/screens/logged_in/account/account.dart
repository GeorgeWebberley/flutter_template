import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_details.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_friends.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_root.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/state/account_state.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:provider/provider.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> with SingleTickerProviderStateMixin {
  String currentScreen = 'root';

  void changeScreen(String screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    return StreamBuilder<UserData>(
        stream: UserService(uid: user?.uid).userDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (snapshot.hasData) {
            UserData? userData = snapshot.data;

            Map<String, Widget> screens = {
              'details': AccountDetails(user: userData!),
              'root': AccountRoot(user: userData),
              'friends': AccountFriends(user: userData),
              'settings': AccountDetails(user: userData),
            };

            return ChangeNotifierProvider<AccountState>(
              create: (_) => AccountState(),
              child:
                  Consumer<AccountState>(builder: (context, accountState, _) {
                return screens[accountState.currentScreen]!;
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
}
