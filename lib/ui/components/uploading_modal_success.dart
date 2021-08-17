import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';

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
      color: OlukoColors.black,
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
                                if (widget.goToPage ==
                                        UploadFrom.profileImage ||
                                    widget.goToPage ==
                                        UploadFrom.profileCoverImage) {
                                  BlocProvider.of<AuthBloc>(context)
                                    ..checkCurrentUser();
                                  Navigator.pop(context);

                                  Navigator.popAndPushNamed(context,
                                      returnRouteToGo(widget.goToPage));
                                }
                                if (widget.goToPage ==
                                    UploadFrom.transformationJourney) {
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
      routeToGo = routeLabels[RouteEnum.profileTransformationJourney];
    }
    if (cameFrom == UploadFrom.profileImage) {
      routeToGo = routeLabels[RouteEnum.profileViewOwnProfile];
    }
    if (cameFrom == UploadFrom.profileCoverImage) {
      routeToGo = routeLabels[RouteEnum.profileViewOwnProfile];
    }
    return routeToGo;
  }
}
