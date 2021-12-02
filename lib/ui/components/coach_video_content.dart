import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class CoachVideoContent extends StatefulWidget {
  const CoachVideoContent({this.videoThumbnail, this.isForGallery});
  final List<String> videoThumbnail;
  final bool isForGallery;

  @override
  _CoachVideoContentState createState() => _CoachVideoContentState();
}

class _CoachVideoContentState extends State<CoachVideoContent> {
  final String useDefaultImage = 'defaultImage';
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  @override
  Widget build(BuildContext context) {
    return widget.isForGallery ? galleryContent() : carouselContent();
  }

  Container carouselContent() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: OlukoColors.black,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (widget.videoThumbnail.length > 2)
                Positioned(
                    bottom: 5,
                    child: Container(
                        height: 100,
                        width: 130,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            image: DecorationImage(
                              image: widget.videoThumbnail != null && widget.videoThumbnail.isNotEmpty
                                  ? widget.videoThumbnail.first == useDefaultImage
                                      ? defaultImage
                                      : widget.videoThumbnail.first == useDefaultImage
                                          ? defaultImage
                                          : NetworkImage(
                                              widget.videoThumbnail.length > 2 ? widget.videoThumbnail.first : widget.videoThumbnail.first)
                                  : defaultImage,
                              fit: BoxFit.fill,
                            ))))
              else
                const SizedBox.shrink(),
              if (widget.videoThumbnail.length > 1)
                Positioned(
                    bottom: 10,
                    child: Container(
                        height: 100,
                        width: 140,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            image: DecorationImage(
                              image: widget.videoThumbnail != null && widget.videoThumbnail.isNotEmpty
                                  ? widget.videoThumbnail.length == 2
                                      ? widget.videoThumbnail.first == useDefaultImage
                                          ? defaultImage
                                          : NetworkImage(widget.videoThumbnail.first)
                                      : widget.videoThumbnail[1] == useDefaultImage
                                          ? defaultImage
                                          : NetworkImage(widget.videoThumbnail[1])
                                  : defaultImage,
                              fit: BoxFit.fill,
                            ))))
              else
                const SizedBox.shrink(),
              Positioned(
                  bottom: 15,
                  child: Container(
                      height: 100,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          image: DecorationImage(
                            image: widget.videoThumbnail != null && widget.videoThumbnail.isNotEmpty
                                ? widget.videoThumbnail.last == useDefaultImage
                                    ? defaultImage
                                    : NetworkImage(widget.videoThumbnail.last)
                                : defaultImage,
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
            ],
          ),
        ],
      ),
    );
  }

  Container galleryContent() {
    return Container(
      height: 150,
      width: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: OlukoColors.black,
      ),
      child: Stack(
        children: [
          Stack(
            children: [
              Align(
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          image: DecorationImage(
                            image: widget.videoThumbnail != null && widget.videoThumbnail.isNotEmpty
                                ? widget.videoThumbnail[0] != null
                                    ? NetworkImage(widget.videoThumbnail[0])
                                    : defaultImage
                                : defaultImage,
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
