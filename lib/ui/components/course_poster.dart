import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';

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
      child: Padding(padding: EdgeInsets.only(top: 40), child: Container(child: Column(children: [classContainer(140.0, 108.0)]))),
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
                child: Image(
                  image: CachedNetworkImageProvider(widget.image),
                  height: height,
                  width: width,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.white,
                    height: height,
                    width: width,
                    child: Image.asset(
                      'assets/home/mvtthumbnail.png',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
