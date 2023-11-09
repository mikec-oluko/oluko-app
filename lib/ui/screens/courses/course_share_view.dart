import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/course/course_user_interaction_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/story_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseShareView extends StatefulWidget {
  final UserResponse currentUser;
  final Course courseToShare;
  const CourseShareView({this.currentUser, this.courseToShare}) : super();

  @override
  State<CourseShareView> createState() => _CourseShareViewState();
}

class _CourseShareViewState extends State<CourseShareView> {
  List<UserResponse> _friendUsersList = [];
  List<UserResponse> userSelectedList = [];
  Map<String, UserProgress> _usersProgress = {};
  List<FriendModel> _friends = [];
  Widget usersWidget = const SizedBox.shrink();
  bool isSelected = true;
  @override
  void initState() {
    BlocProvider.of<UserProgressListBloc>(context).get(widget.currentUser.id);
    BlocProvider.of<FriendBloc>(context).getFriendsByUserId(widget.currentUser.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          color: OlukoNeumorphismColors.appBackgroundColor,
          child: ListView(physics: OlukoNeumorphism.listViewPhysicsEffect, addAutomaticKeepAlives: false, addRepaintBoundaries: false, children: [
            topAppBarBackButton(context),
            BlocConsumer<UserProgressListBloc, UserProgressListState>(
              listener: (context, userProgressListState) {
                if (userProgressListState is GetUserProgressSuccess) {
                  setState(() {
                    _usersProgress = userProgressListState.usersProgress;
                  });
                }
              },
              builder: (context, state) {
                return BlocConsumer<UserProgressStreamBloc, UserProgressStreamState>(
                  listener: (context, userProgressStreamState) {},
                  builder: (context, userProgressStreamState) {
                    return BlocBuilder<FriendBloc, FriendState>(
                      builder: (context, friendState) {
                        if (userProgressStreamState is UserProgressUpdate) {
                          _usersProgress[userProgressStreamState.obj.id] = userProgressStreamState.obj;
                        } else if (userProgressStreamState is UserProgressAdd) {
                          _usersProgress[userProgressStreamState.obj.id] = userProgressStreamState.obj;
                        } else if (userProgressStreamState is UserProgressRemove) {
                          _usersProgress[userProgressStreamState.obj.id]?.progress = 0;
                        }
                        if (friendState is GetFriendsSuccess) {
                          _friendUsersList = friendState.friendUsers;
                          _friends = friendState.friendData != null ? friendState.friendData.friends : [];
                        }
                        return Container(
                            child: Column(
                          children: [
                            Container(
                              height: 50,
                              color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      OlukoLocalizations.get(context, 'sendFriendRecommendation'),
                                      textAlign: TextAlign.start,
                                      style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.primary),
                                    ),
                                    IgnorePointer(
                                      ignoring: userSelectedList.isEmpty,
                                      child: Container(
                                          width: 50,
                                          height: 50,
                                          child: IconButton(
                                              onPressed: () async {
                                                if (userSelectedList.isNotEmpty) {
                                                  await BlocProvider.of<CourseUserInteractionBloc>(context).recommendCourseToFriends(
                                                    originUserId: widget.currentUser.id,
                                                    courseRecommendedId: widget.courseToShare.id,
                                                    usersRecommended: userSelectedList,
                                                  );
                                                }
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(
                                                Icons.send_rounded,
                                                color: userSelectedList.isEmpty ? OlukoNeumorphismColors.finalGradientColorDark : OlukoColors.primary,
                                              ))),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            _listOfUsers(contextToUse: context, favorite: true),
                            _listOfUsers(contextToUse: context),
                          ],
                        ));
                      },
                    );
                  },
                );
              },
            )
          ])),
    );
  }

  Column _listOfUsers({BuildContext contextToUse, bool favorite = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          child: Text(
            favorite ? OlukoLocalizations.get(context, 'favorites') : OlukoLocalizations.get(context, 'friends'),
            textAlign: TextAlign.start,
            style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500),
          ),
        ),
        GridView.count(
            padding: const EdgeInsets.only(top: 10),
            childAspectRatio: 0.6,
            crossAxisCount: 4,
            physics: OlukoNeumorphism.listViewPhysicsEffect,
            shrinkWrap: true,
            children: _getFriendList(favoriteUsers: favorite, friends: _friends, friendUsersList: _friendUsersList)
                .map(
                  (friendUserElement) => GestureDetector(
                    onTap: () {
                      setState(() {
                        if (userSelectedList.contains(friendUserElement)) {
                          userSelectedList.remove(friendUserElement);
                        } else {
                          userSelectedList.add(friendUserElement);
                        }
                      });
                    },
                    child: Column(
                      children: [
                        StoriesItem(
                          showUserProgress: true,
                          userProgress: _usersProgress[friendUserElement.id],
                          progressValue: 0.5,
                          maxRadius: 30,
                          imageUrl: friendUserElement.getAvatarThumbnail(),
                          name: friendUserElement.firstName,
                          lastname: friendUserElement.lastName,
                          currentUserId: widget.currentUser.id,
                          itemUserId: friendUserElement.id,
                          addUnseenStoriesRing: true,
                          bloc: BlocProvider.of<StoryListBloc>(context),
                          from: StoriesItemFrom.friends,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                          child: Text(
                            friendUserElement.getFullName(),
                            overflow: TextOverflow.ellipsis,
                            style: OlukoFonts.olukoMediumFont(customColor: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                          child: Text(
                            UserHelper.printUsername(friendUserElement.username, friendUserElement.id) ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: OlukoFonts.olukoSmallFont(customColor: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            width: 25,
                            height: 25,
                            child: userSelectedList.contains(friendUserElement)
                                ? Stack(alignment: Alignment.center, children: [
                                    Image.asset(
                                      'assets/assessment/green_ellipse.png',
                                      scale: 4,
                                    ),
                                    Image.asset(
                                      'assets/assessment/gray_check.png',
                                      scale: 10,
                                    )
                                  ])
                                : Image.asset(
                                    'assets/courses/grey_circle.png',
                                    scale: 4,
                                    color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLight,
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
                .toList()),
      ],
    );
  }

  Container topAppBarBackButton(BuildContext context) {
    return Container(
      width: ScreenUtils.width(context),
      height: ScreenUtils.height(context) / 7,
      child: Column(
        children: [
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
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
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),
          const OlukoNeumorphicDivider()
        ],
      ),
    );
  }

  List<UserResponse> _getFriendList({bool favoriteUsers = false, List<FriendModel> friends, List<UserResponse> friendUsersList}) {
    List<UserResponse> _friendsUsers = [];
    List<UserResponse> _favoriteFriendUsers = [];

    friends.forEach((friend) {
      UserResponse friendUser = friendUsersList
          .where(
            (friendUser) => friendUser != null && friendUser?.id == friend.id,
          )
          .first;
      friendUser != null
          ? friend.isFavorite
              ? _favoriteFriendUsers.add(friendUser)
              : _friendsUsers.add(friendUser)
          : null;
    });
    return favoriteUsers ? _favoriteFriendUsers : _friendsUsers;
  }
}
