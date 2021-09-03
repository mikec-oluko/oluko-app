import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/ui/screens/courses/segment_clocks.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/timer_utils.dart';

class SegmentCameraPreview extends StatefulWidget {
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int segmentIndex;
  final List<Segment> segments;

  SegmentCameraPreview(
      {Key key,
      this.classIndex,
      this.segmentIndex,
      this.courseEnrollment,
      this.segments})
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
    return form();
  }

  Widget form() {
    return Form(
        key: _formKey,
        child: Scaffold(
            body: Container(
                color: Colors.black,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
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
                                      padding:
                                          EdgeInsets.only(right: 10, top: 15),
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/courses/grey_circle.png',
                                              scale: 4,
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.close,
                                                size: 28,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            )
                                          ])),
                                ])),
                      Expanded(
                          child: Container(
                              width: ScreenUtils.width(context),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: AssetImage(
                                    'assets/courses/dialog_background.png'),
                                fit: BoxFit.cover,
                              )),
                              child: Column(children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 4),
                                    child: Text(
                                        OlukoLocalizations.of(context)
                                            .find('cameraInfo'),
                                        textAlign: TextAlign.center,
                                        style: OlukoFonts.olukoBigFont(
                                            custoFontWeight: FontWeight.w300,
                                            customColor: OlukoColors.white))),
                                startButton(),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 2),
                                    child: Text(
                                        OlukoLocalizations.of(context)
                                            .find('cameraWarning'),
                                        textAlign: TextAlign.center,
                                        style: OlukoFonts.olukoBigFont(
                                            custoFontWeight: FontWeight.w300,
                                            customColor: OlukoColors.primary)))
                              ]))),
                    ],
                  ),
                ))));
  }

  Widget startButton() {
    return GestureDetector(
        onTap: () {
          TimerUtils.startCountdown(
              WorkoutType.segmentWithRecording,
              context,
              getArguments(),
              widget.segments[widget.segmentIndex].initialTimer,
              widget.segments[widget.segmentIndex].rounds,
              1);
        },
        child: Stack(alignment: Alignment.center, children: [
          Image.asset(
            'assets/courses/oval.png',
            scale: 4,
          ),
          Image.asset(
            'assets/courses/green_circle.png',
            scale: 4,
          ),
        ]));
  }

  getArguments() {
    return {
      'segmentIndex': widget.segmentIndex,
      'classIndex': widget.classIndex,
      'courseEnrollment': widget.courseEnrollment,
      'workoutType': WorkoutType.segmentWithRecording,
      'segments': widget.segments,
    };
  }

  Widget formSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'title',
                style: OlukoFonts.olukoSuperBigFont(
                    customColor: OlukoColors.grayColor,
                    custoFontWeight: FontWeight.normal),
              )),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'description',
              style: OlukoFonts.olukoSuperBigFont(
                  customColor: OlukoColors.white,
                  custoFontWeight: FontWeight.normal),
            )),
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
              onTap: () {},
              child: _recording ? recordingIcon() : recordIcon(),
            ),
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