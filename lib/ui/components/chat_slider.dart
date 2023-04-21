import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/audio_bloc.dart';
import 'package:oluko_app/blocs/chat_slider_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:badges/badges.dart';

class ChatSlider extends StatefulWidget {
  final List<CourseEnrollment> courseList;
  final String currentUserId;

  const ChatSlider({this.courseList, this.currentUserId});

  @override
  _ChatSliderState createState() => _ChatSliderState();
}

class _ChatSliderState extends State<ChatSlider> {
  List<int> messageQuantityList = [];

  @override
  void initState() {
    BlocProvider.of<ChatSliderBloc>(context).getMessagesAfterLast(widget.currentUserId, widget.courseList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatSliderBloc, ChatSliderState>(builder: (context, chatSliderState) {
      if (chatSliderState is GetQuantityOfMessagesAfterLast) {
        messageQuantityList = chatSliderState.messageQuantityList;
        return widget.courseList.isEmpty ? _noCoursesMessage(context) : _courseList(widget.courseList, messageQuantityList, context);
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

Widget _courseList(List<CourseEnrollment> courses, List<int> msgQuantity, BuildContext context) {
  return ListView(
    scrollDirection: Axis.horizontal,
    children: courses
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  routeLabels[RouteEnum.courseChat],
                  arguments: {
                    'courseEnrollment': element,
                  },
                );
              },
              child: courseCard(element.course.image, element.course.name, msgQuantity[index], context),
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
  //TODO: fill space with default image or message
}
