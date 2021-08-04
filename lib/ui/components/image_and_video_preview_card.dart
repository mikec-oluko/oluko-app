import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

import '../../routes.dart';

class ImageAndVideoPreviewCard extends StatefulWidget {
  final Image backgroundImage;
  final bool isContentVideo;
  final String videoUrl;
  final bool showTitle;
  final dynamic originalContent;

  ImageAndVideoPreviewCard(
      {this.backgroundImage,
      this.videoUrl,
      this.isContentVideo = false,
      this.showTitle = false,
      this.originalContent});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ImageAndVideoPreviewCard> {
  String titleForPreviewImage = '';
  ChewieController _controller;
  TransformationJourneyUpload transformationJourneyContent;

  @override
  void initState() {
    setState(() {
      if (widget.originalContent is TransformationJourneyUpload) {
        transformationJourneyContent = widget.originalContent;
        titleForPreviewImage = TimeConverter.returnDateAndTimeOnStringFormat(
            dateToFormat: transformationJourneyContent.createdAt);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Stack(children: [
        widget.backgroundImage,
        widget.isContentVideo
            ? Align(
                alignment: Alignment.center,
                child: TextButton(
                    onPressed: () {
                      AppModal.dialogContent(
                          closeButton: true,
                          context: context,
                          content: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: showVideoPlayer(widget.videoUrl),
                            )
                          ]);
                    },
                    child: Image.asset(
                      'assets/assessment/play.png',
                      scale: 5,
                    )))
            : Container(),
        Align(
            alignment: Alignment.bottomCenter,
            child: widget.showTitle
                ? InkWell(
                    onTap: () {
                      if (widget.originalContent
                          is TransformationJourneyUpload) {
                        Navigator.pushNamed(
                            context,
                            routeLabels[
                                RouteEnum.transformationJournetContentDetails],
                            arguments: {
                              'TransformationJourneyUpload':
                                  transformationJourneyContent
                            });
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 30,
                      child: Center(
                        child: Text(
                          titleForPreviewImage,
                          style: OlukoFonts.olukoSmallFont(),
                        ),
                      ),
                    ),
                  )
                : SizedBox())
      ]),
    );
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5,
            minHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: widgets)));
  }
}
