import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/account/widgets/account_header.dart';
import 'package:flutter_firebase_template/state/account_state.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/detail_tile.dart';
import 'package:provider/provider.dart';

class AccountRoot extends StatelessWidget {
  const AccountRoot({Key? key, required this.user}) : super(key: key);

  final UserData user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccountHeader(userData: user),
        Expanded(
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(
                    AppPading.page,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppPading.large),
                        child: DetailTile(
                            title: 'Account details',
                            value: 'Edit your details',
                            onPressed: () {
                              Provider.of<AccountState>(context, listen: false)
                                  .setScreen('details');
                              // changeScreen('details');
                            },
                            icon: const Icon(
                              Icons.person_sharp,
                              color: AppColors.primary,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppPading.large),
                        child: DetailTile(
                            title: 'Friends',
                            value: 'Manage your friends',
                            onPressed: () {
                              Provider.of<AccountState>(context, listen: false)
                                  .setScreen('friends');
                            },
                            icon: const Icon(
                              Icons.people_alt,
                              color: AppColors.tertiary,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppPading.large),
                        child: DetailTile(
                            title: 'Settings',
                            value: 'Application settings',
                            onPressed: () {
                              Provider.of<AccountState>(context, listen: false)
                                  .setScreen('settings');
                            },
                            icon: const Icon(
                              Icons.settings,
                              color: AppColors.quaternary,
                            )),
                      ),
                    ],
                  ))),
        )
      ],
    );
  }
}
