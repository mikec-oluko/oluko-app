import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/permissions.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/settings_dialog.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/exception_codes.dart';
import 'package:oluko_app/utils/permissions_utils.dart';

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

  Task _task;
  List<Task> _tasks;

  @override
  void initState() {
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
                      : Stack(alignment: Alignment.topRight, children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 1.1,
                              child: CameraPreview(cameraController)),
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
          child: Container(
            child: Column(
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
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setupCameras() async {
    final int cameraPos = isCameraFront ? 0 : 1;
    try {
      if (!await Permissions.requiredPermissionsEnabled(DeviceContentFrom.camera)) {
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
                      Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecordingPreview], arguments: {
                        'taskIndex': widget.taskIndex,
                        'filePath': state.pickedFile.path,
                        'isPublic': widget.isPublic,
                        'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : widget.isLastTask
                      });
                    }
                  },
                  child: GestureDetector(
                    onTap: () {
                      BlocProvider.of<GalleryVideoBloc>(context).getVideoFromGallery();
                    },
                    child: const Icon(
                      Icons.file_upload,
                      size: 30,
                      color: OlukoColors.grayColor,
                    ),
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
        'assets/self_recording/red_ellipse.png',
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
        'assets/self_recording/white_ellipse.png',
        scale: 4,
      ),
      Image.asset(
        'assets/self_recording/white_filled_ellipse.png',
        scale: 4,
      ),
    ]);
  }
}
