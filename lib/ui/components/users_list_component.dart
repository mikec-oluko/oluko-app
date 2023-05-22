import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class UserListComponent extends StatefulWidget {
  final UserResponse authUser;
  final List<UserResponse> users;
  final Function(UserResponse friendUser) onTapUser;
  final Function() onTopScroll;
  final Map<String, UserProgress> usersProgress;

  const UserListComponent({@required this.authUser, @required this.users, @required this.onTapUser, this.usersProgress, this.onTopScroll}) : super();

  @override
  State<UserListComponent> createState() => _UserListComponentState();
}

class _UserListComponentState extends State<UserListComponent> {
  List<UserResponse> _growingUserList = [];
  final _listController = ScrollController();
  final int _batchMaxRange = 50;

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _growingUserList =
        widget.users.isNotEmpty ? [...widget.users.getRange(0, widget.users.length > _batchMaxRange ? _batchMaxRange : widget.users.length)] : [];
    _listController.addListener(() {
      if (_listController.position.atEdge) {
        if (_listController.position.pixels > 0) {
          if (_growingUserList.length != widget.users.length) {
            _getMoreUsers();
            setState(() {});
          }
        }
        if (_listController.position.pixels == 0) {
          widget.onTopScroll();
        }
      }
    });
    super.initState();
  }

  void _getMoreUsers() => _growingUserList = widget.users.isNotEmpty
      ? [
          ...widget.users
              .getRange(0, widget.users.length > _growingUserList.length + _batchMaxRange ? _growingUserList.length + _batchMaxRange : widget.users.length)
        ]
      : [];

  @override
  Widget build(BuildContext context) {
    return widget.users.isEmpty ? _noUsersMessage(context) : _userListWidget(context);
  }

  Padding _noUsersMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          OlukoLocalizations.get(context, 'noUsers'),
          style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400, customColor: OlukoColors.grayColor),
        )
      ]),
    );
  }

  Widget _userListWidget(BuildContext context) {
    return GridView.count(
      controller: _listController,
      padding: const EdgeInsets.only(top: 10),
      childAspectRatio: 0.7,
      crossAxisCount: 4,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      children: _growingUserList
          .map(
            (friendElement) => GestureDetector(
              onTap: () => widget.onTapUser(friendElement),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StoriesItem(
                    showUserProgress: true,
                    userProgress: widget.usersProgress?.isNotEmpty ? widget.usersProgress[friendElement.id]: null,
                    progressValue: 0.5,
                    maxRadius: 30,
                    imageUrl: friendElement.getAvatarThumbnail(),
                    name: friendElement.firstName,
                    lastname: friendElement.lastName,
                    currentUserId: widget.authUser.id,
                    itemUserId: friendElement.id,
                    addUnseenStoriesRing: true,
                    bloc: BlocProvider.of<StoryListBloc>(context),
                    from: StoriesItemFrom.friends,
                  ),
                  _printName(friendElement, _isCurrentUser(friendElement)),
                  _printUsername(friendElement)
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  bool _isCurrentUser(UserResponse friendElement) => widget.authUser.id == friendElement.id;

  Widget _printUsername(UserResponse friendUser) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Text(
        UserHelper.printUsername(friendUser.username, friendUser.id) ?? '',
        overflow: TextOverflow.ellipsis,
        style: OlukoFonts.olukoSmallFont(customColor: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Padding _printName(UserResponse user, bool isCurrentUser) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
      child: Text(
        user.getFullName(showFullName: isCurrentUser),
        overflow: TextOverflow.ellipsis,
        style: OlukoFonts.olukoMediumFont(customColor: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
