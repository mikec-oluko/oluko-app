import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_update_bloc.dart';
import 'package:oluko_app/blocs/download_assets_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/file_type_enum.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/completed_course_video.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/utils/class_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/segment_clocks_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class CompletedClass extends StatefulWidget {
  final CourseEnrollment courseEnrollment;
  final int classIndex;
  final int courseIndex;

  CompletedClass({Key key, this.courseEnrollment, this.classIndex, this.courseIndex}) : super(key: key);

  @override
  _CompletedClassState createState() => _CompletedClassState();
}

class _CompletedClassState extends State<CompletedClass> {
  User _user;
  XFile _image;
  final imagePicker = ImagePicker();
  String _imageUrl;
  DateTime _date;
  bool newSelfieUploaded;
  bool showVideo = false;

  @override
  void initState() {
    newSelfieUploaded = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.firebaseUser;

        return BlocBuilder<DownloadAssetBloc, DownloadAssetState>(builder: (context, state) {
          if (state is DownloadSuccess && showVideo) {
            showVideo = false;
            return CompletedCourseVideo(
              file: state.videoFile,
              mediaURL: state.videoUrl,
              isDownloaded: state.isDownloaded,
            );
          } else {
            return form();
          }
        });
      } else {
        return SizedBox();
      }
    });
  }

  Widget form() {
    return Scaffold(
        backgroundColor: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker : Colors.black,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView(children: [
                getClassCard(),
                SizedBox(height: 20),
                getCompletedSegments(),
                if (OlukoNeumorphism.isNeumorphismDesign)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: OlukoNeumorphicDivider(isFadeOut: true),
                  )
                else
                  SizedBox(),
                showPhotoFrame(),
                SizedBox(height: ScreenUtils.height(context) * 0.11),
              ]),
            ),
            Positioned(
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: Container(
                  height: ScreenUtils.height(context) * 0.12,
                  color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                  width: ScreenUtils.width(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: OlukoNeumorphicPrimaryButton(
                            isExpanded: false,
                            customHeight: 60,
                            title: OlukoLocalizations.get(context, 'done'),
                            onPressed: () {
                              if (widget.classIndex < widget.courseEnrollment.classes.length - 1) {
                                Navigator.pushNamed(context, routeLabels[RouteEnum.root], arguments: {
                                  'index': widget.courseIndex,
                                  'classIndex': widget.classIndex + 1,
                                });
                              } else {
                                setState(() {
                                  showVideo = true;
                                });
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget showPhotoFrame() {
    return BlocBuilder<CourseEnrollmentUpdateBloc, CourseEnrollmentUpdateState>(builder: (context, courseEnrollmentUpdateState) {
      if (newSelfieUploaded) {
        if (courseEnrollmentUpdateState is SaveSelfieSuccess) {
          _imageUrl = courseEnrollmentUpdateState.courseEnrollment.classes[widget.classIndex].selfieThumbnailUrl;
          newSelfieUploaded = false;
        }
        _date = DateTime.now();
        return getPhotoFrame();
      } else {
        return OlukoNeumorphism.isNeumorphismDesign ? getAddPhotoFrameNeumorphic() : getAddPhotoFrame();
      }
    });
  }

  Widget getCameraIcon() {
    return Padding(
        padding: EdgeInsets.only(right: 5),
        child: GestureDetector(
            onTap: () async {
              showCameraAndSaveSelfie();
            },
            child: Stack(alignment: Alignment.center, children: [
              Image.asset(
                'assets/courses/green_circle.png',
                scale: 8,
              ),
              Icon(Icons.camera_alt_outlined, size: 18, color: OlukoColors.black)
            ])));
  }

  Widget getPhotoFrame() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Stack(alignment: Alignment.center, children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 30, left: 10),
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(-0.01),
                  child: (() {
                    if (newSelfieUploaded) {
                      return Container(
                          height: 153,
                          width: 153,
                          child: Center(
                            child: CircularProgressIndicator(value: null),
                          ));
                    } else {
                      return Container(
                          height: 153,
                          width: 153,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(_imageUrl ?? _image.path),
                            ),
                          ));
                    }
                  })(),
                )),
            Image.asset(
              'assets/courses/neumorphic_empty_frame.png',
              scale: 3,
            )
          ]),
          Padding(
              padding: const EdgeInsets.only(bottom: 45, left: 116),
              child: RotationTransition(
                  turns: AlwaysStoppedAnimation(-0.01),
                  child: Row(children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            DateFormat('MM/dd/yyyy').format(_date).toString(),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.black),
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            DateFormat('hh:mm a').format(_date).toString(),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: OlukoNeumorphism.isNeumorphismDesign ? OlukoColors.grayColor : OlukoColors.black),
                            textAlign: TextAlign.start,
                          )
                        ])),
                    SizedBox(width: 50),
                    getCameraIcon()
                  ]))),
        ]));
  }

  showCameraAndSaveSelfie() async {
    newSelfieUploaded = true;
    return Navigator.pushNamed(context, routeLabels[RouteEnum.selfRecording],
        arguments: {'fromCompletedClass': true, 'classIndex': widget.classIndex, 'courseEnrollment': widget.courseEnrollment});
  }

  Widget getAddPhotoFrame() {
    return GestureDetector(
        onTap: () async {
          showCameraAndSaveSelfie();
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Stack(alignment: Alignment.center, children: [
                Image.asset(
                  'assets/courses/frame.png',
                  scale: 3,
                )
              ]),
              Padding(
                  padding: const EdgeInsets.only(bottom: 33, left: 18),
                  child: RotationTransition(
                      turns: AlwaysStoppedAnimation(-0.01),
                      child: Text(
                        OlukoLocalizations.get(context, 'addYourSelfie'),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: OlukoColors.black),
                        textAlign: TextAlign.start,
                      ))),
            ])));
  }

  Widget getAddPhotoFrameNeumorphic() {
    return GestureDetector(
        onTap: () async {
          showCameraAndSaveSelfie();
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Stack(alignment: Alignment.center, children: [
                Image.asset(
                  'assets/courses/neumorphic_frame.png',
                  scale: 3,
                )
              ]),
            ])));
  }

  Widget getClassCard() {
    return Container(
      height: ScreenUtils.height(context) * 0.35,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoColors.listGrayColor),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 13, top: 17),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 174,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: OlukoColors.challengeLockedFilterColor,
                        image: () {
                          if (widget.courseEnrollment != null &&
                              widget.courseEnrollment.classes[widget.classIndex] != null &&
                              widget.courseEnrollment.classes[widget.classIndex].image != null) {
                            return DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(widget.courseEnrollment.classes[widget.classIndex].image),
                            );
                          } else {
                            final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
                            return DecorationImage(fit: BoxFit.cover, image: defaultImage);
                          }
                        }()),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 0),
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.courseEnrollment.classes[widget.classIndex].name,
                            style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: 11),
                          Text(
                            ClassUtils.toClassProgress(widget.classIndex, widget.courseEnrollment.classes.length, context),
                            style: OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.white),
                          ),
                          Image.asset(
                            'assets/courses/completed_logo.png',
                            scale: 7,
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCompletedSegments() {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Column(children: getSegments()));
  }

  List<Widget> getSegments() {
    List<Widget> segments = [];
    widget.courseEnrollment.classes[widget.classIndex].segments.forEach((segment) {
      segments.add(Row(children: [
        Image.asset(
          'assets/self_recording/completed_tick.png',
          scale: 2.5,
        ),
        SizedBox(width: 10),
        if (OlukoNeumorphism.isNeumorphismDesign)
          SizedBox(
            width: ScreenUtils.width(context) * 0.75,
            child: Text(
              segment.name,
              style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.grayColor),
              textAlign: TextAlign.start,
            ),
          )
        else
          Text(
            segment.name,
            style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
      ]));
      segments.add(SizedBox(height: 5));
    });
    return segments;
  }
}
