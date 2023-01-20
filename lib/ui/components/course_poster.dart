import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoursePoster extends StatefulWidget {
  final String image;

  CoursePoster({this.image});

  @override
  _State createState() => _State();
}

class _State extends State<CoursePoster> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Padding(padding: EdgeInsets.only(top: 40), child: Container(child: Column(children: [classContainer(108.0, 108.0)]))),
    );
  }

  Widget classContainer(double height, double width) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        border: Border.all(
          color: OlukoColors.white,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                child: CachedNetworkImage(
                  imageUrl: widget.image,
                  height: height,
                  width: width,
                  maxWidthDiskCache: (width * 3).toInt(),
                  maxHeightDiskCache: (height * 3).toInt(),
                  memCacheWidth: (width * 3).toInt(),
                  memCacheHeight: (height * 3).toInt(),
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
