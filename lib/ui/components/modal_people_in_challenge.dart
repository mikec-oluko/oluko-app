import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/done_challenge_users_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/user_utils.dart';

class ModalPeopleInChallenge extends StatefulWidget {
  String segmentId;
  String userId;
  ModalPeopleInChallenge({this.segmentId, this.userId});

  @override
  _ModalPeopleInChallengeState createState() => _ModalPeopleInChallengeState();
}

class _ModalPeopleInChallengeState extends State<ModalPeopleInChallenge> {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<DoneChallengeUsersBloc>(context).get(widget.segmentId, widget.userId);
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/courses/gray_background.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<DoneChallengeUsersBloc, DoneChallengeUsersState>(builder: (context, doneChallengeUsersState) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: TitleBody(OlukoLocalizations.get(context, 'favourites')),
                        ),
                      ],
                    ),
                  ),
                  if (doneChallengeUsersState is DoneChallengeUsersSuccess) usersGrid(doneChallengeUsersState.favoriteUsers) else const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        TitleBody(OlukoLocalizations.get(context, 'everyoneElse')),
                      ],
                    ),
                  ),
                  if (doneChallengeUsersState is DoneChallengeUsersSuccess) usersGrid(doneChallengeUsersState.users) else const SizedBox()
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget usersGrid(List<UserSubmodel> users) {
    if (users.isNotEmpty) {
      return ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: users
              .map((user) => Column(
                    children: [
                      StoriesItem(
                        maxRadius: 30,
                        imageUrl: user.avatarThumbnail ?? UserUtils().defaultAvatarImageUrl,
                        name: user.firstName,
                        lastname: user.lastName,
                      ),
                    ],
                  ))
              .toList());
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: TitleBody(OlukoLocalizations.get(context, 'noUsers')),
      );
    }
  }
}
