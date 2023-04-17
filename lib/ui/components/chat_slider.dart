import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ChatSlider extends StatefulWidget {
  final List<CourseEnrollment> courses;
  const ChatSlider({this.courses});

  @override
  _ChatSliderState createState() => _ChatSliderState();
}

class _ChatSliderState extends State<ChatSlider> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: widget.courses
          .map(
            (element) => GestureDetector(
              onTap: () => null,
              child: courseCard(element.course.image, element.course.name, context),
            ),
          )
          .toList(),
    );
  }
}

Widget courseCard(String image, String name, BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(left: 20),
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
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
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
  return Image.asset("assets/courses/course_sample_7.png");
  //TODO: fill space with default image or message
}
