import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
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
  bool _isPrivateDemo = false;
  String _archivementsDefaultValue = "0";

  @override
  void initState() {
    _userLocation = getUserLocation(widget.userInformation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String _locationDemo = "San Francisco, CA USA";
    final List<String> _valuesDemo = ["07", "10", "50"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: ContainerGradient.getContainerGradientDecoration(),
        width: MediaQuery.of(context).size.width,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _profileUserInformation(_locationDemo, _valuesDemo)),
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
                      !_isPrivateDemo
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Row(
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
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: IntrinsicHeight(
                                      child: Row(
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
                                          VerticalDivider(
                                              color: OlukoColors.grayColor),
                                          _userLocation != null
                                              ? Text(
                                                  location,
                                                  style: OlukoFonts
                                                      .olukoMediumFont(
                                                          customColor:
                                                              OlukoColors
                                                                  .grayColor,
                                                          custoFontWeight:
                                                              FontWeight.w300),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  )
                                ])
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Row(
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
                                      height: 20,
                                      width: 20,
                                      child: TextButton(
                                          onPressed: () {},
                                          child: Icon(
                                              Icons.lock_outline_rounded,
                                              color: OlukoColors.primary,
                                              size: 18)),
                                    ),
                                    Container(
                                      width: 100,
                                      height: 25,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 0, 0),
                                        child: Text(
                                            OlukoLocalizations.of(context)
                                                .find('privateProfile'),
                                            style: OlukoFonts.olukoMediumFont(
                                                customColor:
                                                    OlukoColors.grayColor,
                                                custoFontWeight:
                                                    FontWeight.w300)),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        //PROFILE ARCHIVEMENTS
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: !widget.userIsOwnerProfile && !_isPrivateDemo
              ? UserProfileProgress(
                  challengesCompleted: _archivementsDefaultValue,
                  coursesCompleted: _archivementsDefaultValue,
                  classesCompleted: _archivementsDefaultValue,
                )
              : UserProfileProgress(
                  challengesCompleted: valuesForArchivements[0],
                  coursesCompleted: valuesForArchivements[1],
                  classesCompleted: valuesForArchivements[2],
                ),
        )
      ],
    );
  }
}
