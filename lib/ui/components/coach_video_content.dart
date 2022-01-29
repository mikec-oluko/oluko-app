import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';

class CoachVideoContent extends StatefulWidget {
  const CoachVideoContent({this.videoThumbnail, this.isForGallery});
  final List<String> videoThumbnail;
  final bool isForGallery;

  @override
  _CoachVideoContentState createState() => _CoachVideoContentState();
}

class _CoachVideoContentState extends State<CoachVideoContent> {
  final String _useDefaultImage = 'defaultImage';
  final ImageProvider _defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  final double _maxWidth = 150;
  final double _maxHeight = 100;
  @override
  Widget build(BuildContext context) {
    return widget.isForGallery ? galleryContent() : videoContentPreviewStackCards();
  }

  Container videoContentPreviewStackCards() {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
              visible: widget.videoThumbnail != null && widget.videoThumbnail.length > 2,
              child: thirdElementPreview(getImageToShowOnPreview(widget.videoThumbnail[2]))),
          Visibility(
              visible: widget.videoThumbnail != null && widget.videoThumbnail.length > 1,
              child: secondElementPreview(getImageToShowOnPreview(widget.videoThumbnail[1]))),
          Visibility(
              visible: widget.videoThumbnail != null && widget.videoThumbnail.isNotEmpty,
              child: firstElementPreview(getImageToShowOnPreview(widget.videoThumbnail[0]))),
        ],
      ),
    );
  }

  ImageProvider<Object> getImageToShowOnPreview(String imageUrl) {
    if (imageUrl != null && imageUrl != _useDefaultImage) {
      return NetworkImage(imageUrl);
    } else {
      return _defaultImage;
    }
  }

  Positioned thirdElementPreview(ImageProvider<Object> image) {
    return Positioned(
      top: 20,
      child: Center(
        child: Container(
          decoration: videoCardDecoration(image: image),
          width: _maxWidth - 20,
          height: _maxHeight,
        ),
      ),
    );
  }

  Positioned secondElementPreview(ImageProvider<Object> image) {
    return Positioned(
      top: 10,
      child: Center(
        child: Container(
          decoration: videoCardDecoration(image: image),
          width: _maxWidth - 10,
          height: _maxHeight,
        ),
      ),
    );
  }

  Positioned firstElementPreview(ImageProvider<Object> image) {
    return Positioned(
      top: 0,
      child: Center(
        child: Container(
          decoration: videoCardDecoration(image: image),
          width: _maxWidth,
          height: _maxHeight,
          child: Center(child: playIconButton()),
        ),
      ),
    );
  }

  BoxDecoration videoCardDecoration({ImageProvider<Object> image}) {
    return BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat,
        image: DecorationImage(image: image, fit: BoxFit.cover));
  }

  SizedBox playIconButton() {
    return SizedBox(
      width: 45,
      height: 45,
      child: OlukoNeumorphism.isNeumorphismDesign
          ? OlukoBlurredButton(
              childContent: Image.asset('assets/courses/play_arrow.png', height: 5, width: 5, scale: 4, color: OlukoColors.white))
          : SizedBox(
              child: Image.asset(
              'assets/self_recording/play_button.png',
              color: Colors.white,
              height: 15,
              width: 15,
            )),
    );
  }

  Container galleryContent() {
    return Container(
      height: 150,
      width: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: OlukoNeumorphismColors.appBackgroundColor,
      ),
      child: Stack(
        children: [
          Stack(
            children: [
              Align(
                  child: Container(
                      decoration: BoxDecoration(
                          color: OlukoNeumorphismColors.appBackgroundColor,
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          image: DecorationImage(
                            image: widget.videoThumbnail != null && widget.videoThumbnail.isNotEmpty
                                ? widget.videoThumbnail[0] != null
                                    ? NetworkImage(widget.videoThumbnail[0])
                                    : _defaultImage
                                : _defaultImage,
                            fit: BoxFit.cover,
                          )))),
              Align(
                child: SizedBox(
                    child: Image.asset(
                  'assets/self_recording/play_button.png',
                  color: Colors.white,
                  height: 40,
                  width: 40,
                )),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(child: IconButton(icon: const Icon(Icons.close, color: OlukoColors.white), onPressed: () {})),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
