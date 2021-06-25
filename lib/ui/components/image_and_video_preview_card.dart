import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageAndVideoPreviewCard extends StatefulWidget {
  final Image imageCover;
  final bool isVideo;

  ImageAndVideoPreviewCard({this.imageCover, this.isVideo = false});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ImageAndVideoPreviewCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: 100,
      child: Stack(children: [
        widget.imageCover,
        widget.isVideo == true
            ? Align(
                alignment: Alignment.center,
                child: TextButton(
                    onPressed: () {},
                    child: Image.asset(
                      'assets/assessment/play.png',
                      scale: 5,
                    )))
            : Container(),
      ]),
    );
  }
}
