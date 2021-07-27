import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
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
  final _successText = "Uploaded Successfully";
  final _doneButtonText = "Done";
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
                    _successText,
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
                              title: _doneButtonText,
                              onPressed: () {
                                //Cambiar navigator
                                //add methods to restart state
                                //get route from
                                if (widget.goToPage ==
                                    UploadFrom.profileImage) {
                                  BlocProvider.of<ProfileBloc>(context)
                                    ..resetUploadStatus();
                                  BlocProvider.of<AuthBloc>(context)
                                    ..checkCurrentUser();
                                  Navigator.pop(context);

                                  Navigator.popAndPushNamed(context,
                                      returnRouteToGo(widget.goToPage));
                                }
                                if (widget.goToPage ==
                                    UploadFrom.transformationJourney) {
                                  BlocProvider.of<TransformationJourneyBloc>(
                                      context)
                                    ..resetUploadStatus();
                                  Navigator.popAndPushNamed(context,
                                      returnRouteToGo(widget.goToPage));
                                }
                              }),
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
