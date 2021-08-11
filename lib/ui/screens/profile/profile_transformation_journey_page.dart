import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_error_message_view.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/modal_upload_options.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileTransformationJourneyPage extends StatefulWidget {
  @override
  _ProfileTransformationJourneyPageState createState() =>
      _ProfileTransformationJourneyPageState();
}

class _ProfileTransformationJourneyPageState
    extends State<ProfileTransformationJourneyPage> {
  List<Widget> _contentGallery;
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  UserResponse _profileInfo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        _profileInfo = state.user;
        return BlocBuilder<TransformationJourneyBloc,
            TransformationJourneyState>(
          builder: (context, state) {
            if (state is TransformationJourneySuccess) {
              _transformationJourneyContent = state.contentFromUser;
              _contentGallery = _contentGallery =
                  TransformListOfItemsToWidget.getWidgetListFromContent(
                      tansformationJourneyData: _transformationJourneyContent,
                      requestedFromRoute:
                          ActualProfileRoute.transformationJourney);
            }
            return page(context, _profileInfo);
          },
        );
      } else {
        return SizedBox();
      }
    });
  }

  Scaffold page(BuildContext context, UserResponse profileInfo) {
    return Scaffold(
        appBar: OlukoAppBar(
          title: ProfileViewConstants.profileOptionsTransformationJourney,
          showSearchBar: false,
        ),
        body: _contentGallery == null
            ? Container(
                color: Colors.black, child: OlukoCircularProgressIndicator())
            : Container(
                constraints: BoxConstraints.expand(),
                color: OlukoColors.black,
                child: SafeArea(
                  child: Stack(children: [
                    Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                children: [
                                  OlukoOutlinedButton(
                                      title: OlukoLocalizations.of(context)
                                          .find('tapToUpload'),
                                      onPressed: () {
                                        AppModal.dialogContent(
                                            context: context,
                                            content: [
                                              BlocProvider.value(
                                                value: BlocProvider.of<
                                                        TransformationJourneyBloc>(
                                                    context),
                                                child: ModalUploadOptions(
                                                    UploadFrom
                                                        .transformationJourney),
                                              )
                                            ]);
                                      }),
                                ],
                              ),
                            ))),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 150, 10, 0),
                      child: _contentGallery.length != 0
                          ? GridView.count(
                              crossAxisCount: 3,
                              children: _contentGallery,
                            )
                          : OlukoErrorMessage(),
                    ),
                  ]),
                ),
              ));
  }
}
