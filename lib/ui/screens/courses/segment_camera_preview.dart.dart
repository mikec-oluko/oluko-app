import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/recording_alert_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/permissions_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/timer_utils.dart';

class SegmentCameraPreview extends StatefulWidget {
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int currentTaskIndex;
  final int segmentIndex;
  final List<Segment> segments;
  final int courseIndex;
  final UserResponse coach;

  SegmentCameraPreview({Key key, this.coach, this.courseIndex, this.classIndex, this.segmentIndex, this.courseEnrollment, this.segments, this.currentTaskIndex})
      : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<SegmentCameraPreview> {
  final _formKey = GlobalKey<FormState>();

  //camera
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _isReady = false;
  bool _recording = false;
  bool isCameraFront = false;
  UserResponse _user;

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
        _user = authState.user;
        return form();
      } else {
        return SizedBox();
      }
    });
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
          bottomSheet: bottomPanel(),
          body: Stack(
            children: [
              cameraSection(),
            ],
          ),
        ));
  }

  Widget cameraSection() {
    return (!_isReady)
        ? Container()
        : Stack(alignment: Alignment.topRight, children: [
            AspectRatio(aspectRatio: 3.0 / 4.0, child: CameraPreview(cameraController)),
            closeButton(),
          ]);
  }

  Widget closeButton() {
    return Padding(
        padding: const EdgeInsets.only(right: 10, top: 55),
        child: Stack(alignment: Alignment.center, children: [
          Image.asset(
            'assets/courses/grey_circle.png',
            scale: 4,
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 28,
              color: Colors.grey,
            ),
            onPressed: () => Navigator.pop(context),
          )
        ]));
  }

  Widget bottomPanel() {
    return Container(
        height: 240,
        width: ScreenUtils.width(context),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            image: DecorationImage(
              image: AssetImage('assets/courses/dialog_background.png'),
              fit: BoxFit.cover,
            )),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(OlukoLocalizations.of(context).find('cameraInfo'),
                  textAlign: TextAlign.left, style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w600, customColor: OlukoColors.white)),
              startButton(),
              Text(OlukoLocalizations.of(context).find('cameraWarning'),
                  textAlign: TextAlign.left, style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.primary))
            ])));
  }

  Widget startButton() {
    return GestureDetector(
        onTap: () {
          TimerUtils.startCountdown(WorkoutType.segmentWithRecording, context, getArguments(), widget.segments[widget.segmentIndex].initialTimer);
        },
        child: recordIcon());
  }

  Object getArguments() {
    return {
      'segmentIndex': widget.segmentIndex,
      'classIndex': widget.classIndex,
      'courseEnrollment': widget.courseEnrollment,
      'courseIndex': widget.courseIndex,
      'coach': widget.coach,
      'workoutType': WorkoutType.segmentWithRecording,
      'segments': widget.segments,
      'showPanel': _user.showRecordingAlert,
      'onShowAgainPressed': () {
        BlocProvider.of<RecordingAlertBloc>(context).updateRecordingAlert(_user);
      },
      'currentTaskIndex': widget.currentTaskIndex,
    };
  }

  Future<void> _setupCameras() async {
    final int cameraPos = isCameraFront ? 0 : 1;
    try {
      if (!await PermissionsUtils.permissionsEnabled(DeviceContentFrom.camera)) {
        Navigator.pop(context);
        PermissionsUtils.showSettingsMessage(context, permissionsRequired: [DeviceContentFrom.camera.name, DeviceContentFrom.microphone.name]);
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

  Widget recordIcon() {
    return Stack(alignment: Alignment.center, children: [
      Image.asset(
        'assets/neumorphic/button_shade.png',
        scale: 4,
      ),
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
}
