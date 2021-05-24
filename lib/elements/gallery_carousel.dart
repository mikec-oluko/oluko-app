import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:oluko_app/constants/theme.dart';

class GalleryCarousel extends StatefulWidget {
  final List<Map<String, String>> imgArray;

  const GalleryCarousel({
    Key key,
    @required this.imgArray,
  }) : super(key: key);

  @override
  _GalleryCarouselState createState() => _GalleryCarouselState();
}

class _GalleryCarouselState extends State<GalleryCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: widget.imgArray
          .map((item) => Stack(children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.4),
                                blurRadius: 8,
                                spreadRadius: 0.3,
                                offset: Offset(0, 3))
                          ]),
                          child: AspectRatio(
                            aspectRatio: 2 / 1.25,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                item["img"],
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                color: Colors.black,
                                colorBlendMode: BlendMode.softLight,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace stackTrace) {
                                  return Text('Your error widget...');
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    child: Padding(
                        padding: EdgeInsets.only(top: 90, left: 25, right: 50),
                        child: Column(children: [
                          Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Row(children: [
                                Text(item['title'],
                                    style: TextStyle(
                                        color: OlukoColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25.0)),
                              ])),
                        ])))
              ]))
          .toList(),
      options: CarouselOptions(
          height: 260,
          autoPlay: false,
          enlargeCenterPage: false,
          disableCenter: true,
          enableInfiniteScroll: false,
          initialPage: 0,
          viewportFraction: 1,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          }),
    );
  }
}
