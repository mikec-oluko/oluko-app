import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/privacy_options.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

import 'modal_upload_options.dart';

class UserProfileInformation extends StatefulWidget {
  final UserResponse userInformation;
  final ActualProfileRoute actualRoute;
  final bool userIsOwnerProfile;
  const UserProfileInformation(
      {this.userInformation, this.actualRoute, this.userIsOwnerProfile})
      : super();

  @override
  _UserProfileInformationState createState() => _UserProfileInformationState();
}

class _UserProfileInformationState extends State<UserProfileInformation> {
  String _userLocation;
  bool _isProfilePrivate = false;
  String _archivementsDefaultValue = "0";

  @override
  void initState() {
    _userLocation = getUserLocation(widget.userInformation);
    // PrivacyOptions
    //         .privacyOptionsList[widget.userInformation.privacy].option !=
    //     SettingsPrivacyOptions.restricted
    if (PrivacyOptions
            .privacyOptionsList[widget.userInformation.privacy].option ==
        SettingsPrivacyOptions.restricted) {
      setState(() {
        _isProfilePrivate = true;
      });
    }
    super.initState();
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
                widget.userInformation.avatarThumbnail != null
                    ? Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Stack(clipBehavior: Clip.none, children: [
                          CircleAvatar(
                            backgroundColor: OlukoColors.black,
                            backgroundImage: Image.network(
                              widget.userInformation.avatarThumbnail,
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
                                widget.userIsOwnerProfile,
                            child: Positioned(
                              top: 25,
                              right: -12,
                              child: Container(
                                clipBehavior: Clip.none,
                                width: 40,
                                height: 40,
                                child: TextButton(
                                    onPressed: () {
                                      //UPDATE PROFILE PIC
                                      AppModal.dialogContent(
                                          context: context,
                                          content: [
                                            BlocProvider.value(
                                              value:
                                                  BlocProvider.of<ProfileBloc>(
                                                      context),
                                              child: ModalUploadOptions(
                                                  UploadFrom.profileImage),
                                            )
                                          ]);
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
                          Visibility(
                            visible: widget.actualRoute ==
                                    ActualProfileRoute.userProfile &&
                                widget.userIsOwnerProfile == true,
                            child: Positioned(
                              top: 25,
                              right: -12,
                              child: Container(
                                clipBehavior: Clip.none,
                                width: 40,
                                height: 40,
                                child: TextButton(
                                    onPressed: () {
                                      AppModal.dialogContent(
                                          context: context,
                                          content: [
                                            BlocProvider.value(
                                              value:
                                                  BlocProvider.of<ProfileBloc>(
                                                      context),
                                              child: ModalUploadOptions(
                                                  UploadFrom.profileImage),
                                            )
                                          ]);
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
                      !_isProfilePrivate && widget.userIsOwnerProfile
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10.0)
                                          .copyWith(top: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            this
                                                .widget
                                                .userInformation
                                                .firstName,
                                            style: OlukoFonts.olukoBigFont(
                                                customColor:
                                                    OlukoColors.primary,
                                                custoFontWeight:
                                                    FontWeight.w500),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            this
                                                .widget
                                                .userInformation
                                                .lastName,
                                            style: OlukoFonts.olukoBigFont(
                                                customColor:
                                                    OlukoColors.primary,
                                                custoFontWeight:
                                                    FontWeight.w500),
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
                                              this
                                                  .widget
                                                  .userInformation
                                                  .username,
                                              style: OlukoFonts.olukoMediumFont(
                                                  customColor:
                                                      OlukoColors.grayColor,
                                                  custoFontWeight:
                                                      FontWeight.w300),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 3),
                                              child: Container(
                                                  width: 1,
                                                  height: 15,
                                                  color: OlukoColors.grayColor),
                                            ),
                                            _userLocation != null
                                                ? Text(
                                                    location,
                                                    style: OlukoFonts
                                                        .olukoMediumFont(
                                                            customColor:
                                                                OlukoColors
                                                                    .grayColor,
                                                            custoFontWeight:
                                                                FontWeight
                                                                    .w300),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ])
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        this.widget.userInformation.firstName,
                                        style: OlukoFonts.olukoBigFont(
                                            customColor: OlukoColors.primary,
                                            custoFontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        this.widget.userInformation.lastName,
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
                                      child: Text(
                                          OlukoLocalizations.of(context)
                                              .find('privateProfile'),
                                          style: OlukoFonts.olukoMediumFont(
                                              customColor:
                                                  OlukoColors.grayColor,
                                              custoFontWeight:
                                                  FontWeight.w300)),
                                    )
                                  ],
                                )
                              ],
                            ),
                    ],
                  ),
                ),
                //TODO: Check show/hide button conditions
                !widget.userIsOwnerProfile &&
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
        !widget.userIsOwnerProfile && _isProfilePrivate == true
            ? UserProfileProgress(
                challengesCompleted: _archivementsDefaultValue,
                coursesCompleted: _archivementsDefaultValue,
                classesCompleted: _archivementsDefaultValue,
              )
            : UserProfileProgress(
                challengesCompleted: valuesForArchivements[0],
                coursesCompleted: valuesForArchivements[1],
                classesCompleted: valuesForArchivements[2],
              )
      ],
    );
  }
}
