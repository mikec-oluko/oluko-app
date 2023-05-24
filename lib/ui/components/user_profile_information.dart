import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_avatar_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/stories_item.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/upload_profile_media_menu.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class UserProfileInformation extends StatefulWidget {
  final UserResponse userToDisplayInformation;
  final ActualProfileRoute actualRoute;
  final UserResponse currentUser;
  final UserConnectStatus connectStatus;
  final UserStatistics userStats;
  final bool minimalRequested;
  final Success galleryState;
  final bool isLoadingState;
  const UserProfileInformation(
      {this.userToDisplayInformation,
      this.actualRoute,
      this.currentUser,
      this.connectStatus,
      this.userStats,
      this.minimalRequested = false,
      this.isLoadingState = false,
      this.galleryState})
      : super();

  @override
  _UserProfileInformationState createState() => _UserProfileInformationState();
}

class _UserProfileInformationState extends State<UserProfileInformation> {
  String _userLocation;
  bool _isOwner = false;
  final String _archivementsDefaultValue = '0';
  PrivacyOptions _privacyOptions = PrivacyOptions();
  HiFiveReceivedSuccess _hiFiveReceivedState;
  AuthSuccess _authState;
  Map<String, UserProgress> _usersProgress = {};

  @override
  void initState() {
    BlocProvider.of<UserProgressListBloc>(context).get(widget.currentUser.id);
    _isOwner = _isOwnerProfile(currentUser: widget.currentUser, userRequested: widget.userToDisplayInformation);
    super.initState();
  }

  bool _isOwnerProfile({@required UserResponse currentUser, @required UserResponse userRequested}) {
    return currentUser.id == userRequested.id;
  }

