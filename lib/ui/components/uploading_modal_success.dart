import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/ui/screens/profile/profile_routes.dart';

class UploadingModalSuccess extends StatefulWidget {
  final UploadFrom goToPage;
  UploadingModalSuccess(this.goToPage);

  @override
  _UploadingModalSuccessState createState() => _UploadingModalSuccessState();
}

class _UploadingModalSuccessState extends State<UploadingModalSuccess> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: CircleAvatar(
                    backgroundColor: OlukoColors.primary,
                    radius: 40.0,
                    child: IconButton(
                        icon: Icon(Icons.check, color: OlukoColors.black),
                        onPressed: () {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Uploaded Successfully",
                    style: OlukoFonts.olukoTitleFont(
                        custoFontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          OlukoOutlinedButton(
                            title: "Done",
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String returnRouteToGo(UploadFrom cameFrom) {
    String routeToGo = '/';
    if (cameFrom == UploadFrom.transformationJourney) {
      routeToGo = ProfileRoutes.profileTransformationJourneyRoute;
    }
    if (cameFrom == UploadFrom.profileImage) {
      routeToGo = ProfileRoutes.profileMyAccountRoute;
    }
    return routeToGo;
  }
}
