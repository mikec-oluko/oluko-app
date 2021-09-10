import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CoachCarouselSliderSection extends StatefulWidget {
  final List<Widget> contentForCarousel;
  const CoachCarouselSliderSection({this.contentForCarousel});

  @override
  _CoachCarouselSliderSectionState createState() =>
      _CoachCarouselSliderSectionState();
}

class _CoachCarouselSliderSectionState
    extends State<CoachCarouselSliderSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      height: 250,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(35, 20, 35, 20),
            child: CarouselSlider(
              items: widget.contentForCarousel,
              options: CarouselOptions(
                  aspectRatio: 5.4,
                  viewportFraction: 0.7,
                  height: 250.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true),
            ),
          )
          //Video if first time
          // Align(
          //     alignment: Alignment.center,
          //     child: showVideoPlayer(_assessment.video)),
        ],
      ),
    );
  }
}
