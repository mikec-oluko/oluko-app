import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselGallery extends StatefulWidget {
  final List<Widget> items;

  const CarouselGallery({
    Key key,
    @required this.items,
  }) : super(key: key);

  @override
  _CarouselGalleryState createState() => _CarouselGalleryState();
}

class _CarouselGalleryState extends State<CarouselGallery> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: widget.items,
      options: CarouselOptions(
          height: 225,
          autoPlay: false,
          enlargeCenterPage: false,
          disableCenter: false,
          enableInfiniteScroll: false,
          initialPage: 0,
          viewportFraction: 0.32,
          onPageChanged: (index, reason) {
            print("EL INDEX ES:" + index.toString());
          }),
    );
  }
}
