import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/ui/components/three_dots_menu.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_custom_video_player.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import '../../routes.dart';

class ImageAndVideoPreviewCard extends StatefulWidget {
  final Image backgroundImage;
  final bool isContentVideo;
  final String videoUrl;
  final bool showTitle;
  final dynamic originalContent;
  final bool isCoach;
  final bool isCoachMediaContent;
  final bool isEditing;
  final Function() editAction;

  ImageAndVideoPreviewCard(
      {this.backgroundImage,
      this.videoUrl,
      this.isContentVideo = false,
      this.showTitle = false,
      this.originalContent,
      this.isCoach = false,
      this.isCoachMediaContent = false,
      this.isEditing = false,
      this.editAction});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ImageAndVideoPreviewCard> {
  String titleForPreviewImage = '';
  ChewieController _controller;
  TransformationJourneyUpload transformationJourneyContent;
  TaskSubmission taskSubmissionContent;

  @override
  void initState() {
    definePreviewTittleOfTaskSubmission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    definePreviewTitleByTypeOfContent(context);
    return Container(
      alignment: Alignment.center,
      decoration: getDecorationForContainer(),
      width: widget.isCoach ? 150 : 120,
      height: 120,
      child: contentForPreview(context),
    );
  }

  Widget contentForPreview(BuildContext context) {
    Widget _widgetToReturn;
    if (widget.originalContent is TaskSubmission) {
      _widgetToReturn = videoPreview(context);
    } else if (widget.originalContent is TransformationJourneyUpload) {
      _widgetToReturn = widget.isContentVideo ? videoPreview(context) : imagePreview(context);
    } else if (widget.originalContent is CoachMedia) {
      _widgetToReturn = widget.isContentVideo ? videoPreview(context) : imagePreview(context);
    }
    return _widgetToReturn;
  }

  Widget imagePreview(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!widget.isEditing) {
          if (widget.originalContent is TransformationJourneyUpload && widget.showTitle) {
            Navigator.pushNamed(context, routeLabels[RouteEnum.transformationJournetContentDetails],
                arguments: {'TransformationJourneyUpload': transformationJourneyContent});
          }

          if (widget.isCoachMediaContent) {
            Navigator.pushNamed(context, routeLabels[RouteEnum.transformationJournetContentDetails],
                arguments: {'coachMedia': widget.originalContent as CoachMedia});
          }
        }
      },
      child: Align(
          alignment: Alignment.bottomCenter,
          child: widget.showTitle
              ? Container(
                  width: 120,
                  height: widget.isEditing ? 100 : 30,
                  child: Center(
                    child: widget.isEditing
                        ? GestureDetector(
                            onTap: () {
                              if (widget.editAction != null) {
                                widget.editAction();
                              }
                            },
                            child: Image.asset(
                              'assets/neumorphic/bin.png',
                              scale: 3,
                            ),
                          )
                        : Text(
                            titleForPreviewImage != null ? titleForPreviewImage : '',
                            style: OlukoFonts.olukoSmallFont().copyWith(fontSize: 9),
                          ),
                  ),
                )
              : SizedBox()),
    );
  }

  Stack videoPreview(BuildContext context) {
    return Stack(children: [
      Align(
          alignment: Alignment.center,
          child: TextButton(
              onPressed: () {
                //TODO: Change Modal VideoPlayer
                if (widget.isCoachMediaContent) {
                  Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                    'videoUrl': widget.videoUrl,
                    'titleForContent': 'Coach Uploaded Media'
                    // 'titleForContent': OlukoLocalizations.get(context, 'personalizedVideos')
                  });
                } else {
                  widget.showTitle
                      ? AppModal.dialogContent(
                          // closeButton: true,
                          context: context,
                          content: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30),
                                child: showVideoPlayer(widget.videoUrl),
                              ),
                              Container(
                                  child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Image.asset(
                                    'assets/courses/video_cross.png',
                                    color: Colors.white,
                                    height: 80,
                                    width: 80,
                                  ),
                                ),
                              ))
                            ])
                      : SizedBox();
                }
              },
              child: OlukoNeumorphism.isNeumorphismDesign
                  ? Container(
                      width: 50,
                      height: 50,
                      child: OlukoBlurredButton(
                        childContent: Icon(Icons.play_arrow),
                      ),
                    )
                  : Image.asset(
                      'assets/assessment/play.png',
                      scale: 5,
                    ))),
      Align(
          alignment: Alignment.bottomCenter,
          child: widget.showTitle
              ? Container(
                  width: widget.isCoach ? 150 : 120,
                  height: 30,
                  child: Center(
                    child: Text(
                      titleForPreviewImage != null ? titleForPreviewImage : '',
                      style: OlukoFonts.olukoSmallFont(),
                    ),
                  ),
                )
              : SizedBox())
    ]);
  }

  BoxDecoration getDecorationForContainer() {
    final ImageProvider _defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: OlukoColors.black,
        image: DecorationImage(
            opacity: widget.isEditing ? 0.15 : 1,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            image: Image(
              image: widget.backgroundImage.image ?? _defaultImage,
              frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
                  ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 120),
            ).image));
  }

  void definePreviewTitleByTypeOfContent(BuildContext context) {
    setState(() {
      if (widget.originalContent is TransformationJourneyUpload) {
        transformationJourneyContent = widget.originalContent as TransformationJourneyUpload;
        titleForPreviewImage = transformationJourneyContent.createdAt != null
            ? TimeConverter.returnDateAndTimeOnStringFormat(dateToFormat: transformationJourneyContent.createdAt, context: context)
            : '';
      }
    });
  }

  void definePreviewTittleOfTaskSubmission() {
    if (widget.originalContent is TaskSubmission) {
      taskSubmissionContent = widget.originalContent as TaskSubmission;
      titleForPreviewImage = taskSubmissionContent.task.name;
    }
  }

  Widget showVideoPlayer(String videoUrl) {
    return OlukoCustomVideoPlayer(videoUrl: videoUrl, useConstraints: true, autoPlay: false, whenInitialized: (ChewieController chewieController) => {});
  }
}
