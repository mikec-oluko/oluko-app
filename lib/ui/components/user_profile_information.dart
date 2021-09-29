import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_received_bloc.dart';
import 'package:oluko_app/blocs/friends/hi_five_send_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_avatar_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
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
  String _archivementsDefaultValue = "0";
  PrivacyOptions _privacyOptions = PrivacyOptions();
  HiFiveReceivedSuccess _hiFiveReceivedState;
  AuthSuccess _authState;

  @override
  void initState() {
    _userLocation = getUserLocation(widget.userToDisplayInformation);
    if (_isOwnerProfile(currentUser: widget.currentUser, userRequested: widget.userToDisplayInformation)) {
      _isOwner = true;
    }

    super.initState();
  }

  bool _isOwnerProfile({@required UserResponse currentUser, @required UserResponse userRequested}) {
    return currentUser.id == userRequested.id;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _valuesDemo = ["07", "10", "50"];

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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Container(
            decoration: ContainerGradient.getContainerGradientDecoration(),
            width: MediaQuery.of(context).size.width,
            child: Padding(padding: const EdgeInsets.all(10.0), child: _profileUserInformation(_userLocation, _valuesDemo)),
          ),
        );
      }),
    );
  }

  String getUserLocation(UserResponse user) {
    return "${user.city ?? ''}, ${user.state ?? ''} ${user.country ?? ''}";
  }

  Widget _profileUserInformation(String location, List<String> valuesForArchivements) {
    return Column(
      children: [
        //PROFILE IMAGE AND INFO
        Column(
          children: [
            //USER CIRCLEAVATAR
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.userToDisplayInformation.avatarThumbnail != null
                    ? Padding(
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
                          Visibility(
                            visible: widget.actualRoute == ActualProfileRoute.userProfile && _isOwner,
                            child: Positioned(
                              top: 25,
                              right: -12,
                              child: Container(
                                clipBehavior: Clip.none,
                                width: 40,
                                height: 40,
                                child: TextButton(
                                    onPressed: () {
                                      BlocProvider.of<ProfileAvatarBloc>(context).openPanel();
                                    },
                                    child: Image.asset('assets/profile/uploadImage.png')),
                              ),
                            ),
                          ),
                        ]),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Stack(children: [
                          CircleAvatar(
                            backgroundColor: OlukoColors.black,
                            radius: 30.0,
                          ),
                          Visibility(
                            visible: widget.actualRoute == ActualProfileRoute.userProfile && _isOwner,
                            child: Positioned(
                              top: 25,
                              right: -12,
                              child: Container(
                                clipBehavior: Clip.none,
                                width: 40,
                                height: 40,
                                child: TextButton(
                                    onPressed: () {
                                      BlocProvider.of<ProfileAvatarBloc>(context)..openPanel();
                                    },
                                    child: Image.asset('assets/profile/uploadImage.png')),
                              ),
                            ),
                          ),
                        ]),
                      ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    children: [
                      //PROFILE NAME AND LASTNAME
                      _isOwner
                          ? userInfoUnlocked(location)
                          : _privacyOptions.canShowDetails(
                                  isOwner: _isOwner,
                                  currentUser: widget.currentUser,
                                  userRequested: widget.userToDisplayInformation,
                                  connectStatus: widget.connectStatus)
                              ? userInfoUnlocked(location)
                              : userInfoLocked(),
                    ],
                  ),
                ),
                //TODO: Check show/hide button conditions
                //HIFIVE BUTTON
                !_isOwner && widget.actualRoute == ActualProfileRoute.userProfile
                    ? Container(
                        child: BlocListener<HiFiveSendBloc, HiFiveSendState>(
                          listener: (context, hiFiveSendState) {
                            if (hiFiveSendState is HiFiveSendSuccess) {
                              AppMessages.showSnackbarTranslated(context, hiFiveSendState.hiFive ? 'hiFiveSent' : 'hiFiveRemoved');
                            }
                            BlocProvider.of<HiFiveReceivedBloc>(context)
                                .get(context, _authState.user.id, widget.userToDisplayInformation.id);
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
                                              context, _authState.user.id, widget.userToDisplayInformation.id,
                                              hiFive: !_hiFiveReceivedState.hiFive);
                                        },
                                        child: Image.asset(
                                          HiFiveReceivedState.hiFive ? 'assets/profile/hiFive_selected.png' : 'assets/profile/hiFive.png',
                                          fit: BoxFit.cover,
                                          colorBlendMode: BlendMode.lighten,
                                          height: 60,
                                          width: 60,
                                        )),
                                  )
                                : SizedBox();
                          }),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ],
        ),
        //PROFILE ARCHIVEMENTS
        _privacyOptions.canShowDetails(
                isOwner: _isOwner,
                currentUser: widget.currentUser,
                userRequested: widget.userToDisplayInformation,
                connectStatus: widget.connectStatus)
            ? UserProfileProgress(
                challengesCompleted: widget.userStats != null ? widget.userStats.completedChallenges.toString() : _archivementsDefaultValue,
                coursesCompleted: widget.userStats != null ? widget.userStats.completedCourses.toString() : _archivementsDefaultValue,
                classesCompleted: widget.userStats != null ? widget.userStats.completedClasses.toString() : _archivementsDefaultValue,
              )
            : UserProfileProgress(
                challengesCompleted: _archivementsDefaultValue,
                coursesCompleted: _archivementsDefaultValue,
                classesCompleted: _archivementsDefaultValue,
              )
      ],
    );
  }

  Column userInfoLocked() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                this.widget.userToDisplayInformation.firstName,
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                this.widget.userToDisplayInformation.lastName,
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
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
              child: Text(OlukoLocalizations.of(context).find('privateProfile'),
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w300)),
            )
          ],
        )
      ],
    );
  }

  Column userInfoUnlocked(String location) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0).copyWith(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                this.widget.userToDisplayInformation.firstName,
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                this.widget.userToDisplayInformation.lastName,
                style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
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
                  this.widget.userToDisplayInformation.username ?? '',
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w300),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                ),
                _userLocation != null
                    ? Text(
                        location,
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w300),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      )
    ]);
  }
}
