import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/oluko_panel_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_transformation_journey_content_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_error_message_view.dart';
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
          : GestureDetector(
              onTap: () {
                _panelController.isPanelOpen
                    ? BlocProvider.of<OlukoPanelBloc>(context).setNewState(
                        action: OlukoPanelAction.close, maxHeight: null)
                    : null;
              },
              child: Container(
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
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10, 100, 10, 10),
                                  child: Text(
                                      getTitleForContent(
                                          uploadListContent:
                                              _transformationJourneyContent),
                                      style: OlukoFonts.olukoBigFont()),
                                )),
                          )
                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 150, 10, 0),
                      child: _contentGallery.length != 0
                          ? Container(
                              height: MediaQuery.of(context).size.height / 1.6,
                              child: GridView.count(
                                crossAxisCount: 3,
                                children: _contentGallery,
                              ),
                            )
                          : Center(
                              child: OlukoErrorMessage(
                              whyIsError: ErrorTypeOption.noContent,
                            )),
                    ),
                    BlocListener<TransformationJourneyContentBloc,
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
                          BlocProvider.of<TransformationJourneyContentBloc>(
                              context)
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
                                TransformationJourneyContentState>(
                            builder: (context, state) {
                          Widget _contentForPanel = SizedBox();
                          if (state is TransformationJourneyContentOpen) {
                            _panelController.open();
                            _contentForPanel = ModalUploadOptions(
                                UploadFrom.transformationJourney);
                          }
                          if (state is TransformationJourneyContentDefault) {
                            _panelController.isPanelOpen
                                ? _panelController.close()
                                : null;
                            _contentForPanel = SizedBox();
                          }
                          if (state is TransformationJourneyContentLoading) {
                            _contentForPanel = UploadingModalLoader(
                                UploadFrom.transformationJourney);
                          }
                          if (state is TransformationJourneyContentSuccess) {
                            _contentForPanel = UploadingModalSuccess(
                                UploadFrom.transformationJourney);
                          }
                          if (state is TransformationJourneyContentFailure) {
                            _panelController.close();
                          }
                          return _contentForPanel;
                        }),
                      ),
                    ),
                  ]),
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
        if (state is TransformationJourneyUploadSuccess) {
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
