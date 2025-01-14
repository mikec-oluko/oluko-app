// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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
              child: thirdElementPreview(widget.videoThumbnail.length > 2 ? widget.videoThumbnail[2] : widget.videoThumbnail[0])),
          Visibility(
              visible: widget.videoThumbnail != null && widget.videoThumbnail.length > 1,
              child: secondElementPreview(widget.videoThumbnail.length > 1 ? widget.videoThumbnail[1] : widget.videoThumbnail[0])),
          Visibility(visible: widget.videoThumbnail != null && widget.videoThumbnail.isNotEmpty, child: firstElementPreview(widget.videoThumbnail[0])),
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

  Positioned thirdElementPreview(String imageUrl) {
    final double updatedWidth = _maxWidth - 15;
    return Positioned(
      top: 15,
      child: Center(
        child: Neumorphic(
            style: OlukoNeumorphism.getNeumorphicStyleForStackCardElement(),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: _maxHeight,
              width: updatedWidth,
              maxWidthDiskCache: updatedWidth.toInt(),
              maxHeightDiskCache: _maxHeight.toInt(),
              memCacheWidth: updatedWidth.toInt(),
              memCacheHeight: _maxHeight.toInt(),
              fit: BoxFit.cover,
            )),
      ),
    );
  }

  Positioned secondElementPreview(String imageUrl) {
    final double updatedWidth = _maxWidth - 7.5;
    return Positioned(
      top: 7.5,
      child: Center(
        child: Neumorphic(
            style: OlukoNeumorphism.getNeumorphicStyleForStackCardElement(),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: _maxHeight,
              width: updatedWidth,
              maxWidthDiskCache: updatedWidth.toInt(),
              maxHeightDiskCache: _maxHeight.toInt(),
              memCacheWidth: updatedWidth.toInt(),
              memCacheHeight: _maxHeight.toInt(),
              fit: BoxFit.cover,
            )),
      ),
    );
  }

  Positioned firstElementPreview(String imageUrl) {
    return Positioned(
        top: 0,
        child: Center(
          child: Neumorphic(
            style: OlukoNeumorphism.getNeumorphicStyleForStackCardElement(),
            child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: _maxHeight,
                width: _maxWidth,
                maxWidthDiskCache: (_maxWidth * 2.5).toInt(),
                maxHeightDiskCache: (_maxHeight * 2.5).toInt(),
                memCacheWidth: (_maxWidth * 2.5).toInt(),
                memCacheHeight: (_maxHeight * 2.5).toInt(),
                fit: BoxFit.fitWidth,
                imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) => Stack(
                      children: [
                        Image(
                          image: imageProvider,
                          height: _maxHeight,
                          width: _maxWidth,
                          fit: BoxFit.fitWidth,
                        ),
                        Center(
                          child: playIconButton(),
                        )
                      ],
                    )),
          ),
        ));
  }

  BoxDecoration videoCardDecoration({String image}) {
    return BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: OlukoNeumorphismColors.olukoNeumorphicGreyBackgroundFlat,
        image: DecorationImage(image: getImageToShowOnPreview(image), fit: BoxFit.cover));
  }

  SizedBox playIconButton() {
    return SizedBox(
      width: 45,
      height: 45,
      child: OlukoNeumorphism.isNeumorphismDesign
          ? OlukoBlurredButton(childContent: Image.asset('assets/courses/play_arrow.png', height: 5, width: 5, scale: 4, color: OlukoColors.white))
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
                                    ? CachedNetworkImageProvider(widget.videoThumbnail[0])
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
