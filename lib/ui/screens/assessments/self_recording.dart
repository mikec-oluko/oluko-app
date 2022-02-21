import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/permissions.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/settings_dialog.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/exception_codes.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:photo_manager/photo_manager.dart';

class SelfRecording extends StatefulWidget {
  const SelfRecording({this.taskIndex, this.isPublic, this.isLastTask = false, Key key}) : super(key: key);

  final int taskIndex;
  final bool isPublic;
  final bool isLastTask;

  @override
  _State createState() => _State();
}

class _State extends State<SelfRecording> {
  final _formKey = GlobalKey<FormState>();

  //camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _isReady = false;
  bool _recording = false;
  bool isCameraFront = false;

  bool _buttonBlocked = false;
  Uint8List galleryImage;
  Task _task;
  List<Task> _tasks;
 

  bool flashActivated = false;
  @override
  void initState() {
    firstGalleryVideo();
    super.initState();
    _setupCameras();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, taskState) {
            if (taskState is TaskSuccess) {
              _tasks = taskState.values;
              _task = _tasks[widget.taskIndex];
              return OlukoNeumorphism.isNeumorphismDesign ? NeumorphicForm() : form();
            } else {
              return const SizedBox();
            }
          },
        );
      } else {
        return const SizedBox();
      }
    });
  }

  Widget form() {
    return Form(key: _formKey, child: Scaffold(bottomNavigationBar: bottomBar(), body: cameraContent()));
  }

  Widget NeumorphicForm() {
    return Form(
        key: _formKey,
        child: Scaffold(
            extendBody: true,
            bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0)),
                ),
                height: 100,
                child: bottomBar()),
            body: neumorphicCameraContent()));
  }

  Container cameraContent() {
    return Container(
        color: Colors.black,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: ListView(
            shrinkWrap: true,
            children: [
              ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
                  child: (!_isReady)
                      ? Container()
                      : Stack(alignment: Alignment.topRight, children: [
                          AspectRatio(aspectRatio: 3.0 / 4.0, child: CameraPreview(cameraController)),
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, routeLabels[RouteEnum.taskDetails], arguments: {
                                    'taskIndex': widget.taskIndex,
                                    'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask,
                                    'taskCompleted': true /**TODO: */
                                  });
                                },
                              )),
                        ])),
              OlukoNeumorphism.isNeumorphismDesign ? neumorphicFormSection() : formSection(),
            ],
          ),
        ));
  }

  Container neumorphicCameraContent() {
    return Container(
        color: Colors.black,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 1.1,
          child: Stack(
            children: [
              ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
                  child: (!_isReady)
                      ? Container()
                      : Stack(children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 1.1,
                              child: CameraPreview(cameraController)),
                          Positioned(
                            right: 15,
                            top: 40,
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, routeLabels[RouteEnum.taskDetails], arguments: {
                                    'taskIndex': widget.taskIndex,
                                    'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask,
                                    'taskCompleted': true /**TODO: */
                                  });
                                },
                                child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: OlukoBlurredButton(
                                        childContent: Center(
                                            child: Text(OlukoLocalizations.get(context, 'close'), style: OlukoFonts.olukoSmallFont()))))),
                          ),
                          Positioned(
                            top: 40,
                            left: 15,
                            child: GestureDetector(
                              onTap: () => flashOn(),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: OlukoBlurredButton(
                                  childContent: Image.asset(
                                    'assets/self_recording/white_flash.png',
                                    scale: 3.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ])),
              OlukoNeumorphism.isNeumorphismDesign
                  ? Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Container(width: MediaQuery.of(context).size.width - 40, height: 200, child: neumorphicFormSection()))
                  : formSection(),
            ],
          ),
        ));
  }

  Widget formSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: _task.stepsTitle != null
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    _task.stepsTitle,
                    style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.normal),
                  ))
              : const SizedBox(),
        ),
        if (_task.stepsDescription != null)
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                _task.stepsDescription.replaceAll('\\n', '\n'),
                style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.normal),
              ))
        else
          const SizedBox(),
        const SizedBox(height: 50)
      ],
    );
  }

  Widget neumorphicFormSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: _task.stepsTitle != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          _task.stepsTitle,
                          style: OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.normal),
                        ))
                    : const SizedBox(),
              ),
              if (_task.stepsDescription != null)
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      _task.stepsDescription.replaceAll('\\n', '\n'),
                      style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.normal),
                    ))
              else
                const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

 

  Widget bulletItem() {
    return Container(
      width: 5,
      height: 5,
      decoration: new BoxDecoration(
        color: OlukoColors.yellow,
        shape: BoxShape.circle,
      ),
    );
  }

  Future<void> _setupCameras() async {
    final int cameraPos = isCameraFront ? 0 : 1;
    try {
      if (!await PermissionsUtils.permissionsEnabled(DeviceContentFrom.camera)) {
        Navigator.pop(context);
        PermissionsUtils.showSettingsMessage(context);
        return;
      }
      cameras = await availableCameras();
      cameraController = CameraController(cameras[cameraPos], ResolutionPreset.medium);
      await cameraController.initialize();
    } on CameraException catch (e) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }
