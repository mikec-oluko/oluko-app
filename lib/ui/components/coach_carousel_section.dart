import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/screen_utils.dart';

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

  int _current = 0;
  final CarouselController _controller = CarouselController();

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
                ? Wrap(children: [
                    CarouselSlider(
                      carouselController: _controller,
                      items: widget.contentForCarousel,
                      options: CarouselOptions(
                          height: 240.0,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          autoPlayCurve: Curves.easeInExpo,
                          autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                          autoPlayInterval: const Duration(seconds: 5),
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }),
                    ),
                    Center(
                      child: Container(
                        height: 25,
                        constraints: BoxConstraints(minHeight: 25, minWidth: 10, maxWidth: ScreenUtils.width(context) / 3, maxHeight: 25),
                        // color: Colors.red,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.contentForCarousel
                              .map((item) => _current == widget.contentForCarousel.indexOf(item)
                                  ? Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Image.asset(
                                          'assets/self_recording/outlined_circle_cam.png',
                                        ),
                                        Image.asset(
                                          'assets/self_recording/white_circle_cam.png',
                                        ),
                                      ],
                                    )
                                  : Image.asset(
                                      'assets/self_recording/white_circle_cam.png',
                                    ))
                              .toList(),
                        ),
                      ),
                    )
                  ])
                : const SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}
