import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/hi_five_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class HiFivePage extends StatefulWidget {
  const HiFivePage({Key key}) : super(key: key);

  @override
  _HiFivePageState createState() => _HiFivePageState();
}

class _HiFivePageState extends State<HiFivePage> {
  HiFiveSuccess _hiFiveState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: Colors.black,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccess) {
            if (_hiFiveState == null) {
              BlocProvider.of<HiFiveBloc>(context).get(authState.user.id);
            }
            return BlocBuilder<HiFiveBloc, HiFiveState>(builder: (context, hiFiveState) {
              if (hiFiveState is HiFiveSuccess) {
                _hiFiveState = hiFiveState;
                return ListView(
                  children: hiFiveState.users
                      .map(
                        (targetUser) => _listItem(
                          authState.user,
                          targetUser,
                          hiFiveState.chat.values.toList()[hiFiveState.users.indexOf(targetUser)].length,
                        ),
                      )
                      .toList(),
                );
              } else {
                return SizedBox();
              }
            });
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _listItem(UserResponse user, UserResponse targetUser, num hiFives) {
    return Dismissible(
      key: ValueKey<String>(targetUser.id),
      onDismissed: (DismissDirection dismissDirection) {
        if (dismissDirection == DismissDirection.startToEnd) {
          BlocProvider.of<HiFiveBloc>(context).sendHiFive(user.id, targetUser.id);
        } else {
          BlocProvider.of<HiFiveBloc>(context).ignoreHiFive(user.id, targetUser.id);
        }
      },
      background: Container(color: OlukoColors.primary),
      secondaryBackground: Container(
        color: Colors.red.shade100,
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    StoriesItem(
                      progressValue: 0.6,
                      imageUrl: targetUser.avatar,
                      maxRadius: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              targetUser.firstName,
                              style: const TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              targetUser.username,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Flexible(
              flex: 5,
              child: Column(
                children: [
                  Text(
                    '$hiFives Hi-Fives',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () => BlocProvider.of<HiFiveBloc>(context).sendHiFive(user.id, targetUser.id),
              child: Image.asset(
                'assets/profile/hiFive.png',
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.lighten,
                height: 60,
                width: 60,
              ),
            )
          ],
        ),
      ),
    );
  }

  OlukoAppBar _appBar() {
    return OlukoAppBar(
      title: 'Hi Five',
      showLogo: false,
      showBackButton: true,
      actions: [],
    );
  }
}
