import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_avatar_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class UserProfileInformation extends StatefulWidget {
  final UserResponse userToDisplayInformation;
  final ActualProfileRoute actualRoute;
  final UserResponse currentUser;
  final UserConnectStatus connectStatus;

  const UserProfileInformation(
      {this.userToDisplayInformation,
      this.actualRoute,
      this.currentUser,
      this.connectStatus})
      : super();

  @override
  _UserProfileInformationState createState() => _UserProfileInformationState();
}

class _UserProfileInformationState extends State<UserProfileInformation> {
  String _userLocation;
  //TODO: ESTABLECER ISOWNER CON LA MISMA LOGICA QUE ANTES
  bool _isOwner = false;
  String _archivementsDefaultValue = "0";

  @override
  void initState() {
    _userLocation = getUserLocation(widget.userToDisplayInformation);
    if (_isOwnerProfile(
        currentUser: widget.currentUser,
        userRequested: widget.userToDisplayInformation)) {
      _isOwner = true;
    }

    super.initState();
  }

  bool _isOwnerProfile(
      {@required UserResponse currentUser,
      @required UserResponse userRequested}) {
    return currentUser.id == userRequested.id;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _valuesDemo = ["07", "10", "50"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: ContainerGradient.getContainerGradientDecoration(),
        width: MediaQuery.of(context).size.width,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _profileUserInformation(_userLocation, _valuesDemo)),
      ),
    );
  }

  String getUserLocation(UserResponse user) {
    String userLocationContent;
    if (user.city != null && (user.state != null && user.country != null)) {
      userLocationContent = "${user.city}, ${user.state} ${user.country}";
    }
    return userLocationContent;
  }

  Widget _profileUserInformation(
      String location, List<String> valuesForArchivements) {
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
                              frameBuilder: (BuildContext context, Widget child,
                                      int frame, bool wasSynchronouslyLoaded) =>
                                  ImageUtils.frameBuilder(context, child, frame,
                                      wasSynchronouslyLoaded,
                                      height: 30, width: 30),
                              height: 30,
                              width: 30,
                            ).image,
                            radius: 30.0,
                          ),
                          Visibility(
                            visible: widget.actualRoute ==
                                    ActualProfileRoute.userProfile &&
                                _isOwner,
                            child: Positioned(
                              top: 25,
                              right: -12,
                              child: Container(
                                clipBehavior: Clip.none,
                                width: 40,
                                height: 40,
                                child: TextButton(
                                    onPressed: () {
                                      BlocProvider.of<ProfileAvatarBloc>(
                                          context)
                                        ..openPanel();
                                    },
                                    child: Image.asset(
                                        'assets/profile/uploadImage.png')),
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
                          //USER ES OWNER Y PUEDE CAMBIAR FOTO DE PERFIL
                          Visibility(
                            visible: widget.actualRoute ==
                                    ActualProfileRoute.userProfile &&
                                _isOwner,
                            child: Positioned(
                              top: 25,
                              right: -12,
                              child: Container(
                                clipBehavior: Clip.none,
                                width: 40,
                                height: 40,
                                child: TextButton(
                                    onPressed: () {
                                      BlocProvider.of<ProfileAvatarBloc>(
                                          context)
                                        ..openPanel();
                                    },
                                    child: Image.asset(
                                        'assets/profile/uploadImage.png')),
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
                      //USER ES PRIVADO Y NO ES OWNER
                      _isOwner
                          ? userInfoUnlocked(location)
                          : PrivacyOptions.canShowDetails(
                                  isOwner: _isOwner,
                                  currentUser: widget.currentUser,
                                  userRequested:
                                      widget.userToDisplayInformation,
                                  connectStatus: widget.connectStatus)
                              ? userInfoUnlocked(location)
                              : userInfoLocked(),
                    ],
                  ),
                ),
                //TODO: Check show/hide button conditions
                //HIFIVE BUTTON
                !_isOwner &&
                        widget.actualRoute == ActualProfileRoute.userProfile
                    ? Container(
                        height: 50,
                        width: 50,
                        child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              //TODO: HiFive Logic
                            },
                            child: Image.asset(
                              'assets/profile/hiFive.png',
                              fit: BoxFit.cover,
                              height: 60,
                              width: 60,
                            )),
                      )
                    : SizedBox(),
              ],
            ),
          ],
        ),
        //PROFILE ARCHIVEMENTS
        //CHECK TODA LA LOGICA ACA PRIVACY 1 Y  2 ADEMAS DE CONNECTION STATUS
        PrivacyOptions.canShowDetails(
                isOwner: _isOwner,
                currentUser: widget.currentUser,
                userRequested: widget.userToDisplayInformation,
                connectStatus: widget.connectStatus)
            ? UserProfileProgress(
                challengesCompleted: valuesForArchivements[0],
                coursesCompleted: valuesForArchivements[1],
                classesCompleted: valuesForArchivements[2],
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
                style: OlukoFonts.olukoBigFont(
                    customColor: OlukoColors.primary,
                    custoFontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                this.widget.userToDisplayInformation.lastName,
                style: OlukoFonts.olukoBigFont(
                    customColor: OlukoColors.primary,
                    custoFontWeight: FontWeight.w500),
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
                  style: OlukoFonts.olukoMediumFont(
                      customColor: OlukoColors.grayColor,
                      custoFontWeight: FontWeight.w300)),
            )
          ],
        )
      ],
    );
  }

  Column userInfoUnlocked(String location) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0).copyWith(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    this.widget.userToDisplayInformation.firstName,
                    style: OlukoFonts.olukoBigFont(
                        customColor: OlukoColors.primary,
                        custoFontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    this.widget.userToDisplayInformation.lastName,
                    style: OlukoFonts.olukoBigFont(
                        customColor: OlukoColors.primary,
                        custoFontWeight: FontWeight.w500),
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
                      this.widget.userToDisplayInformation.username,
                      style: OlukoFonts.olukoMediumFont(
                          customColor: OlukoColors.grayColor,
                          custoFontWeight: FontWeight.w300),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                          width: 1, height: 15, color: OlukoColors.grayColor),
                    ),
                    _userLocation != null
                        ? Text(
                            location,
                            style: OlukoFonts.olukoMediumFont(
                                customColor: OlukoColors.grayColor,
                                custoFontWeight: FontWeight.w300),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
          )
        ]);
  }

  // bool canShowDetails() {
  //   if (_isOwner) {
  //     return true;
  //   } else {
  //     if (currentUserPrivacyOption() == SettingsPrivacyOptions.public) {
  //       if (userRequestedPrivacyOption() == SettingsPrivacyOptions.public) {
  //         return true;
  //       } else if (userRequestedPrivacyOption() ==
  //               SettingsPrivacyOptions.restricted &&
  //           widget.connectStatus == UserConnectStatus.connected) {
  //         return true;
  //       } else if (userRequestedPrivacyOption() ==
  //               SettingsPrivacyOptions.anonymous &&
  //           widget.connectStatus == UserConnectStatus.connected) {
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }
  //     if (currentUserPrivacyOption() == SettingsPrivacyOptions.restricted) {
  //       if (userRequestedPrivacyOption() == SettingsPrivacyOptions.public) {
  //         return true;
  //       } else if (userRequestedPrivacyOption() ==
  //               SettingsPrivacyOptions.restricted &&
  //           widget.connectStatus == UserConnectStatus.connected) {
  //         return true;
  //       } else if (userRequestedPrivacyOption() ==
  //               SettingsPrivacyOptions.anonymous &&
  //           widget.connectStatus == UserConnectStatus.connected) {
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     }
  //     if (currentUserPrivacyOption() == SettingsPrivacyOptions.anonymous) {
  //       if (userRequestedPrivacyOption() == SettingsPrivacyOptions.public) {
  //         return true;
  //       } else if (userRequestedPrivacyOption() ==
  //               SettingsPrivacyOptions.restricted &&
  //           widget.connectStatus == UserConnectStatus.connected) {
  //         return true;
  //       }
  //     }
  //   }
  // }

  // SettingsPrivacyOptions currentUserPrivacyOption() {
  //   return PrivacyOptions.privacyOptionsList[widget.currentUser.privacy].option;
  // }

  // SettingsPrivacyOptions userRequestedPrivacyOption() {
  //   return PrivacyOptions
  //       .privacyOptionsList[widget.userToDisplayInformation.privacy].option;
  // }
}
