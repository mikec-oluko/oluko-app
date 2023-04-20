import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:badges/badges.dart';

class ChatSlider extends StatefulWidget {
  final List<CourseEnrollment> courses;
  final int messageQuantity;

  const ChatSlider({this.courses, this.messageQuantity});

  @override
  _ChatSliderState createState() => _ChatSliderState();
}

class _ChatSliderState extends State<ChatSlider> {
  @override
  Widget build(BuildContext context) {
    return widget.courses.isEmpty ? _noCoursesMessage(context) : _courseList(widget.courses, widget.messageQuantity, context);
  }
}

Padding _noCoursesMessage(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          OlukoLocalizations.get(context, 'noCourses'),
          style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w400, customColor: OlukoColors.grayColor),
        )
      ],
    ),
  );
}

Widget _courseList(List<CourseEnrollment> courses, int msgQuantity, BuildContext context) {
  return ListView(
    scrollDirection: Axis.horizontal,
    children: courses
        .map(
          (element) => GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                routeLabels[RouteEnum.courseChat],
                arguments: {
                  'courseEnrollment': element,
                },
              );
            },
            child: courseCard(element.course.image, element.course.name, msgQuantity, context),
          ),
        )
        .toList(),
  );
}

Widget courseCard(String image, String name, int msgQuantity, BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(left: 16),
    width: 80,
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: generateImageCourse(image, context),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                constraints: const BoxConstraints(
                  maxWidth: 80,
                ),
                child: Text(
                  name,
                  textWidthBasis: TextWidthBasis.parent,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -3,
          left: 50,
          child: Visibility(
            visible: msgQuantity > 0,
            child: Badge(
              badgeContent: Text(
                msgQuantity.toString(),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              badgeColor: Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget generateImageCourse(String imageUrl, BuildContext context) {
  if (imageUrl != null) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 60,
      height: 80,
      maxWidthDiskCache: (ScreenUtils.width(context) * 0.5).toInt(),
      maxHeightDiskCache: (ScreenUtils.height(context) * 0.5).toInt(),
      memCacheWidth: (ScreenUtils.width(context) * 0.5).toInt(),
      memCacheHeight: (ScreenUtils.height(context) * 0.5).toInt(),
      fit: BoxFit.fill,
    );
  }
  return Image.asset('assets/courses/course_sample_7.png');
  //TODO: fill space with default image or message
}
