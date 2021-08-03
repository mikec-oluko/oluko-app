import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_assignment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/models/assessment_assignment.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/screens/assessments/self_recording_preview.dart';

class SelfRecording extends StatefulWidget {
  SelfRecording({this.taskIndex, Key key}) : super(key: key);

  final int taskIndex;

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
  bool isCameraFront = true;

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
            appBar: OlukoAppBar(title: _task.name),
            bottomNavigationBar: BottomAppBar(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 45,
                        ),
                        onPressed: () async {
                          setState(() {
                            isCameraFront = !isCameraFront;
                          });
                          _setupCameras();
                        }),
                    GestureDetector(
                      onTap: () async {
                        if (_recording) {
                          XFile videopath =
                              await cameraController.stopVideoRecording();
                          String path = videopath.path;
                          Navigator.pushNamed(context,
                              routeLabels[RouteEnum.selfRecordingPreview],
                              arguments: {
                                'taskIndex': widget.taskIndex,
                                'filePath': path
                              });
                        } else {
                          await cameraController.startVideoRecording();
                        }
                        setState(() {
                          _recording = !_recording;
                        });
                      },
                      child: _recording
                          ? Image.asset('assets/self_recording/recording.png')
                          : Image.asset('assets/self_recording/record.png'),
                    ),
                    Image.asset('assets/self_recording/gallery.png'),
                  ],
                ),
              ),
            ),
            body: Container(
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ListView(
                        children: [
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 1.6),
                              child: (!_isReady)
                                  ? Container()
                                  : AspectRatio(
                                      aspectRatio: 3.0 / 4.0,
                                      child: CameraPreview(cameraController))),
                          formSection(),
                        ],
                      ),
                    )))));
  }

  Widget formSection() {
    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          formFields(),
        ]));
  }

  Widget formFields() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _task.stepsTitle != null
                  ? TitleBody(_task.stepsTitle)
                  : SizedBox()
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _task.stepsDescription != null
                      ? Text(
                          '${_task.stepsDescription.replaceAll('\\n', '\n')} ',
                          style: TextStyle(fontSize: 20, color: Colors.white60),
                        )
                      : SizedBox(),
                ],
              ),
            ],
          ),
        )
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
}
