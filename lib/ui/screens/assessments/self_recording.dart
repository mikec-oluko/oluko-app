import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/open_settings_modal.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/exception_codes.dart';

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
              return form();
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
    return Form(
        key: _formKey,
        child: Scaffold(
            bottomNavigationBar: bottomBar(),
            body: Container(
                color: Colors.black,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
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
                                        onPressed: () => Navigator.pop(context),
                                      )),
                                ])),
                      formSection(),
                    ],
                  ),
                ))));
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
                    style: OlukoFonts.olukoSuperBigFont(
                        customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.normal),
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

  Future<void> _setupCameras() async {
    final int cameraPos = isCameraFront ? 0 : 1;
    try {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[cameraPos], ResolutionPreset.medium);
      await cameraController.initialize();
    } on CameraException catch (e) {
      if (e.code == ExceptionCodes.cameraPermissionError) {
        Navigator.pop(context);
        DialogUtils.getDialog(context, [OpenSettingsModal(context)], showExitButton: false);
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _isReady = true;
    });
  }

  Widget bottomBar() {
    return BottomAppBar(
      color: Colors.black,
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
                if (_recording) {
                  final XFile videopath = await cameraController.stopVideoRecording();
                  final String path = videopath.path;
                  Navigator.pop(context);
                  //TODO: Send flag to set assesment as last upload
                  Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecordingPreview], arguments: {
                    'taskIndex': widget.taskIndex,
                    'filePath': path,
                    'isPublic': widget.isPublic,
                    'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : !widget.isLastTask
                  });
                } else {
                  await cameraController.startVideoRecording();
                }
                setState(() {
                  _recording = !_recording;
                });
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
                      'isLastTask': _tasks.length - widget.taskIndex == 1 ? true : !widget.isLastTask
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
