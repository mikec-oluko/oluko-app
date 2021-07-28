import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/container_grediant.dart';

import 'modal_upload_options.dart';

class UserProfileInformation extends StatefulWidget {
  final UserResponse userInformation;
  final Function() onPressed;

  const UserProfileInformation({this.userInformation, this.onPressed})
      : super();

  @override
  _UserProfileInformationState createState() => _UserProfileInformationState();
}

class _UserProfileInformationState extends State<UserProfileInformation> {
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
            //BIG COLUMN
            child: _profileUserInformation(_locationDemo, _valuesDemo)),
      ),
    );
  }

  Widget _profileUserInformation(
      String location, List<String> valuesForArchivements) {
    final bool _isOwnProfile = true;

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
                            backgroundColor: OlukoColors.white,
                            backgroundImage: NetworkImage(
                                widget.userInformation.avatarThumbnail),
                            radius: 30.0,
                          ),
                          Visibility(
                            visible: _isOwnProfile,
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
                          )
                        ]),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundColor: OlukoColors.white,
                          radius: 30.0,
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    children: [
                      //PROFILE NAME AND LASTNAME
                      Column(
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
                                      this.widget.userInformation.username,
                                      style: OlukoFonts.olukoMediumFont(
                                          customColor: OlukoColors.grayColor,
                                          custoFontWeight: FontWeight.w300),
                                    ),
                                    VerticalDivider(
                                        color: OlukoColors.grayColor),
                                    Text(
                                      location,
                                      style: OlukoFonts.olukoMediumFont(
                                          customColor: OlukoColors.grayColor,
                                          custoFontWeight: FontWeight.w300),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ]),
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
          child: UserProfileProgress(
            challengesCompleted: valuesForArchivements[0],
            coursesCompleted: valuesForArchivements[1],
            classesCompleted: valuesForArchivements[2],
          ),
        )
      ],
    );
  }
}