//TODO Make service and bloc for the function
  void firstGalleryVideo() async {
    bool firstVideo = false;
    Uint8List galleryVideo;
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
    for (var assetPathEntity in albums) {
      if (!firstVideo) {
        List<AssetEntity> photo = await assetPathEntity.getAssetListPaged(0, 1);
        if (photo[0].duration > 1) {
          galleryVideo = await photo[0].thumbDataWithSize(30, 30);
          setState(() => galleryImage = galleryVideo);
          firstVideo = true;
        }
      }
    }
  }

  Widget _ImageWrapper() {
    if (galleryImage != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          image: DecorationImage(fit: BoxFit.cover, image: MemoryImage(galleryImage)),
        ),
      );
    }
    return const Icon(
      Icons.file_upload,
      size: 30,
      color: OlukoColors.grayColor,
    );
  }

  Widget bottomBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: BottomAppBar(
        color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth : Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              !_recording
                  ? GestureDetector(
                      onTap: () async {
                        setState(() {
                          isCameraFront = !isCameraFront;
                        });
                        _setupCameras();
                      },
                      child: Stack(alignment: Alignment.center, children: [
                        Image.asset(
                          'assets/assessment/camera.png',
                          scale: 4,
                        ),
                        const Icon(
                          Icons.cached,
                          color: OlukoColors.grayColor,
                          size: 18,
                        ),
                      ]))
                  : SizedBox(),
              GestureDetector(
                onTap: () async {
                  if (!_buttonBlocked) {
                    if (_recording) {
                      final XFile videopath = await cameraController.stopVideoRecording();
                      final String path = videopath.path;
                      Navigator.pop(context);
                      Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecordingPreview], arguments: {
                        'taskIndex': widget.taskIndex,
                        'filePath': path,
                        'isPublic': widget.isPublic,
                        'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask
                      });
                    } else {
                      await cameraController.startVideoRecording();
                    }
                    setState(() {
                      _recording = !_recording;
                    });
                  } else {
                    await cameraController.startVideoRecording();
                  }
                },
                child: _recording ? recordingIcon() : recordIcon(),
              ),
              BlocListener<GalleryVideoBloc, GalleryVideoState>(
                  listener: (context, state) {
                    if (state is Success && state.pickedFile != null) {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        routeLabels[RouteEnum.selfRecordingPreview],
                        arguments: {
                          'taskIndex': widget.taskIndex,
                          'filePath': state.pickedFile.path,
                          'isPublic': widget.isPublic,
                          'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask
                        },
                      );
                    } else if (state is PermissionsRequired) {
                      PermissionsUtils.showSettingsMessage(context);
                    }
                  },
                  child: GestureDetector(
                    onTap: () {
                      BlocProvider.of<GalleryVideoBloc>(context).getVideoFromGallery();
                    },
                    child: _ImageWrapper(),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget recordingIcon() {
    return Stack(alignment: Alignment.center, children: [
      Image.asset(
        'assets/self_recording/green_elipse_recording.png',
        scale: 4,
      ),
      Image.asset(
        'assets/self_recording/white_square.png',
        scale: 4,
      ),
    ]);
  }

  Widget recordIcon() {
    return Stack(alignment: Alignment.center, children: [
      Image.asset(
        'assets/self_recording/green_elipse_cam.png',
        scale: 4,
      ),
      Image.asset(
        'assets/self_recording/outlined_circle_cam.png',
        scale: 4,
      ),
      Image.asset(
        'assets/self_recording/white_circle_cam.png',
        scale: 4,
      ),
    ]);
  }

  void flashOn() {
    setState(() {
      if (flashActivated) {
        cameraController.setFlashMode(FlashMode.off);
        flashActivated = false;
      } else {
        cameraController.setFlashMode(FlashMode.torch);
        flashActivated = true;
      }
    });
  }
}
