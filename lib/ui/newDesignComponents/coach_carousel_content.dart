import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/image_utils.dart';

class CoachCarouselContent extends StatefulWidget {
  final String contentImage;
  final bool isForPosterContent;
  const CoachCarouselContent({Key key, this.contentImage, this.isForPosterContent = false}) : super(key: key);

  @override
  State<CoachCarouselContent> createState() => _CoachCarouselContentState();
}

class _CoachCarouselContentState extends State<CoachCarouselContent> {
  @override
  Widget build(BuildContext context) {
    return getVideoPreviewCard(image: widget.contentImage, isForPosterContent: widget.isForPosterContent);
  }

  Padding getVideoPreviewCard({bool isForPosterContent = false, @required String image}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: widget.isForPosterContent ? getPosterPreviewCard(image) : contentForVideo(image),
    );
  }

  CourseCard getPosterPreviewCard(String image) {
    return CourseCard(
      width: 120,
      height: 200,
      imageCover: Image(
        image: CachedNetworkImageProvider(
          image,
        ),
        fit: BoxFit.cover,
        frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
            ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 120),
      ),
    );
  }

  Widget contentForVideo(String image) {
    return Neumorphic(
      style: OlukoNeumorphism.getNeumorphicStyleForCardElement(),
      child: Container(
        height: 100,
        width: 160,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)), image: DecorationImage(image: CachedNetworkImageProvider(image), fit: BoxFit.fill)),
        child: Center(
          child: Container(
            width: 50,
            height: 50,
            child: OlukoBlurredButton(
              childContent: Image.asset(
                'assets/self_recording/white_play_arrow.png',
                color: Colors.white,
                height: 50,
                width: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
