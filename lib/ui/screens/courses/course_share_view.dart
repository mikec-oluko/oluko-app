import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/users_list_component.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseShareView extends StatefulWidget {
  final UserResponse currentUser;
  const CourseShareView({this.currentUser}) : super();

  @override
  State<CourseShareView> createState() => _CourseShareViewState();
}

class _CourseShareViewState extends State<CourseShareView> {
  List<UserResponse> _friendUsersList = [];
  Map<String, UserProgress> _usersProgess = {};
  List<FriendModel> _friends = [];
  Widget usersWidget = SizedBox.shrink();
  @override
  void initState() {
    BlocProvider.of<UserProgressListBloc>(context).get();
    BlocProvider.of<FriendBloc>(context).getFriendsByUserId(widget.currentUser.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          // width: ScreenUtils.width(context),
          // height: ScreenUtils.height(context),
          color: OlukoNeumorphismColors.appBackgroundColor,
          child: ListView(children: [
            topAppBarBackButton(context),
            BlocConsumer<UserProgressListBloc, UserProgressListState>(
              listener: (context, userProgressListState) {
                if (userProgressListState is GetUserProgressSuccess) {
                  setState(() {
                    _usersProgess = userProgressListState.usersProgress;
                  });
                }
                // TODO: implement listener
              },
              builder: (context, state) {
                return BlocConsumer<UserProgressStreamBloc, UserProgressStreamState>(
                  listener: (context, userProgressStreamState) {},
                  builder: (context, userProgressStreamState) {
                    return BlocBuilder<FriendBloc, FriendState>(
                      builder: (context, friendState) {
                        if (userProgressStreamState is UserProgressUpdate) {
                          _usersProgess[userProgressStreamState.obj.id] = userProgressStreamState.obj;
                        } else if (userProgressStreamState is UserProgressAdd) {
                          _usersProgess[userProgressStreamState.obj.id] = userProgressStreamState.obj;
                        } else if (userProgressStreamState is UserProgressRemove) {
                          _usersProgess[userProgressStreamState.obj.id].progress = 0;
                        }
                        if (friendState is GetFriendsSuccess) {
                          _friendUsersList = friendState.friendUsers;
                          _friends = friendState.friendData != null ? friendState.friendData.friends : [];
                          usersWidget = UserListComponent(
                              usersProgess: _usersProgess,
                              authUser: widget.currentUser,
                              users: _filterFriendUsers(friends: _friends, friendUsersList: _friendUsersList),
                              onTapUser: (UserResponse friendUser) {},
                              onTopScroll: () {});
                        }
                        // return SizedBox();
                        return Container(
                            // color: Colors.red,
                            child: GridView.count(
                                padding: const EdgeInsets.only(top: 10),
                                childAspectRatio: 0.7,
                                crossAxisCount: 4,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                children: _filterFriendUsers(friends: _friends, friendUsersList: _friendUsersList)
                                    .map(
                                      (e) => Column(
                                        children: [
                                          StoriesItem(
                                            showUserProgress: true,
                                            userProgress: _usersProgess[e.id],
                                            progressValue: 0.5,
                                            maxRadius: 30,
                                            imageUrl: e.avatar,
                                            name: e.firstName,
                                            lastname: e.lastName,
                                            currentUserId: widget.currentUser.id,
                                            itemUserId: e.id,
                                            addUnseenStoriesRing: true,
                                            bloc: BlocProvider.of<StoryListBloc>(context),
                                            from: StoriesItemFrom.friends,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
                                            child: Text(
                                              '${e.firstName} ${e.lastName}',
                                              overflow: TextOverflow.ellipsis,
                                              style: OlukoFonts.olukoMediumFont(customColor: Colors.white),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                                            child: Text(
                                              UserHelper.printUsername(e.username, e.id) ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              style: OlukoFonts.olukoSmallFont(customColor: Colors.grey),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Container(width: 25, height: 25, color: Colors.red),
                                          )
                                        ],
                                      ),
                                    )
                                    .toList()));
                      },
                    );
                  },
                );
              },
            )
          ])),
    );
  }

  Container topAppBarBackButton(BuildContext context) {
    return Container(
      width: ScreenUtils.width(context),
      height: ScreenUtils.height(context) / 7,
      // color: Colors.red,
      child: Column(
        children: [
          Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    // color: Colors.blue,
                    width: 60,
                    height: 60,
                    child: Neumorphic(
                      style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: OlukoNeumorphismColors.finalGradientColorDark,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        height: 55,
                        width: 55,
                        child: Image.asset(
                          'assets/courses/left_back_arrow.png',
                          scale: 3.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: SizedBox()),
          OlukoNeumorphicDivider()
        ],
      ),
    );
  }

  List<UserResponse> _filterFriendUsers({List<FriendModel> friends, List<UserResponse> friendUsersList}) {
    List<UserResponse> _friendsUsers = [];

    friends.forEach((friend) {
      UserResponse friendUser = friendUsersList
          .where(
            (friendUser) => friendUser != null && friendUser?.id == friend.id,
          )
          .first;
      friendUser != null ? _friendsUsers.add(friendUser) : null;
    });
    return _friendsUsers;
  }
}
