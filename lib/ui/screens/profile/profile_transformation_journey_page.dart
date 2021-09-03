import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_transformation_journey_content_bloc.dart';
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
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/modal_upload_options.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/components/uploading_modal_success.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileTransformationJourneyPage extends StatefulWidget {
  @override
  _ProfileTransformationJourneyPageState createState() =>
      _ProfileTransformationJourneyPageState();
}

class _ProfileTransformationJourneyPageState
    extends State<ProfileTransformationJourneyPage> {
  int _variableSet = 0;
  double width;
  double height;
  int _position;
  ScrollController _scrollController;
  List<Widget> _contentGallery;
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  UserResponse _profileInfo;
  final PanelController _panelController = new PanelController();
  double _panelMaxHeight = 100.0;
  double _statePanelMaxHeight = 100.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        _profileInfo = state.user;
        return transformationJourneyView();
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
                                      BlocProvider.of<
                                                  TransformationJourneyContentBloc>(
                                              context)
                                          .openPanel();
                                    }),
                              ],
                            ),
                          ))),
                  _contentGallery.length != 0
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 100, 10, 10),
                            child: Text(
                              getTitleForContent(
                                  uploadListContent:
                                      _transformationJourneyContent),
                              style: OlukoFonts.olukoBigFont(),
                            ),
                          ),
                        )
                      : SizedBox(),
                  _contentGallery.length != 0
                      ? dragAndDropGridView(context)
                      : SizedBox(),
                  slidingUpPanelComponent(context),
                ]),
              ),
            ),
    );
  }

  BlocListener<TransformationJourneyContentBloc,
          TransformationJourneyContentState>
      slidingUpPanelComponent(BuildContext context) {
    return BlocListener<TransformationJourneyContentBloc,
        TransformationJourneyContentState>(
      listener: (context, state) {
        if (state is TransformationJourneyContentDefault ||
            state is TransformationJourneyContentOpen) {
          _statePanelMaxHeight = 100;
        } else {
          _statePanelMaxHeight = 300;
        }
      },
      child: SlidingUpPanel(
        onPanelOpened: () {
          setState(() {
            _panelMaxHeight = _statePanelMaxHeight;
          });
        },
        onPanelClosed: () {
          BlocProvider.of<TransformationJourneyContentBloc>(context)
            ..emitDefaultState();
        },
        backdropEnabled: true,
        isDraggable: false,
        margin: const EdgeInsets.all(0),
        header: SizedBox(),
        backdropTapClosesPanel: true,
        padding: EdgeInsets.zero,
        color: OlukoColors.black,
        minHeight: 0.0,
        maxHeight: _panelMaxHeight,
        collapsed: SizedBox(),
        defaultPanelState: PanelState.CLOSED,
        controller: _panelController,
        panel: BlocBuilder<TransformationJourneyContentBloc,
            TransformationJourneyContentState>(builder: (context, state) {
          Widget _contentForPanel = SizedBox();
          if (state is TransformationJourneyContentOpen) {
            _panelController.open();
            _contentForPanel = ModalUploadOptions(
              contentFrom: UploadFrom.transformationJourney,
              indexValue: _transformationJourneyContent.length,
            );
          }
          if (state is TransformationJourneyContentDefault) {
            _panelController.isPanelOpen ? _panelController.close() : null;
            _contentForPanel = SizedBox();
          }
          if (state is TransformationJourneyContentLoading) {
            _contentForPanel =
                UploadingModalLoader(UploadFrom.transformationJourney);
          }
          if (state is TransformationJourneyContentSuccess) {
            _contentForPanel = UploadingModalSuccess(
                goToPage: UploadFrom.transformationJourney);
          }
          if (state is TransformationJourneyContentFailure) {
            _panelController.close();
          }
          return _contentForPanel;
        }),
      ),
    );
  }

  Align dragAndDropGridView(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 150),
        child: Container(
          height: MediaQuery.of(context).size.height / 1.4,
          child: DragAndDropGridView(
            isCustomChildWhenDragging: true,
            childWhenDragging: (pos) => Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  border: Border.all(
                    width: 2.0,
                    color: OlukoColors.grayColor,
                  )),
            ),
            itemCount: _transformationJourneyContent.length,
            controller: _scrollController,
            onWillAccept: (oldIndex, newIndex) {
              setState(
                () {
                  _position = newIndex;
                },
              );
              return true;
            },
            onReorder: (oldIndex, newIndex) {
              BlocProvider.of<TransformationJourneyBloc>(context)
                ..changeContentOrder(_transformationJourneyContent[oldIndex],
                    _transformationJourneyContent[newIndex], _profileInfo.id);

              final elementMoved = _transformationJourneyContent[oldIndex];
              _transformationJourneyContent[oldIndex] =
                  _transformationJourneyContent[newIndex];

              _transformationJourneyContent[newIndex] = elementMoved;

              setState(() {
                _position = null;
              });
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) => Opacity(
              opacity: _position != null
                  ? _position != index
                      ? 0.6
                      : 1
                  : 1,
              child: Card(
                color: Colors.transparent,
                child: LayoutBuilder(
                  builder: (context, costrains) {
                    if (_variableSet == 0) {
                      height = 120;
                      width = 100;
                      _variableSet++;
                    }
                    return ImageAndVideoContainer(
                      backgroundImage:
                          _transformationJourneyContent[index].thumbnail,
                      isContentVideo:
                          _transformationJourneyContent[index].type ==
                                  FileTypeEnum.video
                              ? true
                              : false,
                      videoUrl: _transformationJourneyContent[index].file,
                      displayOnViewNamed:
                          ActualProfileRoute.transformationJourney,
                      originalContent: _transformationJourneyContent[index],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BlocBuilder<TransformationJourneyBloc, TransformationJourneyState>
      transformationJourneyView() {
    return BlocBuilder<TransformationJourneyBloc, TransformationJourneyState>(
      builder: (context, state) {
        if (state is TransformationJourneySuccess) {
          _transformationJourneyContent = state.contentFromUser;
          _contentGallery =
              TransformListOfItemsToWidget.getWidgetListFromContent(
                  tansformationJourneyData: _transformationJourneyContent,
                  requestedFromRoute: ActualProfileRoute.transformationJourney);
        }
        if (state is TransformationJourneyFailure ||
            state is TransformationJourneyDefault) {
          BlocProvider.of<TransformationJourneyBloc>(context)
            ..getContentByUserId(_profileInfo.id);
        }
        return page(context, _profileInfo);
      },
    );
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
