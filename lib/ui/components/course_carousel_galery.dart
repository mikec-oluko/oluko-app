import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/three_dots_menu.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseCarouselGallery extends StatefulWidget {
  final List<CourseEnrollment> courseEnrollments;
  final int courseIndex;
  final Function(int) onCourseChange;
  final Function(int) onCourseDeleted;
  final Function(int) onCourseTap;

  const CourseCarouselGallery(
      {Key key, @required this.courseEnrollments, this.courseIndex, @required this.onCourseChange, @required this.onCourseDeleted, this.onCourseTap})
      : super(key: key);

  @override
  _CourseCarouselGalleryState createState() => _CourseCarouselGalleryState();
}

class _CourseCarouselGalleryState extends State<CourseCarouselGallery> {
  List<Widget> items = [];

  @override
  Widget build(BuildContext context) {
    items = buildCourseCards(widget.courseIndex ?? 0);
    return CarouselSlider(
      items: items,
      options: CarouselOptions(
        height: ScreenUtils.height(context) * 0.42,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        viewportFraction: 0.65,
        initialPage: widget.courseIndex ?? 0,
        onPageChanged: (index, reason) {
          widget.onCourseChange(index);
        },
      ),
    );
  }

  List<Widget> buildCourseCards(int selected) {
    final List<Widget> classCards = [];
    for (var i = 0; i < widget.courseEnrollments.length; i++) {
      classCards.add(SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.courseEnrollments[i].course.image != null)
                GestureDetector(
                  onTap: () {
                    if (widget.onCourseTap != null) {
                      widget.onCourseTap(selected);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: CachedNetworkImageProvider(widget.courseEnrollments[i].course.image),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Center(
                        child: Container(
                      width: ScreenUtils.width(context) / 3,
                      height: ScreenUtils.height(context) / 15,
                      // color: Colors.red,
                      child: OlukoBlurredButton(
                        childContent: Center(
                          child: Text(
                            OlukoLocalizations.of(context).find('goToClass'),
                            style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    )),
                  ),
                )
              else
                const SizedBox(),
              Positioned(
                top: 0,
                right: 0,
                child: ThreeDotsMenu(
                  actualCourse: widget.courseEnrollments[selected],
                  unrolledFunction: () => widget.onCourseDeleted(i),
                ),
              )
            ],
          ),
        ),
      ));
    }
    return classCards;
  }
}
