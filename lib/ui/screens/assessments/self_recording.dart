import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/routes.dart';

class SelfRecording extends StatefulWidget {
  SelfRecording({this.taskIndex, this.isPublic, Key key}) : super(key: key);

  final int taskIndex;
  final bool isPublic;

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
              return SizedBox();
            }
          },
        );
      } else {
        return SizedBox();
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
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height),
                          child: (!_isReady)
                              ? Container()
                              : Stack(alignment: Alignment.topRight, children: [
                                  AspectRatio(
                                      aspectRatio: 3.0 / 4.0,
                                      child: CameraPreview(cameraController)),
                                  Padding(
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        icon: Icon(
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
                        customColor: OlukoColors.grayColor,
                        custoFontWeight: FontWeight.normal),
                  ))
              : SizedBox(),
        ),
        _task.stepsDescription != null
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${_task.stepsDescription.replaceAll('\\n', '\n')}',
                  style: OlukoFonts.olukoSuperBigFont(
                      customColor: OlukoColors.white,
                      custoFontWeight: FontWeight.normal),
                ))
            : SizedBox(),
        SizedBox(height: 50)
      ],
    );
  }

  Future<void> _setupCameras() async {
    int cameraPos = isCameraFront ? 0 : 1;
    try {
      cameras = await availableCameras();
      cameraController =
          new CameraController(cameras[cameraPos], ResolutionPreset.medium);
      await cameraController.initialize();
    } on CameraException catch (_) {}
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
            GestureDetector(
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
                  Icon(
                    Icons.cached,
                    color: OlukoColors.grayColor,
                    size: 18,
                  ),
                ])),
            GestureDetector(
              onTap: () async {
                if (_recording) {
                  XFile videopath = await cameraController.stopVideoRecording();
                  String path = videopath.path;
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, routeLabels[RouteEnum.selfRecordingPreview],
                      arguments: {
                        'taskIndex': widget.taskIndex,
                        'filePath': path,
                        'isPublic': widget.isPublic,
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
            Image.asset('assets/self_recording/gallery.png', scale: 4),
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
