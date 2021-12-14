import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/dto/story_dto.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/user_utils.dart';

class ModalPeopleEnrolled extends StatefulWidget {
  String userId;
  List<dynamic> users;
  List<dynamic> favorites;
  ModalPeopleEnrolled({this.userId, this.users, this.favorites});

  @override
  _ModalPeopleEnrolledState createState() => _ModalPeopleEnrolledState();
}

class _ModalPeopleEnrolledState extends State<ModalPeopleEnrolled> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/courses/gray_background.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      width: MediaQuery.of(context).size.width,
      height: 150,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: TitleBody(OlukoLocalizations.get(context, 'favourites')),
                  ),
                ],
              ),
              usersGrid(widget.favorites),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: TitleBody(OlukoLocalizations.get(context, 'everyoneElse')),
                  ),
                ],
              ),
              usersGrid(widget.users)
            ],
          )),
    );
  }

  Widget usersGrid(List<dynamic> users) {
    if (users != null && users.isNotEmpty) {
      return GridView.count(
          childAspectRatio: 0.7,
          crossAxisCount: 4,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: users
              .map((user) => GridTile(
                    child: Column(
                      children: [
                        StoriesItem(
                          itemUserId: user.id?.toString() ?? '',
                          name: user.username?.toString() ?? user.firstName?.toString() ?? '',
                          currentUserId: widget.userId,
                          maxRadius: 35,
                          imageUrl: user.avatarThumbnail?.toString() ?? UserUtils().defaultAvatarImageUrl,
                          stories: user is UserSubmodel && user.stories?.stories != null ? user.stories.stories : [],
                        ),
                        Text('${user.firstName ?? ''} ${user.lastName ?? ''}',
                            textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: OlukoFonts.olukoMediumFont()),
                        const SizedBox(height: 1),
                        Text(user.username?.toString() ?? '',
                            style: const TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
                      ],
                    ),
                  ))
              .toList());
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: TitleBody(OlukoLocalizations.get(context, 'noUsers')),
        ),
      );
    }
  }
}