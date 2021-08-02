import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/image_utils.dart';

import 'image_and_video_preview_card.dart';

class ImageAndVideoContainer extends StatefulWidget {
  final String assetImage;
  final bool isVideo;
  final String videoUrl;
  final ActualProfileRoute displayOn;

  ImageAndVideoContainer(
      {this.assetImage, this.isVideo, this.videoUrl, this.displayOn});

  @override
  _ImageAndVideoContainerState createState() => _ImageAndVideoContainerState();
}

class _ImageAndVideoContainerState extends State<ImageAndVideoContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        height: 120,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: OlukoColors.black,
        ),
        child: ImageAndVideoPreviewCard(
          imageCover: Image.asset(
            widget.assetImage,
            fit: BoxFit.contain,
            height: 120,
            width: 120,
          ),
          videoUrl: widget.videoUrl,
          isVideo: widget.isVideo,
          showTitle:
              widget.displayOn == ActualProfileRoute.userAssessmentVideos,
        ),
      ),
    );
  }
}
