import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/profile/upload_transformation_journey_content_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
import 'package:oluko_app/ui/components/modal_exception_message.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/components/modal_upload_options.dart';
import 'package:oluko_app/ui/components/uploading_modal_loader.dart';
import 'package:oluko_app/ui/components/uploading_modal_success.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileTransformationJourneyPage extends StatefulWidget {
  final UserResponse userRequested;
  bool viewAllPage;
  ProfileTransformationJourneyPage({Key key, this.userRequested, this.viewAllPage = false}) : super(key: key);
  @override
  _ProfileTransformationJourneyPageState createState() => _ProfileTransformationJourneyPageState();
}

class _ProfileTransformationJourneyPageState extends State<ProfileTransformationJourneyPage> {
  bool isCurrenUser = false;
  UserResponse userToUse;
  int _variableSet = 0;
  double width;
  double height;
  int _position;
  ScrollController _scrollController;
  List<Widget> _contentGallery;
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  UserResponse _profileInfo;
  final PanelController _panelController = PanelController();
  double _panelMaxHeight = 100.0;
  double _statePanelMaxHeight = 100.0;
  bool canHidePanel = true;
  bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthSuccess) {
        BlocProvider.of<GalleryVideoBloc>(context).getFirstImageFromGalley();
        _profileInfo = state.user;
        if (widget.userRequested.id == _profileInfo.id) {
          isCurrenUser = true;
          userToUse = _profileInfo;
        } else {
          userToUse = widget.userRequested;
        }
        return transformationJourneyView();
      } else {
        return SizedBox();
      }
    });
  }

  Scaffold page(BuildContext context, UserResponse profileInfo) {
    return Scaffold(
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      appBar: OlukoAppBar(
        centerTitle: true,
        showTitle: true,
        showBackButton: true,
        title: widget.viewAllPage ? '' : OlukoLocalizations.get(context, 'transformation'),
        showSearchBar: false,
      ),
      body: _contentGallery == null
          ? Container(color: OlukoNeumorphismColors.appBackgroundColor, child: OlukoCircularProgressIndicator())
          : Container(
              constraints: const BoxConstraints.expand(),
              color: OlukoNeumorphismColors.appBackgroundColor,
              child: SafeArea(
                child: Stack(alignment: OlukoNeumorphism.isNeumorphismDesign ? AlignmentDirectional.center : AlignmentDirectional.topStart, children: [
                  if (isCurrenUser && !widget.viewAllPage)
                    Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Container(
                            width: OlukoNeumorphism.isNeumorphismDesign ? ScreenUtils.width(context) * 0.85 : MediaQuery.of(context).size.width,
                            decoration: OlukoNeumorphism.isNeumorphismDesign
                                ? const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)), color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker)
                                : const BoxDecoration(),
                            child: OlukoNeumorphism.isNeumorphismDesign
                                ? GestureDetector(
                                    onTap: () {
                                      BlocProvider.of<TransformationJourneyContentBloc>(context).openPanel();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: OlukoColors.primary),
                                          color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                                          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                'assets/profile/plus.png',
                                                scale: 5,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10.0),
                                                child: Text(
                                                  OlukoLocalizations.get(context, 'upload'),
                                                  style: OlukoFonts.olukoBigFont(customColor: OlukoColors.primary),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Row(
                                        children: [
                                          OlukoOutlinedButton(
                                              title: OlukoLocalizations.get(context, 'upload'),
                                              onPressed: () {
                                                BlocProvider.of<TransformationJourneyContentBloc>(context).openPanel();
                                              }),
                                        ],
                                      ),
                                    )),
                          ),
                        ))
                  else
                    const SizedBox(),
                  if (_contentGallery.isNotEmpty)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: widget.viewAllPage
                            ? const EdgeInsets.fromLTRB(30, 20, 10, 10)
                            : isCurrenUser
                                ? const EdgeInsets.fromLTRB(30, 110, 30, 10)
                                : const EdgeInsets.fromLTRB(10, 20, 10, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.viewAllPage
                                  ? ProfileViewConstants.profileOptionsTransformationPhotos
                                  : getTitleForContent(uploadListContent: _transformationJourneyContent),
                              style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.bold),
                            ),
                            if (isCurrenUser)
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isEdit = !isEdit;
                                    });
                                  },
                                  child: Text(OlukoLocalizations.get(context, 'editContent'),
                                      style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.bold, customColor: OlukoColors.primary))),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                  if (_contentGallery.isNotEmpty) dragAndDropGridView(context) else const SizedBox(),
                  slidingUpPanelComponent(context),
                ]),
              ),
            ),
    );
  }

  Widget slidingUpPanelComponent(BuildContext context) {
    Widget _contentForPanel = const SizedBox();
    return BlocConsumer<TransformationJourneyContentBloc, TransformationJourneyContentState>(
      listener: (context, state) {
        if (state is TransformationJourneyContentDefault || state is TransformationJourneyContentOpen) {
          _statePanelMaxHeight = _panelMaxHeight;
        } else {
          if (state is TransformationJourneyContentDelete) {
            _statePanelMaxHeight = 120;
          } else {
            _statePanelMaxHeight = 300;
          }
        }
        if (state is TransformationJourneyContentOpen) {
          _panelController.open();
          _contentForPanel = ModalUploadOptions(
            contentFrom: UploadFrom.transformationJourney,
            indexValue: _transformationJourneyContent.length,
          );
        }
        if (state is TransformationJourneyContentDelete) {
          _panelController.open();
          _contentForPanel = ModalUploadOptions(
            deleteAction: () => BlocProvider.of<TransformationJourneyBloc>(context).markContentAsDeleted(_profileInfo.id, state.elementToMarkAsDelete),
            deleteCancelAction: () => BlocProvider.of<TransformationJourneyContentBloc>(context).emitDefaultState(),
            isDeleteRequested: true,
          );
        }
        if (state is TransformationJourneyContentDefault) {
          _panelController.isPanelOpen ? _panelController.close() : null;
          _contentForPanel = const SizedBox();
        }
        if (state is TransformationJourneyContentLoading) {
          canHidePanel = !canHidePanel;
          _contentForPanel = UploadingModalLoader(UploadFrom.transformationJourney);
        }
        if (state is TransformationJourneyContentSuccess) {
          canHidePanel = !canHidePanel;
          _contentForPanel = UploadingModalSuccess(goToPage: UploadFrom.transformationJourney, userRequested: userToUse);
        }
        if (state is TransformationJourneyContentFailure) {
          _statePanelMaxHeight = _panelMaxHeight;
          _contentForPanel = ModalExceptionMessage(
              exceptionType: state.exceptionType,
              onPress: () => _panelController.isPanelOpen ? _panelController.close() : null,
              exceptionSource: state.exceptionSource);
        }
        if (state is TransformationJourneyRequirePermissions) {
          _panelController.close().then((value) => PermissionsUtils.showSettingsMessage(context, permissionsRequired: [state.permissionRequired]));
        }
      },
      builder: (context, state) {
        return SlidingUpPanel(
          onPanelClosed: () {
            if (state is! TransformationJourneyContentDelete && (state is! TransformationJourneyContentOpen)) {
              BlocProvider.of<TransformationJourneyContentBloc>(context).emitDefaultState();
              BlocProvider.of<TransformationJourneyBloc>(context).emitTransformationJourneyDefault();
            }
          },
          backdropEnabled: canHidePanel,
          isDraggable: false,
          margin: EdgeInsets.all(0),
          header: const SizedBox(),
          padding: EdgeInsets.zero,
          color: OlukoColors.black,
          minHeight: 0.0,
          maxHeight: _statePanelMaxHeight,
          collapsed: const SizedBox(),
          controller: _panelController,
          panel: _contentForPanel,
          borderRadius:
              OlukoNeumorphism.isNeumorphismDesign ? BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)) : BorderRadius.zero,
        );
      },
    );
  }

  Align dragAndDropGridView(BuildContext context) {
    return Align(
      child: Padding(
        padding: widget.viewAllPage
            ? EdgeInsets.only(top: 60)
            : isCurrenUser
                ? const EdgeInsets.only(top: 150)
                : const EdgeInsets.only(top: 20),
        child: Container(
          padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10) : EdgeInsets.all(0),
          decoration: OlukoNeumorphism.isNeumorphismDesign
              ? const BoxDecoration(
                  color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                )
              : const BoxDecoration(),
          width: OlukoNeumorphism.isNeumorphismDesign ? ScreenUtils.width(context) * 0.86 : ScreenUtils.width(context),
          height: MediaQuery.of(context).size.height / 1.4,
          child: isCurrenUser
              ? DragAndDropGridView(
                  physics: ClampingScrollPhysics(),
                  isCustomChildWhenDragging: true,
                  childWhenDragging: (pos) => Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                        border: Border.all(
                          width: 2.0,
                          color: OlukoColors.grayColor,
                        )),
                  ),
                  itemCount: _transformationJourneyContent.length,
                  controller: _scrollController,
                  onWillAccept: (int oldIndex, int newIndex) {
                    setState(
                      () {
                        _position = newIndex;
                      },
                    );
                    return true;
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    if (isCurrenUser) {
                      BlocProvider.of<TransformationJourneyBloc>(context)
                          .changeContentOrder(_transformationJourneyContent[oldIndex], _transformationJourneyContent[newIndex], _profileInfo.id);

                      final elementMoved = _transformationJourneyContent[oldIndex];
                      _transformationJourneyContent[oldIndex] = _transformationJourneyContent[newIndex];

                      _transformationJourneyContent[newIndex] = elementMoved;
                      if (_position != null) {
                        setState(() {
                          _position = null;
                        });
                      }
                    }
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              backgroundImage: _transformationJourneyContent[index].thumbnail,
                              isContentVideo: _transformationJourneyContent[index].type == FileTypeEnum.video ? true : false,
                              videoUrl: _transformationJourneyContent[index].file,
                              displayOnViewNamed: ActualProfileRoute.transformationJourney,
                              originalContent: _transformationJourneyContent[index],
                              isEdit: isEdit,
                              editAction: () =>
                                  BlocProvider.of<TransformationJourneyContentBloc>(context).markContentAsDelete(_transformationJourneyContent[index]));
                        },
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  physics: ClampingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: _transformationJourneyContent.length,
                  itemBuilder: (context, index) => Card(
                      color: Colors.transparent,
                      child: ImageAndVideoContainer(
                          backgroundImage: _transformationJourneyContent[index].thumbnail,
                          isContentVideo: _transformationJourneyContent[index].type == FileTypeEnum.video ? true : false,
                          videoUrl: _transformationJourneyContent[index].file,
                          displayOnViewNamed: ActualProfileRoute.transformationJourney,
                          originalContent: _transformationJourneyContent[index],
                          isEdit: isEdit,
                          editAction: () =>
                              BlocProvider.of<TransformationJourneyContentBloc>(context).markContentAsDelete(_transformationJourneyContent[index]))),
                ),
        ),
      ),
    );
  }

  BlocBuilder<TransformationJourneyBloc, TransformationJourneyState> transformationJourneyView() {
    return BlocBuilder<TransformationJourneyBloc, TransformationJourneyState>(
      builder: (context, state) {
        if (state is TransformationJourneySuccess) {
          _transformationJourneyContent = state.contentFromUser;
          _contentGallery = TransformListOfItemsToWidget.getWidgetListFromContent(
            tansformationJourneyData: _transformationJourneyContent,
            requestedFromRoute: ActualProfileRoute.transformationJourney,
          );
        }
        if (state is TransformationJourneyFailure || state is TransformationJourneyDefault) {
          BlocProvider.of<TransformationJourneyBloc>(context).getContentByUserId(userToUse.id);
        }
        if (state is TransformationJourneyDeleteSuccess) {
          BlocProvider.of<TransformationJourneyBloc>(context).getContentByUserId(userToUse.id);
          BlocProvider.of<TransformationJourneyContentBloc>(context).emitDefaultState();
        }
        return page(context, _profileInfo);
      },
    );
  }

  String getTitleForContent({List<TransformationJourneyUpload> uploadListContent}) {
    int _videos = 0;
    int _images = 0;
    uploadListContent.forEach((content) => content.type == FileTypeEnum.video ? _videos += 1 : _images += 1);
    return 'Uploaded $_images Images & $_videos Videos';
  }
}
