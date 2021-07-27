import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/user_profile_progress.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class UserProfileInformation extends StatelessWidget {
  final UserResponse userInformation;

  const UserProfileInformation({this.userInformation}) : super();

  @override
  Widget build(BuildContext context) {
    final String _locationDemo = "San Francisco, CA USA";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              OlukoColors.grayColorFadeTop,
              OlukoColors.grayColorFadeBottom
            ], stops: [
              0.0,
              1
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            color: OlukoColors.secondary,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        width: MediaQuery.of(context).size.width,
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            //BIG COLUMN
            child: Column(
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
                                  backgroundImage: NetworkImage(
                                      userInformation.avatarThumbnail),
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
                          child: Expanded(
                            child: Row(
                              children: [
                                //PROFILE NAME AND LASTNAME
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              this.userInformation.firstName,
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
                                              this.userInformation.lastName,
                                              style: OlukoFonts.olukoBigFont(
                                                  customColor:
                                                      OlukoColors.primary,
                                                  custoFontWeight:
                                                      FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              Text(
                                                this.userInformation.username,
                                                style:
                                                    OlukoFonts.olukoMediumFont(
                                                        custoFontWeight:
                                                            FontWeight.w300),
                                              ),
                                              VerticalDivider(
                                                  color: OlukoColors.grayColor),
                                              Text(
                                                _locationDemo,
                                                style:
                                                    OlukoFonts.olukoMediumFont(
                                                        custoFontWeight:
                                                            FontWeight.w300),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ]),
                                //PROFILE USERNAME, CITY, STATE, COUNTRY
                                Column(
                                  children: [
                                    Row(),
                                    Row(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    //PROFILE INFO
                    // Row(
                    //   children: [
                    //     //PROFILE NAME AND LASTNAME
                    //     Column(children: [
                    //       Row(
                    //         children: [
                    //           Text(
                    //             this.userInformation.firstName,
                    //             style: OlukoFonts.olukoBigFont(
                    //                 custoFontWeight: FontWeight.w500),
                    //           ),
                    //         ],
                    //       )
                    //     ]),
                    //     //PROFILE USERNAME, CITY, STATE, COUNTRY
                    //     Column(
                    //       children: [
                    //         Row(),
                    //         Row(),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
                //PROFILE ARCHIVEMENTS
                Column(
                  children: [
                    Row(
                      children: [
                        //CHALLENGES COMPLETED
                        Column(
                          children: [
                            //VALUE
                            Column(),
                            //SUBTITLE
                            Column(),
                          ],
                        ),
                        //SEPARATOR
                        //COURSES COMPLETED
                        Column(
                          children: [
                            //VALUE
                            Column(),
                            //SUBTITLE
                            Column(),
                          ],
                        ),
                        //SEPARATOR
                        //CLASSES COMPLETED
                        Column(
                          children: [
                            //VALUE
                            Column(),
                            //SUBTITLE
                            Column(),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
