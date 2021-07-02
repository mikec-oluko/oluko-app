import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission_bloc.dart';
import 'package:oluko_app/models/sign_up_response.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/title_body.dart';
import 'package:oluko_app/ui/screens/self_recording_preview.dart';

class SelfRecording extends StatefulWidget {
  SelfRecording({this.task, Key key}) : super(key: key);

  final Task task;

  @override
  _State createState() => _State();
}

class _State extends State<SelfRecording> {
  final _formKey = GlobalKey<FormState>();
  SignUpResponse profileInfo;

  //camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _isReady = false;
  bool _recording = false;
  bool isCameraFront = true;

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
    return BlocProvider(
      create: (context) => TaskBloc()..get(),
      child: form(),
    );
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: OlukoAppBar(title: widget.task.name),
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

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SelfRecordingPreview(
                                      task: widget.task, filePath: path)));
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
                          BlocBuilder<TaskBloc, TaskState>(
                              builder: (context, state) {
                            return formSection();
                          }),
                        ],
                      ),
                    )))));
  }

  Widget formSection() {
    return Container(
      child: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
        return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              formFields(state),
            ]);
      }),
    );
  }

  Widget formFields(TaskState state) {
    if (state is TaskSuccess) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget.task.stepsTitle != null
                    ? TitleBody(widget.task.stepsTitle)
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
                    widget.task.stepsDescription != null
                        ? Text(
                            '${widget.task.stepsDescription.replaceAll('\\n', '\n')} ',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white60),
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          )
        ],
      );
    } else {
      return SizedBox();
    }
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