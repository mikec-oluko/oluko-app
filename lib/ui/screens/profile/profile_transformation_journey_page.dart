import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
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
  int variableSet = 0;
  double width;
  double height;
  int pos;

  ScrollController _scrollController;
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
              _contentGallery =
                  TransformListOfItemsToWidget.getWidgetListFromContent(
                      tansformationJourneyData: _transformationJourneyContent,
                      requestedFromRoute:
                          ActualProfileRoute.transformationJourney);
            } else if (state is TransformationJourneyNoUploads) {
              BlocProvider.of<TransformationJourneyBloc>(context)
                ..emitTransformationJourneyFailure();
            } else if (state is TransformationJourneyFailure) {
              BlocProvider.of<TransformationJourneyBloc>(context)
                ..getContentByUserId(_profileInfo.id);
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
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 1.4,
                          child: DragAndDropGridView(
                            isCustomChildWhenDragging: true,
                            childWhenDragging: (pos) => Container(
                              height: 120,
                              width: 100,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  border: Border.all(
                                    width: 2.0,
                                    color: OlukoColors.grayColor,
                                  )),
                            ),
                            feedback: () {},
                            itemCount: _transformationJourneyContent.length,
                            controller: _scrollController,
                            onWillAccept: (oldIndex, newIndex) {
                              setState(
                                () {
                                  pos = newIndex;
                                },
                              );
                              return true;
                            },
                            onReorder: (oldIndex, newIndex) {
                              final tempt =
                                  _transformationJourneyContent[oldIndex];
                              _transformationJourneyContent[oldIndex] =
                                  _transformationJourneyContent[newIndex];
                              _transformationJourneyContent[newIndex] = tempt;
                              setState(() {
                                pos = null;
                              });
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              // childAspectRatio: 3.3 / 4,
                            ),
                            itemBuilder: (context, index) => Opacity(
                              opacity: pos != null
                                  ? pos != index
                                      ? 0.6
                                      : 1
                                  : 1,
                              child: Card(
                                color: Colors.transparent,
                                child: LayoutBuilder(
                                  builder: (context, costrains) {
                                    if (variableSet == 0) {
                                      height = 120;
                                      width = 100;
                                      variableSet++;
                                    }
                                    return ImageAndVideoContainer(
                                      backgroundImage:
                                          _transformationJourneyContent[index]
                                              .thumbnail,
                                      isContentVideo:
                                          _transformationJourneyContent[index]
                                                      .type ==
                                                  FileTypeEnum.video
                                              ? true
                                              : false,
                                      videoUrl:
                                          _transformationJourneyContent[index]
                                              .file,
                                      originalContent:
                                          _transformationJourneyContent[index],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
              ));
  }

  String getTitleForContent(
      {List<TransformationJourneyUpload> uploadListContent}) {
    int _videos = 0;
    int _images = 0;
    uploadListContent.forEach((content) =>
        content.type == FileTypeEnum.video ? _videos += 1 : _images += 1);
    return "Uploaded $_images Images & $_videos Videos";
  }
}
