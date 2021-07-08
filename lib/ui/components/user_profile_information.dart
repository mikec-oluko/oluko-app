import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';

class UserProfileInformation extends StatelessWidget {
  final UserResponse userInformation;

  const UserProfileInformation({this.userInformation}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoColors.black,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
              child: CircleAvatar(
                backgroundColor: OlukoColors.white,
                // backgroundImage: ,
                radius: 30.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        this.userInformation.firstName,
                        style: OlukoFonts.olukoBigFont(
                            custoFontWeight: FontWeight.w500),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          this.userInformation.lastName,
                          style: OlukoFonts.olukoBigFont(
                              custoFontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  //TODO: Use username instead profilLevel
                  Text(ProfileViewConstants.profileUserNameContent,
                      style: OlukoFonts.olukoMediumFont(
                          customColor: OlukoColors.grayColor))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
