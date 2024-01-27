import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/user_profile.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/enums.dart';
import 'package:flutter_firebase_template/state/account_state.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/app_search_bar.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/user_tile.dart';
import 'package:provider/provider.dart';

// TODO: Name validation (e.g. length, spaces etc.)
// TODO: Slogan validation (e.g. length)
// TODO: Redo design of tiles so that it matches kia's design
class AccountFriends extends StatefulWidget {
  const AccountFriends({Key? key, required this.user}) : super(key: key);

  final UserData user;

  @override
  State<AccountFriends> createState() => _AccountFriendsState();
}

class _AccountFriendsState extends State<AccountFriends>
    with TickerProviderStateMixin {
  String search = '';
  List<UserData>? filteredUsers;

  @override
  Widget build(BuildContext context) {
    UserService userService = UserService(uid: widget.user.uid);

    return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // The top tabs and navigation
            Container(
              color: AppColors.quaternary,
              padding: const EdgeInsets.symmetric(horizontal: AppPading.page),
              child: Column(
                children: [
                  // Back arrow and add friend icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Provider.of<AccountState>(context, listen: false)
                              .setScreen('root');
                        },
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppPading.small),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _openAddFriendDialog();
                        },
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppPading.small),
                          child: Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppPading.medium,
                  ),
                  // tabs
                  const TabBar(
                      unselectedLabelColor: Colors.white,
                      indicator: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20)),
                      ),
                      tabs: [
                        Tab(
                          text: 'Current Friends',
                        ),
                        Tab(
                          text: 'Pending Requests',
                        )
                      ]),
                ],
              ),
            ),
            // The Search bar and list of friends
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPading.page,
                ),
                child: TabBarView(children: [
                  SingleChildScrollView(
                    child: widget.user.friends == null ||
                            widget.user.friends!.isEmpty
                        ? _noFriends("Let's find your first friend :)")
                        : StreamBuilder<List<UserData>>(
                            stream: userService.getMultipleUsersByIdStream(
                                widget.user.friends!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<UserData> friendsToDisplay =
                                    filteredUsers ??
                                        snapshot.data as List<UserData>;

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: AppPading.page,
                                          bottom: AppPading.large),
                                      child: AppSearchBar(onChanged: (value) {
                                        _filterFriends(value,
                                            snapshot.data as List<UserData>);
                                      }),
                                    ),
                                    for (var friend in friendsToDisplay)
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: AppPading.large),
                                          child: UserTile(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserProfile(
                                                          friendId: friend.uid,
                                                          currentUser:
                                                              widget.user,
                                                        )),
                                              );
                                            },
                                            user: friend,
                                          )),
                                  ],
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.secondary,
                                  ),
                                );
                              }
                            }),
                  ),
                  SingleChildScrollView(
                    child: widget.user.friendRequests == null ||
                            widget.user.friendRequests!.isEmpty
                        ? _noFriends('No pending requests')
                        : StreamBuilder<List<UserData>>(
                            stream: userService.getMultipleUsersByIdStream(
                                widget.user.friendRequests!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                // Use snapshot.data unless the user has searched/filtered
                                List<UserData> friendsToDisplay =
                                    snapshot.data as List<UserData>;
                                return Column(
                                  children: [
                                    const SizedBox(
                                      height: AppPading.page,
                                    ),
                                    // TODO: This should instead loop through pending requests
                                    for (var friend in friendsToDisplay)
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: AppPading.large),
                                          child: UserTile(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserProfile(
                                                            friendId:
                                                                friend.uid,
                                                            currentUser:
                                                                widget.user)),
                                              );
                                            },
                                            user: friend,
                                            friendStatus:
                                                FriendStatus.requestSent,
                                          )),
                                  ],
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.secondary,
                                  ),
                                );
                              }
                            }),
                  ),
                ]),
              ),
            ),
          ],
        ));
  }

  _filterFriends(String? value, List<UserData> allFriends) {
    if (value == null || value == '') {
      setState(() {
        filteredUsers = null;
      });
    } else {
      setState(() {
        filteredUsers = allFriends
            .where((friend) =>
                // If null, then convert to false.
                // Else, do a case insensitive 'contains'
                (friend.firstName
                        ?.toLowerCase()
                        .contains(value.toLowerCase()) ??
                    false) ||
                (friend.lastName?.toLowerCase().contains(value.toLowerCase()) ??
                    false) ||
                friend.username!.toLowerCase().contains(value.toLowerCase()))
            .toList();
      });
    }
  }

  _openAddFriendDialog() {
    String _username = '';
    String error = '';

    final _formKey = GlobalKey<FormState>();
    bool loading = false;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Search for a friend"),
        // Use a StatefulBuilder so that we are able to call 'setState' inside the dialog, allowing us to update the UI as the user updates the value in the slider
        content: StatefulBuilder(builder: (stateContext, setState) {
          return SizedBox(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppPading.large),
                    child: TextFormField(
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Enter username'),
                      validator: (value) =>
                          value!.isEmpty ? 'Cannot be empty' : null,
                      onChanged: (value) {
                        setState(() {
                          _username = value;
                        });
                      },
                    ),
                  ),
                  AppButton(
                    text: 'Search',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });

                        UserData? friend =
                            await UserService(uid: widget.user.uid)
                                .findUserByUsername(_username);

                        if (friend != null) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserProfile(
                                      friendId: friend.uid,
                                      currentUser: widget.user,
                                    )),
                          );
                        } else {
                          setState(() {
                            error = 'No friend found with that username';
                          });
                          setState(() {
                            loading = false;
                          });
                        }
                      } else {
                        setState(() {
                          loading = false;
                        });
                      }
                    },
                    loading: loading,
                    color: AppColors.secondary,
                    size: ButtonSize.medium,
                  ),
                  const SizedBox(
                    height: AppPading.small,
                  ),
                  Text(
                    error,
                    style: const TextStyle(
                        color: AppColors.danger, fontWeight: FontWeight.w600),
                  ).h5()
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _noFriends(String message) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppPading.page),
          child: Text(
            message,
            style: const TextStyle(
                color: AppColors.quaternary, fontWeight: FontWeight.w400),
          ).h3(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPading.large),
          child: AppButton(
            onPressed: () {
              _openAddFriendDialog();
            },
            text: 'Search',
            size: ButtonSize.medium,
            color: AppColors.secondary,
          ),
        )
      ],
    );
  }
}
