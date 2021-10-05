import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class CoachVideoContent extends StatefulWidget {
  const CoachVideoContent({this.videoThumbnail, this.isForGallery});
  final String videoThumbnail;
  final bool isForGallery;

  @override
  _CoachVideoContentState createState() => _CoachVideoContentState();
}

class _CoachVideoContentState extends State<CoachVideoContent> {
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
              Positioned(
                  bottom: 5,
                  child: Container(
                      height: 100,
                      width: 130,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          image: DecorationImage(
                            image: NetworkImage(widget.videoThumbnail),
                            fit: BoxFit.fill,
                          )))),
              Positioned(
                  bottom: 10,
                  child: Container(
                      height: 100,
                      width: 140,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          image: DecorationImage(
                            image: NetworkImage(widget.videoThumbnail),
                            fit: BoxFit.fill,
                          )))),
              Positioned(
                  bottom: 15,
                  child: Container(
                      height: 100,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          image: DecorationImage(
                            image: NetworkImage(widget.videoThumbnail),
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
                            image: NetworkImage(widget.videoThumbnail),
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
                child: SizedBox(child: IconButton(icon: Icon(Icons.close, color: OlukoColors.white), onPressed: () {})),
              ),
            ],
          ),
        ],
      ),
    );
  }
}