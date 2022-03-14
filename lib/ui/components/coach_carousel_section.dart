import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class CoachCarouselSliderSection extends StatefulWidget {
  const CoachCarouselSliderSection({this.contentForCarousel, this.introductionCompleted, this.introductionVideo});
  final List<Widget> contentForCarousel;
  final String introductionVideo;
  final bool introductionCompleted;

  @override
  _CoachCarouselSliderSectionState createState() => _CoachCarouselSliderSectionState();
}

class _CoachCarouselSliderSectionState extends State<CoachCarouselSliderSection> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      width: MediaQuery.of(context).size.width,
      height: 270,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: widget.contentForCarousel.isNotEmpty
                ? CarouselSlider(
                    items: widget.contentForCarousel,
                    options: CarouselOptions(
                        height: 250.0,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayCurve: Curves.easeInExpo,
                        autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                        autoPlayInterval: const Duration(seconds: 5),
                        enlargeCenterPage: true),
                  )
                : const SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}
