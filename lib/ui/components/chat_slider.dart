import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/audio_bloc.dart';
import 'package:oluko_app/blocs/chat_slider_messages_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:badges/badges.dart';
import 'package:badges/badges.dart' as badges;

class ChatSlider extends StatefulWidget {
  final List<CourseEnrollment> enrollments;
  final UserResponse currentUser;

  const ChatSlider({this.enrollments, this.currentUser});

  @override
  _ChatSliderState createState() => _ChatSliderState();
}

class _ChatSliderState extends State<ChatSlider> {
  Map<String, int> coursesNotificationQuantity = {};

  @override
  void initState() {
    BlocProvider.of<ChatSliderMessagesBloc>(context).dispose();
    BlocProvider.of<ChatSliderMessagesBloc>(context).listenToMessages(widget.currentUser.id, enrollments: widget.enrollments);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatSliderMessagesBloc, ChatSliderMessagesState>(builder: (context, chatSliderState) {
      if (chatSliderState is MessagesNotificationUpdated) {
        coursesNotificationQuantity[chatSliderState.courseId] = chatSliderState.quantity;
        return widget.enrollments.isEmpty
            ? _noCoursesMessage(context)
            : _courseList(widget.enrollments, coursesNotificationQuantity, context, widget.currentUser, widget.enrollments);
      } else if (widget.enrollments.isNotEmpty) {
        return _courseList(widget.enrollments, coursesNotificationQuantity, context, widget.currentUser, widget.enrollments);
      }
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: OlukoCircularProgressIndicator(),
      );
    });
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

Widget _courseList(
    List<CourseEnrollment> courses, Map<String, int> coursesNotificationQuantity, BuildContext context, UserResponse currentUser, List<CourseEnrollment> enrollments) {
  return ListView(
    scrollDirection: Axis.horizontal,
    children: courses
        .asMap()
        .map(
          (index, enroll) => MapEntry(
            index,
            GestureDetector(
              onTap: () {
                BlocProvider.of<ChatSliderMessagesBloc>(context).dispose();
                Navigator.pushNamed(
                  context,
                  routeLabels[RouteEnum.courseChat],
                  arguments: {'courseEnrollment': enroll, 'currentUser': currentUser, 'enrollments': enrollments},
                );
              },
              child: courseCard(enroll.course.image, enroll.course.name, coursesNotificationQuantity[enroll.course.id], context),
            ),
          ),
        )
        .values
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
          padding: const EdgeInsets.only(top: 15),
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
          top: 3,
          left: 45,
          child: Visibility(
            visible: msgQuantity != null ? msgQuantity > 0 : false,
            child: badges.Badge(
              badgeContent: Text(
                msgQuantity.toString(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
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
}
