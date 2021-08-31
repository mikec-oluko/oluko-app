import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/image_utils.dart';

import 'image_and_video_preview_card.dart';

class ImageAndVideoContainer extends StatefulWidget {
  final String backgroundImage;
  final bool isContentVideo;
  final String videoUrl;
  final ActualProfileRoute displayOnViewNamed;
  final dynamic originalContent;
  final bool isCoach;

  ImageAndVideoContainer(
      {this.backgroundImage,
      this.isContentVideo,
      this.videoUrl,
      this.displayOnViewNamed,
      this.originalContent,
      this.isCoach = false});

  @override
  _ImageAndVideoContainerState createState() => _ImageAndVideoContainerState();
}

class _ImageAndVideoContainerState extends State<ImageAndVideoContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.isCoach ? 150 : 120,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: OlukoColors.black,
        ),
        child: ImageAndVideoPreviewCard(
          backgroundImage: backgroundNetworkImage(),
          videoUrl: widget.videoUrl,
          isContentVideo: widget.isContentVideo,
          showTitle: widget.displayOnViewNamed ==
                  ActualProfileRoute.userAssessmentVideos ||
              widget.displayOnViewNamed ==
                  ActualProfileRoute.transformationJourney,
          originalContent: widget.originalContent,
          isCoach: widget.isCoach,
        ));
  }

  Image backgroundNetworkImage() {
    return Image.network(
      widget.backgroundImage,
      fit: BoxFit.contain,
      frameBuilder: (BuildContext context, Widget child, int frame,
              bool wasSynchronouslyLoaded) =>
          ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded,
              height: widget.isCoach ? 150 : 120, width: 120),
      height: widget.isCoach ? 150 : 120,
      width: 120,
    );
  }
}
