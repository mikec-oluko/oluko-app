import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class UserListComponent extends StatefulWidget {
  final AuthSuccess authUser;
  final List<UserResponse> users;
  final Function(UserResponse friendUser) onTapUser;
  final Function() onTopScroll;
  const UserListComponent({@required this.authUser, @required this.users, @required this.onTapUser, this.onTopScroll}) : super();

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
    _growingUserList = widget.users.isNotEmpty
        ? [...widget.users.getRange(0, widget.users.length > _batchMaxRange ? _batchMaxRange : widget.users.length)]
        : [];
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
          ...widget.users.getRange(
              0,
              widget.users.length > _growingUserList.length + _batchMaxRange
                  ? _growingUserList.length + _batchMaxRange
                  : widget.users.length)
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
        SizedBox(
            width: ScreenUtils.width(context) * 0.85,
            child: Text(
              OlukoLocalizations.get(context, 'noUsers'),
              textAlign: TextAlign.start,
              style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w400),
            ))
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
                    maxRadius: 30,
                    imageUrl: friendElement.avatarThumbnail,
                    name: friendElement.firstName,
                    lastname: friendElement.lastName,
                    currentUserId: widget.authUser.user.id,
                    itemUserId: friendElement.id,
                    addUnseenStoriesRing: true,
                    bloc: StoryListBloc(),
                    from: StoriesItemFrom.friends,
                  ),
                  _printName(friendElement),
                  _printUsername(friendElement)
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Text _printUsername(UserResponse friendUser) {
    return Text(
      UserHelper.printUsername(friendUser.username, friendUser.id) ?? '',
      overflow: TextOverflow.ellipsis,
      style: OlukoFonts.olukoSmallFont(customColor: Colors.grey),
      textAlign: TextAlign.center,
    );
  }

  Padding _printName(UserResponse user) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        '${user.firstName} ${user.lastName}',
        overflow: TextOverflow.ellipsis,
        style: OlukoFonts.olukoMediumFont(customColor: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
