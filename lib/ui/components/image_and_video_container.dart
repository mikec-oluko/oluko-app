import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';

import 'image_and_video_preview_card.dart';

class ImageAndVideoContainer extends StatefulWidget {
  final String assetImage;
  final bool isVideo;

  ImageAndVideoContainer({this.assetImage, this.isVideo});

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
            fit: BoxFit.fill,
            height: 120,
            width: 120,
          ),
          isVideo: widget.isVideo,
        ),
      ),
    );
  }
}
