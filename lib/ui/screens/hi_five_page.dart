import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/hi_five_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class HiFivePage extends StatefulWidget {
  const HiFivePage({Key key}) : super(key: key);

  @override
  _HiFivePageState createState() => _HiFivePageState();
}

class _HiFivePageState extends State<HiFivePage> {
  HiFiveSuccess _hiFiveState;
  AuthSuccess _authState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: Colors.black,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthSuccess) {
            _authState = authState;
            if (_hiFiveState == null) {
              BlocProvider.of<HiFiveBloc>(context).get(authState.user.id);
            }
            return BlocListener<HiFiveBloc, HiFiveState>(
              listener: (context, hiFiveState) {
                if (hiFiveState is HiFiveSuccess && hiFiveState.alertMessage != null) {
                  AppMessages.clearAndShowSnackbar(context, hiFiveState.alertMessage);
                }
              },
              child: BlocBuilder<HiFiveBloc, HiFiveState>(builder: (context, hiFiveState) {
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
              }),
            );
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
          BlocProvider.of<HiFiveBloc>(context).sendHiFive(context, user.id, targetUser.id);
        } else {
          BlocProvider.of<HiFiveBloc>(context).ignoreHiFive(context, user.id, targetUser.id);
        }
      },
      background: Container(
        color: OlukoColors.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Image.asset(
                'assets/profile/hiFive_white.png',
                scale: 0.3,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                OlukoLocalizations.get(context, 'remove').toUpperCase(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                StoriesItem(
                  progressValue: 0.6,
                  imageUrl: targetUser.avatar,
                  name: targetUser.firstName,
                  lastname: targetUser.lastName,
                  maxRadius: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        targetUser.firstName,
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        UserHelper.printUsername(targetUser.username, targetUser.id),
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hiFives > 1)
              Text(
                '$hiFives ${OlukoLocalizations.get(context, 'hiFives')}',
                style: TextStyle(color: Colors.grey),
              )
            else
              const SizedBox(),
            GestureDetector(
              onTap: () => BlocProvider.of<HiFiveBloc>(context).sendHiFive(context, user.id, targetUser.id),
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
      showTitle: OlukoNeumorphism.isNeumorphismDesign,
      showActions: OlukoNeumorphism.isNeumorphismDesign,
      actions: [
        Visibility(
          visible: _hiFiveState != null && _hiFiveState.users.length > 1,
          child: GestureDetector(
            onTap: () {
              BlocProvider.of<HiFiveBloc>(context)
                  .sendHiFiveToAll(context, _authState.user.id, _hiFiveState.users.map((e) => e.id).toList());
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/profile/hiFive.png',
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.lighten,
                      height: 40,
                      width: 40,
                    ),
                    const Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Text(
                        'Hi Five all',
                        style: TextStyle(color: OlukoColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
