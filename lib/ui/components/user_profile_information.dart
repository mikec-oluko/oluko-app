import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_avatar_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
import 'package:oluko_app/helpers/user_helper.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class UserProfileInformation extends StatefulWidget {
  final UserResponse userToDisplayInformation;
  final ActualProfileRoute actualRoute;
  final UserResponse currentUser;
  final UserConnectStatus connectStatus;
  final UserStatistics userStats;
  const UserProfileInformation({this.userToDisplayInformation, this.actualRoute, this.currentUser, this.connectStatus, this.userStats})
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

  @override
  void initState() {
    _userLocation = getUserLocation(widget.userToDisplayInformation);
    _isOwner = _isOwnerProfile(currentUser: widget.currentUser, userRequested: widget.userToDisplayInformation);

    super.initState();
  }

  bool _isOwnerProfile({@required UserResponse currentUser, @required UserResponse userRequested}) {
    return currentUser.id == userRequested.id;
  }

  @override
  Widget build(BuildContext context) {
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
        return Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10, vertical: OlukoNeumorphism.isNeumorphismDesign ? 20 : 5),
          //TODO: Check if need neumorphic outside
          child: Container(
            decoration: UserInformationBackground.getContainerGradientDecoration(isNeumorphic: OlukoNeumorphism.isNeumorphismDesign),
            width: MediaQuery.of(context).size.width,
            height: OlukoNeumorphism.isNeumorphismDesign ? MediaQuery.of(context).size.height / 3.3 : null,
            child: Padding(
                padding: const EdgeInsets.all(OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
                child: OlukoNeumorphism.isNeumorphismDesign
                    ? _profileUserNeumorphicInformation(_userLocation, _valuesDemo)
                    : _profileUserInformation(_userLocation, _valuesDemo)),
          ),
        );
      }),
    );
  }

  String getUserLocation(UserResponse user) {
    return "${user.city ?? ''}, ${user.state ?? ''} ${user.country ?? ''}";
  }

  Widget _profileUserNeumorphicInformation(String location, List<String> valuesForArchivements) {
    final bool canShowDetails = _privacyOptions.canShowDetails(
        isOwner: _isOwner,
        currentUser: widget.currentUser,
        userRequested: widget.userToDisplayInformation,
        connectStatus: widget.connectStatus);

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
                if (widget.userToDisplayInformation.avatarThumbnail != null)
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Neumorphic(
                        style: NeumorphicStyle(
                            border: NeumorphicBorder(width: 1.5, color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark),
                            depth: 5,
                            intensity: 0.5,
                            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                            shape: NeumorphicShape.flat,
                            lightSource: LightSource.topLeft,
                            boxShape: NeumorphicBoxShape.circle(),
                            shadowDarkColorEmboss: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                            shadowLightColorEmboss: OlukoColors.black,
                            surfaceIntensity: 1,
                            shadowLightColor: OlukoColors.grayColor,
                            shadowDarkColor: Colors.black),
                        child: CircleAvatar(
                          backgroundColor: OlukoColors.black,
                          backgroundImage: Image.network(
                            widget.userToDisplayInformation.avatarThumbnail,
                            fit: BoxFit.contain,
                            frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
                                ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 45, width: 45),
                            height: 45,
                            width: 45,
                          ).image,
                          radius: 45.0,
                        ),
                      ),
                      getVisibility(widget, context, _isOwner),
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
                        radius: 45.0,
                        child: Text(widget.userToDisplayInformation != null ? profileDefaultProfilePicContent : '',
                            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500)),
                      ),
                      getVisibility(widget, context, _isOwner),
                    ]),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: OlukoNeumorphism.isNeumorphismDesign ? 20 : 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //PROFILE NAME AND LASTNAME
                      if (_isOwner) userInfoUnlocked(location) else canShowDetails ? userInfoUnlocked(location) : userInfoLocked(),
                    ],
                  ),
                ),
                //HIFIVE BUTTON
                if (!_isOwner && widget.actualRoute == ActualProfileRoute.userProfile)
                  Expanded(
                    child: BlocListener<HiFiveSendBloc, HiFiveSendState>(
                      listener: (context, hiFiveSendState) {
                        if (hiFiveSendState is HiFiveSendSuccess) {
                          AppMessages.showSnackbarTranslated(context, hiFiveSendState.hiFive ? 'hiFiveSent' : 'hiFiveRemoved');
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
        if (OlukoNeumorphism.isNeumorphismDesign)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: OlukoNeumorphicDivider(
              isFadeOut: true,
            ),
          )
        else
          const SizedBox.shrink(),
        //TODO: CHECK IF NEU
        Expanded(child: getUserProfileProgress(widget.userStats, canShowDetails))
      ],
    );
  }

  Widget _profileUserInformation(String location, List<String> valuesForArchivements) {
    final bool canShowDetails = _privacyOptions.canShowDetails(
        isOwner: _isOwner,
        currentUser: widget.currentUser,
        userRequested: widget.userToDisplayInformation,
        connectStatus: widget.connectStatus);

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
                if (widget.userToDisplayInformation.avatarThumbnail != null)
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Stack(clipBehavior: Clip.none, children: [
                      CircleAvatar(
                        backgroundColor: OlukoColors.black,
                        backgroundImage: Image.network(
                          widget.userToDisplayInformation.avatarThumbnail,
                          fit: BoxFit.contain,
                          frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
                              ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 30, width: 30),
                          height: 30,
                          width: 30,
                        ).image,
                        radius: 30.0,
                      ),
                      getVisibility(widget, context, _isOwner),
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
                            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500)),
                      ),
                      getVisibility(widget, context, _isOwner),
                    ]),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    children: [
                      //PROFILE NAME AND LASTNAME
                      if (_isOwner) userInfoUnlocked(location) else canShowDetails ? userInfoUnlocked(location) : userInfoLocked(),
                    ],
                  ),
                ),
                //HIFIVE BUTTON
                if (!_isOwner && widget.actualRoute == ActualProfileRoute.userProfile)
                  Expanded(
                    child: BlocListener<HiFiveSendBloc, HiFiveSendState>(
                      listener: (context, hiFiveSendState) {
                        if (hiFiveSendState is HiFiveSendSuccess) {
                          AppMessages.showSnackbarTranslated(context, hiFiveSendState.hiFive ? 'hiFiveSent' : 'hiFiveRemoved');
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
        getUserProfileProgress(widget.userStats, canShowDetails)
      ],
    );
  }

  UserProfileProgress getUserProfileProgress(UserStatistics userStats, bool canShowDetails) {
    if (!canShowDetails || userStats == null) {
      return UserProfileProgress(
        challengesCompleted: _archivementsDefaultValue,
        coursesCompleted: _archivementsDefaultValue,
        classesCompleted: _archivementsDefaultValue,
      );
    } else {
      return UserProfileProgress(
        challengesCompleted: widget.userStats.completedChallenges.toString(),
        coursesCompleted: widget.userStats.completedCourses.toString(),
        classesCompleted: widget.userStats.completedClasses.toString(),
      );
    }
  }

  Visibility getVisibility(UserProfileInformation userProfileWidget, BuildContext context, bool isOwner) {
    return Visibility(
      visible: userProfileWidget.actualRoute == ActualProfileRoute.userProfile && isOwner,
      child: Positioned(
        top: 25,
        right: -12,
        child: Container(
          width: 40,
          height: 40,
          child: TextButton(
              onPressed: () {
                BlocProvider.of<ProfileAvatarBloc>(context).openPanel();
              },
              child: Image.asset('assets/profile/uploadImage.png')),
        ),
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
                '${widget.userToDisplayInformation.firstName} ${widget.userToDisplayInformation.lastName}',
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
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
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w300)),
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
          padding: const EdgeInsets.only(left: 10.0).copyWith(top: 5),
          child: Text(
            '${widget.userToDisplayInformation.firstName} ${widget.userToDisplayInformation.lastName}',
            style: OlukoFonts.olukoBigFont(
                customColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.white : OlukoColors.primary,
                custoFontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IntrinsicHeight(
            child: Container(
              height: 30,
              width: 170,
              child: Wrap(
                children: [
                  Text(
                    UserHelper.printUsername(widget.userToDisplayInformation.username, widget.userToDisplayInformation.id) ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w300),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                  ),
                  if (_userLocation != null && _userLocation != "null, null null")
                    Text(
                      location,
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w300),
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
