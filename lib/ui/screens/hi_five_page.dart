import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/carrousel_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/views_bloc/hi_five_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
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
  Map<String, UserProgress> _usersProgress = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          _authState = authState;
          BlocProvider.of<UserProgressListBloc>(context).get(_authState.user.id);
          if (_hiFiveState == null) {
            BlocProvider.of<HiFiveBloc>(context).get(authState.user.id);
          }
          return BlocConsumer<HiFiveBloc, HiFiveState>(
            builder: (context, hiFiveState) {
              if (hiFiveState is HiFiveSuccess && hiFiveState.users != null && hiFiveState.users.isNotEmpty) {
                BlocProvider.of<CarouselBloc>(context).widgetIsHiden(false);
                hiFiveState.users.removeWhere((user) => user == null || user.id == null);
                return Scaffold(
                  appBar: _appBar(hiFiveState),
                  backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                  body: BlocConsumer<UserProgressListBloc, UserProgressListState>(
                      listener: (context, userProgressListState) {},
                      builder: (context, userProgressListState) {
                        if (userProgressListState is GetUserProgressSuccess) {
                          _usersProgress = userProgressListState.usersProgress;
                        }
                        return Container(
                          color: OlukoNeumorphismColors.appBackgroundColor,
                          child: ListView(
                            physics: OlukoNeumorphism.listViewPhysicsEffect,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: false,
                            children: hiFiveState.users
                                .map(
                                  (targetUser) => _listItem(
                                    authState.user,
                                    targetUser,
                                    hiFiveState.chat.values.toList()[hiFiveState.users.indexOf(targetUser)].length,
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      }),
                );
              } else {
                BlocProvider.of<CarouselBloc>(context).widgetIsHiden(false);
                return const SizedBox();
              }
            },
            listener: (context, hiFiveState) {
              if (hiFiveState is HiFiveSuccess) {
                if (hiFiveState.alertMessage != null) {
                  AppMessages.clearAndShowSnackbar(context, hiFiveState.alertMessage);
                }
                if (hiFiveState.users == null || hiFiveState.users.isEmpty) {
                  Navigator.pop(context);
                }
              }
            },
          );
        } else {
          return const SizedBox();
        }
      },
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StoriesItem(
                  showUserProgress: true,
                  userProgress: _usersProgress[targetUser.id],
                  itemUserId: targetUser.id,
                  imageUrl: targetUser.getAvatarThumbnail(),
                  name: targetUser.firstName,
                  lastname: targetUser.lastName,
                  maxRadius: 30,
                  userProgressStreamBloc: BlocProvider.of<UserProgressStreamBloc>(context),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          targetUser.firstName,
                          overflow: TextOverflow.ellipsis,
                          style: OlukoFonts.olukoSuperBigFont(),
                        ),
                        Text(
                          UserHelper.printUsername(targetUser.username, targetUser.id),
                          overflow: TextOverflow.ellipsis,
                          style: OlukoFonts.olukoMediumFont(),
                        ),
                      ],
                    ),
                  ),
                ),
                if (hiFives > 1)
                  Text(
                    '$hiFives ${OlukoLocalizations.get(context, 'hiFives')}',
                    style: OlukoFonts.olukoMediumFont(customColor: Colors.grey),
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
            const OlukoNeumorphicDivider(
              isForList: true,
              isFadeOut: true,
            )
          ],
        ),
      ),
    );
  }

  OlukoAppBar _appBar(HiFiveSuccess hiFiveState) {
    return OlukoAppBar(
      title: OlukoLocalizations.get(context, 'hiFive'),
      showBackButton: true,
      showTitle: OlukoNeumorphism.isNeumorphismDesign,
      showActions: true,
      actions: [
        Visibility(
          visible: hiFiveState != null && hiFiveState.users.length > 1,
          child: GestureDetector(
            onTap: () {
              BlocProvider.of<HiFiveBloc>(context).sendHiFiveToAll(context, _authState.user.id, hiFiveState);
            },
            child: OlukoNeumorphism.isNeumorphismDesign
                ? Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Text(
                      OlukoLocalizations.get(context, 'hiFiveAll'),
                      style: TextStyle(color: OlukoColors.primary),
                    ),
                  )
                : Column(
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
                          Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Text(
                              OlukoLocalizations.get(context, 'hiFiveAll'),
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
