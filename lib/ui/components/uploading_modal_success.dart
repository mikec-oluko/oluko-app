import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_avatar_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_cover_image_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_transformation_journey_content_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class UploadingModalSuccess extends StatefulWidget {
  final UploadFrom goToPage;
  final UserResponse userRequested;
  UploadingModalSuccess({this.goToPage, this.userRequested});

  @override
  _UploadingModalSuccessState createState() => _UploadingModalSuccessState();
}

class _UploadingModalSuccessState extends State<UploadingModalSuccess> {
  @override
  Widget build(BuildContext context) {
    final _successText = OlukoLocalizations.of(context).find('uploadedSuccessfully');
    final _doneButtonText = OlukoLocalizations.of(context).find('done');
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
                    child: IconButton(icon: Icon(Icons.check, color: OlukoColors.black), onPressed: () {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _successText,
                    style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.w400),
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
                                if (widget.goToPage == UploadFrom.transformationJourney) {
                                  BlocProvider.of<TransformationJourneyContentBloc>(context)..emitDefaultState();
                                  BlocProvider.of<TransformationJourneyBloc>(context)..emitTransformationJourneyDefault();
                                  Navigator.popAndPushNamed(context, routeLabels[RouteEnum.profileTransformationJourney]);
                                } else {
                                  BlocProvider.of<ProfileAvatarBloc>(context)..emitDefaultState();
                                  BlocProvider.of<ProfileCoverImageBloc>(context)..emitDefaultState();
                                  BlocProvider.of<AuthBloc>(context)..checkCurrentUser();

                                  Navigator.popAndPushNamed(context, routeLabels[RouteEnum.profileViewOwnProfile],
                                      arguments: {'userRequested': widget.userRequested});
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
}
