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
  final String titleForContent;
  final bool isForPosterContent;
  final Function() onTapContent;
  const CoachCarouselContent({Key key, this.contentImage, this.titleForContent, this.onTapContent, this.isForPosterContent = false}) : super(key: key);

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
      child: widget.isForPosterContent
          ? GestureDetector(onTap: () => widget.onTapContent() ?? () {}, child: getPosterPreviewCard(image))
          : GestureDetector(onTap: () => widget.onTapContent() ?? () {}, child: contentForVideo(image)),
    );
  }

  CourseCard getPosterPreviewCard(String image) {
    return CourseCard(
      width: 120,
      height: 200,
      imageCover: Image(
        image: CachedNetworkImageProvider(
          image,
          maxHeight: 200,
          maxWidth: 120,
        ),
        fit: BoxFit.cover,
        frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
            ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded),
      ),
    );
  }

  Widget contentForVideo(String image) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Neumorphic(
          style: OlukoNeumorphism.getNeumorphicStyleForCardElement(),
          child: Container(
            height: 100,
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Stack(
              children: [
                Image(
                  image: CachedNetworkImageProvider(
                    image,
                    maxHeight: 100,
                    maxWidth: 120,
                  ),
                  width: 160,
                  fit: BoxFit.cover,
                  frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
                      ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded),
                ),
                Center(
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
                )
              ],
            ),
          ),
        ),
        if (widget.titleForContent != null)
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              widget.titleForContent,
              style: OlukoFonts.olukoSmallFont(customColor: Colors.white),
            ),
          )
        else
          const SizedBox.shrink()
      ],
    );
  }
}
