import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:oluko_app/constants/Theme.dart';

class CardCarousel extends StatefulWidget {
  final List<String> textArray;

  const CardCarousel({
    Key key,
    @required this.textArray,
  }) : super(key: key);

  @override
  _CardCarouselState createState() => _CardCarouselState();
}

class _CardCarouselState extends State<CardCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: widget.textArray
          .map((item) => Container(
              width: MediaQuery.of(context).size.width - 50,
              height: 100,
              child: Card(
                  elevation: 20,
                  child: Center(
                    child: Text(
                      'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                    ),
                  ))))
          .toList(),
      options: CarouselOptions(
          height: 100,
          autoPlay: false,
          enlargeCenterPage: false,
          disableCenter: true,
          enableInfiniteScroll: false,
          initialPage: 0,
          viewportFraction: 0.8,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          }),
    );
  }
}
