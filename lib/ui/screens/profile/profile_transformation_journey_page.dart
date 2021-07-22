import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
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
  String _titleForContent;
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  UserResponse _profileInfo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getProfileInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return page(context, _profileInfo);
          } else {
            return SizedBox();
          }
        });
  }

  Future<void> _getProfileInfo() async {
    _profileInfo =
        UserResponse.fromJson((await AuthBloc().retrieveLoginData()).toJson());
    return _profileInfo;
  }

  Scaffold page(BuildContext context, UserResponse profileInfo) {
    if (_contentGallery == null || _contentGallery.length == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
            _contentGallery = buildContentGallery(
                uploadListContent: _transformationJourneyContent);
            _titleForContent = getTitleForContent(
                uploadListContent: _transformationJourneyContent);
          }));
    }
    _requestTransformationJourneyData(context, profileInfo);

    return _contentGallery == null
        ? OlukoCircularProgressIndicator()
        : Scaffold(
            appBar: OlukoAppBar(
              title: ProfileViewConstants.profileOptionsTransformationJourney,
              showSearchBar: false,
            ),
            body: BlocConsumer<TransformationJourneyBloc,
                TransformationJourneyState>(
              listener: (context, state) {
                if (state is TransformationJourneySuccess) {
                  _transformationJourneyContent = state.contentFromUser;
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
                          child: Expanded(
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: OlukoOutlinedButton(
                                        title: OlukoLocalizations.of(context)
                                            .find('tapToUpload'),
                                        onPressed: () {
                                          AppModal.dialogContent(
                                              context: context,
                                              content: [
                                                ModalUploadOptions(UploadFrom
                                                    .transformationJourney)
                                              ]);
                                          _requestTransformationJourneyData(
                                              context, profileInfo);
                                        }),
                                  )))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 100, 10, 0),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(_titleForContent,
                                style: OlukoFonts.olukoBigFont())),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 150, 10, 0),
                        child: GridView.count(
                          crossAxisCount: 3,
                          children: _contentGallery,
                        ),
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

  String getTitleForContent(
      {List<TransformationJourneyUpload> uploadListContent}) {
    int _videos = 0;
    int _images = 0;
    uploadListContent.forEach((content) =>
        content.type == FileTypeEnum.video ? _videos += 1 : _images += 1);
    return "Uploaded $_images Images & $_videos Videos";
  }

  void _requestTransformationJourneyData(
      BuildContext context, UserResponse profileInfo) {
    BlocProvider.of<TransformationJourneyBloc>(context)
        .getContentByUserName(profileInfo.username);
  }
}