  @override
  Widget build(BuildContext context) {
    _userLocation = getUserLocation(widget.userToDisplayInformation);
    final List<String> _valuesDemo = ['07', '10', '50'];

    return BlocListener<HiFiveReceivedBloc, HiFiveReceivedState>(
      listener: (BuildContext context, HiFiveReceivedState state) {
        if (state is HiFiveReceivedSuccess) {
          setState(() {
            _hiFiveReceivedState = state;
          });
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        if (_hiFiveReceivedState == null && authState is AuthSuccess) {
          _authState = authState;
          BlocProvider.of<HiFiveReceivedBloc>(context).get(context, authState.user.id, widget.userToDisplayInformation.id);
        }
        return WillPopScope(
          onWillPop: () async {
            BlocProvider.of<ProfileAvatarBloc>(context).emitDefaultState();
            return true;
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10, vertical: OlukoNeumorphism.isNeumorphismDesign ? 10 : 5),
            //TODO: Check if need neumorphic outside
            child: Container(
              decoration: UserInformationBackground.getContainerGradientDecoration(isNeumorphic: OlukoNeumorphism.isNeumorphismDesign),
              width: MediaQuery.of(context).size.width,
              height: widget.minimalRequested
                  ? 160
                  : OlukoNeumorphism.isNeumorphismDesign
                      ? MediaQuery.of(context).size.height < 700
                          ? MediaQuery.of(context).size.height / 2.7
                          : MediaQuery.of(context).size.height / 3.1
                      : null,
              child: Padding(
                  padding: const EdgeInsets.all(OlukoNeumorphism.isNeumorphismDesign ? 10 : 10),
                  child: OlukoNeumorphism.isNeumorphismDesign
                      ? _profileUserNeumorphicInformation(_userLocation, _valuesDemo)
                      : _profileUserInformation(_userLocation, _valuesDemo)),
            ),
          ),
        );
      }),
    );
  }

  String getUserLocation(UserResponse user) {
    String ret = '';
    final String stateAndCountry = ' ${user.state ?? ''} ${user.country ?? ''}';
    if (user.city != null && user.city.isNotEmpty) {
      ret += ' ${user.city[0].toUpperCase()}${user.city.substring(1).toLowerCase()},$stateAndCountry';
    } else {
      ret += stateAndCountry;
    }
    return ret;
  }

  Widget _profileUserNeumorphicInformation(String location, List<String> valuesForArchivements) {
    final bool canShowDetails = _privacyOptions.canShowDetails(
        isOwner: _isOwner, currentUser: widget.currentUser, userRequested: widget.userToDisplayInformation, connectStatus: widget.connectStatus);

    return BlocConsumer<UserProgressListBloc, UserProgressListState>(listener: (context, userProgressListState) {
      if (userProgressListState is GetUserProgressSuccess) {
        setState(() {
          _usersProgress = userProgressListState.usersProgress;
        });
      }
    }, builder: (context, userProgressListState) {
      return Column(
        children: [
          //PROFILE IMAGE AND INFO
          // Column(
          // children: [
          //USER CIRCLEAVATAR
          Row(
            children: [
              Stack(children: [
                StoriesItem(
                  showUserProgress: true,
                  userProgress: _usersProgress[widget.userToDisplayInformation.id],
                  itemUserId: widget.userToDisplayInformation.id,
                  maxRadius: 40,
                  imageUrl: widget.userToDisplayInformation.getAvatarThumbnail(),
                  name: widget.userToDisplayInformation.firstName,
                  lastname: widget.userToDisplayInformation.lastName,
                  userProgressStreamBloc: BlocProvider.of<UserProgressStreamBloc>(context),
                  isLoadingState: widget.isLoadingState,
                ),
                uploadContentComponent(widget, context, _isOwner),
              ]),
              /*if (widget.userToDisplayInformation.avatar != null)
                  /*Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: */
                  Stack(clipBehavior: Clip.none, children: [
                    /*Neumorphic(
                          style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
                          child:*/ /*CircleAvatar(
                          backgroundColor: OlukoColors.black,
                          radius: 40.0,
                        ),*/
                    StoriesItem(
                      maxRadius: 40,
                      imageUrl: widget.userToDisplayInformation.avatar,
                      name: widget.userToDisplayInformation.firstName,
                      lastname: widget.userToDisplayInformation.lastName,
                      userProgressStreamBloc: BlocProvider.of<UserProgressStreamBloc>(context),
                    ) /*)*/,
                    getVisibility(widget, context, _isOwner),
                  ])
                //)
                else
                  // Padding(
                  //   padding: const EdgeInsets.all(5.0),
                  // child:
                  Stack(children: [
                    /*CircleAvatar(
                      backgroundColor: widget.userToDisplayInformation != null
                          ? OlukoColors.userColor(widget.userToDisplayInformation.firstName, widget.userToDisplayInformation.lastName)
                          : OlukoColors.black,
                      radius: 40.0,
                      child: Text(widget.userToDisplayInformation != null ? profileDefaultProfilePicContent : '',
                          style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500)),
                    ),*/
                    StoriesItem(
                      maxRadius: 40,
                      imageUrl: widget.userToDisplayInformation.avatar,
                      name: widget.userToDisplayInformation.firstName,
                      lastname: widget.userToDisplayInformation.lastName,
                      userProgressStreamBloc: BlocProvider.of<UserProgressStreamBloc>(context),
                    ),
                    getVisibility(widget, context, _isOwner),
                  ]),
                // ),*/
              Expanded(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: _isOwner
                          ? userInfoUnlocked(location)
                          : canShowDetails
                              ? userInfoUnlocked(location)
                              : userInfoLocked(),
                    ),
                  ],
                ),
              ),
              //HIFIVE BUTTON
            ],
          ),
          //],
          // ),
          if (OlukoNeumorphism.isNeumorphismDesign)
            Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenUtils.smallScreen(context) ? 0 : 5),
              child: const OlukoNeumorphicDivider(
                isFadeOut: true,
              ),
            )
          else
            const SizedBox.shrink(),
          if (!widget.minimalRequested) Expanded(child: getUserProfileProgress(widget.userStats, canShowDetails))
        ],
      );
    });
  }

  Widget _profileUserInformation(String location, List<String> valuesForArchivements) {
    final bool canShowDetails = _privacyOptions.canShowDetails(
        isOwner: _isOwner, currentUser: widget.currentUser, userRequested: widget.userToDisplayInformation, connectStatus: widget.connectStatus);

    final profileDefaultProfilePicContent =
        '${widget.userToDisplayInformation.firstName.characters.first.toUpperCase()}${widget.userToDisplayInformation.lastName.characters.first.toUpperCase()}';
    return Column(
      children: [
        //PROFILE IMAGE AND INFO
        Column(
          children: [
            //USER CIRCLEAVATAR
            Row(
              children: [
                if (widget.userToDisplayInformation.avatar != null)
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Stack(clipBehavior: Clip.none, children: [
                      CircleAvatar(
                        backgroundColor: OlukoColors.black,
                        backgroundImage: Image(
                          image: CachedNetworkImageProvider(widget.userToDisplayInformation.avatar),
                          fit: BoxFit.contain,
                          frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
                              ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 30, width: 30),
                          height: 30,
                          width: 30,
                        ).image,
                        radius: 30.0,
                      ),
                      uploadContentComponent(widget, context, _isOwner),
                    ]),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Stack(children: [
                      CircleAvatar(
                        backgroundColor: widget.userToDisplayInformation != null
                            ? OlukoColors.userColor(widget.userToDisplayInformation.firstName, widget.userToDisplayInformation.lastName)
                            : OlukoColors.black,
                        radius: 30.0,
                        child: Text(widget.userToDisplayInformation != null ? profileDefaultProfilePicContent : '',
                            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500)),
                      ),
                      uploadContentComponent(widget, context, _isOwner),
                    ]),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Row(
                    children: [
                      //PROFILE NAME AND LASTNAME
                      if (_isOwner) userInfoUnlocked(location) else canShowDetails ? userInfoUnlocked(location) : userInfoLocked(),
                    ],
                  ),
                ),
                //HIFIVE BUTTON
                if (!_isOwner && widget.actualRoute == ActualProfileRoute.homePage)
                  Expanded(
                    child: BlocListener<HiFiveSendBloc, HiFiveSendState>(
                      listener: (context, hiFiveSendState) {
                        if (hiFiveSendState is HiFiveSendSuccess) {
                          AppMessages.clearAndShowSnackbarTranslated(context, hiFiveSendState.hiFive ? 'hiFiveSent' : 'hiFiveRemoved');
                        }
                        BlocProvider.of<HiFiveReceivedBloc>(context).get(context, _authState.user.id, widget.userToDisplayInformation.id);
                      },
                      child: BlocBuilder<HiFiveReceivedBloc, HiFiveReceivedState>(builder: (context, HiFiveReceivedState) {
                        return HiFiveReceivedState is HiFiveReceivedSuccess
                            ? Container(
                                height: 50,
                                width: 50,
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () {
                                      BlocProvider.of<HiFiveSendBloc>(context).set(
                                        context,
                                        _authState.user.id,
                                        widget.userToDisplayInformation.id,
                                      );
                                    },
                                    child: Image.asset(
                                      HiFiveReceivedState.hiFive ? 'assets/profile/hiFive_selected.png' : 'assets/profile/hiFive.png',
                                      fit: BoxFit.cover,
                                      colorBlendMode: BlendMode.lighten,
                                      height: 60,
                                      width: 60,
                                    )),
                              )
                            : const SizedBox.shrink();
                      }),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ],
        ),
        if (!widget.minimalRequested) getUserProfileProgress(widget.userStats, canShowDetails)
      ],
    );
  }

  UserProfileProgress getUserProfileProgress(UserStatistics userStats, bool canShowDetails) {
    if (!canShowDetails || userStats == null) {
      return UserProfileProgress(
        challengesCompleted: _archivementsDefaultValue,
        coursesCompleted: _archivementsDefaultValue,
        classesCompleted: _archivementsDefaultValue,
        currentUser: widget.currentUser,
      );
    } else {
      return UserProfileProgress(
        challengesCompleted: widget.userStats.completedChallenges.toString(),
        coursesCompleted: widget.userStats.completedCourses.toString(),
        classesCompleted: widget.userStats.completedClasses.toString(),
        isMinimalRequested: widget.minimalRequested,
        currentUser: widget.currentUser,
      );
    }
  }

  Visibility uploadContentComponent(UserProfileInformation userProfileWidget, BuildContext context, bool isOwner) {
    return Visibility(
      visible: userProfileWidget.actualRoute == ActualProfileRoute.homePage && isOwner,
      child: Positioned(
        top: OlukoNeumorphism.isNeumorphismDesign ? 45 : 30,
        right: -12,
        child: Container(
            width: 40,
            height: 40,
            child: UploadProfileMediaMenu(
              galleryState: widget.galleryState,
              contentFrom: UploadFrom.profileImage,
              deleteContent: widget.currentUser.getAvatarThumbnail() != null,
            )),
      ),
    );
  }

  Column userInfoLocked() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userToDisplayInformation.getFullName(),
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              height: 35,
              width: 35,
              child: TextButton(
                  onPressed: () {},
                  child: Image.asset(
                    'assets/profile/lockedProfile.png',
                    fit: BoxFit.fill,
                    height: 60,
                    width: 60,
                  )),
            ),
            Container(
              width: 150,
              height: 25,
              child: Text(OlukoLocalizations.get(context, 'privateProfile'),
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w300)),
            )
          ],
        )
      ],
    );
  }

  Widget userInfoUnlocked(String location) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Padding(
            padding: OlukoNeumorphism.isNeumorphismDesign ? EdgeInsets.only(left: 10.0) : EdgeInsets.zero,
            child: Text(
              UserHelper.getFullName(widget.userToDisplayInformation.firstName, widget.userToDisplayInformation.lastName, isCurrentUser: _isOwner),
              style: OlukoFonts.olukoBigFont(
                  customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary, customFontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 10.0,
            bottom: 10,
          ),
          child: IntrinsicHeight(
            child: Container(
              height: ScreenUtils.height(context) * 0.09,
              width: 170,
              child: Wrap(
                children: [
                  Text(
                    UserHelper.printUsername(widget.userToDisplayInformation.username, widget.userToDisplayInformation.id) ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w300),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                  ),
                  if (_userLocation != null && GlobalService().showUserLocation)
                    Text(
                      location.trim(),
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w300),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
