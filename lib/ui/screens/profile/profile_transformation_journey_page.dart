import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
// import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
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
        _requestTransformationJourneyData(context, _profileInfo);
        return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: BlocProvider.of<ProfileBloc>(context),
              ),
              BlocProvider.value(
                value: BlocProvider.of<TransformationJourneyBloc>(context),
              ),
              BlocProvider.value(
                value: BlocProvider.of<AuthBloc>(context),
              ),
            ],
            child: BlocConsumer<TransformationJourneyBloc,
                TransformationJourneyState>(
              listener: (context, state) {
                if (state is TransformationJourneySuccess) {
                  _transformationJourneyContent = state.contentFromUser;
                  _contentGallery = buildContentGallery(
                      uploadListContent: _transformationJourneyContent);
                }
              },
              builder: (context, state) {
                return page(context, _profileInfo);
              },
            ));
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
          : BlocConsumer<TransformationJourneyBloc, TransformationJourneyState>(
              listener: (context, state) {
                if (state is TransformationJourneySuccess) {
                  _transformationJourneyContent = state.contentFromUser;
                  _contentGallery = buildContentGallery(
                      uploadListContent: _transformationJourneyContent);
                }
              },
              builder: (context, state) {
                return Container(
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
                );
              },
            ),
    );
  }

  Widget _getImageAndVideoCard(
      {TransformationJourneyUpload transformationJourneyContent}) {
    Widget contentForReturn;

    if (transformationJourneyContent != null) {
      contentForReturn = ImageAndVideoContainer(
        assetImage: transformationJourneyContent.thumbnail,
        isVideo: transformationJourneyContent.type == FileTypeEnum.video
            ? true
            : false,
        videoUrl: transformationJourneyContent.file,
      );
    }

    return contentForReturn;
  }

  List<Widget> buildContentGallery(
      {List<TransformationJourneyUpload> uploadListContent}) {
    List<Widget> widgetListOfContentTempt = [];

    uploadListContent.forEach((content) => {
          widgetListOfContentTempt
              .add(_getImageAndVideoCard(transformationJourneyContent: content))
        });
    return widgetListOfContentTempt;
  }

  Future<void> _requestTransformationJourneyData(
      BuildContext context, UserResponse profileInfo) async {
    try {
      BlocProvider.of<TransformationJourneyBloc>(context)
          .getContentByUserName(profileInfo.username);
    } catch (e) {
      throw e;
    }
  }
}
