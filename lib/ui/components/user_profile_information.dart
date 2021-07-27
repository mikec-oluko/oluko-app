import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/utils/container_grediant.dart';

class UserProfileInformation extends StatelessWidget {
  final UserResponse userInformation;

  const UserProfileInformation({this.userInformation}) : super();

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
                userInformation.avatarThumbnail != null
                    ? Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundColor: OlukoColors.white,
                          backgroundImage:
                              NetworkImage(userInformation.avatarThumbnail),
                          radius: 30.0,
                        ),
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
                                    this.userInformation.firstName,
                                    style: OlukoFonts.olukoBigFont(
                                        customColor: OlukoColors.primary,
                                        custoFontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(
                                    this.userInformation.lastName,
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
                                      this.userInformation.username,
                                      style: OlukoFonts.olukoMediumFont(
                                          custoFontWeight: FontWeight.w300),
                                    ),
                                    VerticalDivider(
                                        color: OlukoColors.grayColor),
                                    Text(
                                      location,
                                      style: OlukoFonts.olukoMediumFont(
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
