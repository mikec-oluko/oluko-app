import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/ui/components/course_card.dart';
import 'package:oluko_app/utils/image_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ChallengeCoursesPanelContent extends StatefulWidget {
  final List<Movement> movements;
  final Segment segment;
  final Function(BuildContext, Movement) onPressedMovement;
  final Widget action;

  ChallengeCoursesPanelContent({this.segment, this.movements, this.onPressedMovement, this.action});

  @override
  _State createState() => _State();
}

class _State extends State<ChallengeCoursesPanelContent> {
  List<Movement> segmentMovements;

  @override
  Widget build(BuildContext context) {
    return Container(
        // padding: EdgeInsets.only(left: 18),
        decoration: OlukoNeumorphism.isNeumorphismDesign
            ? BoxDecoration(
                color: OlukoNeumorphismColors.olukoNeumorphicBackgroundLigth,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)))
            : decorationImage(),
        child: Column(children: [
          SizedBox(height: OlukoNeumorphism.isNeumorphismDesign ? 5 : 15),
          !OlukoNeumorphism.isNeumorphismDesign
              ? SizedBox.shrink()
              : Center(
                  child: Container(
                    width: 50,
                    child: Image.asset('assets/courses/horizontal_vector.png', scale: 2, color: OlukoColors.grayColor),
                  ),
                ),
          _content()
        ]));
  }

    Padding getCourseCards(BuildContext context, Course course) {
    return Padding(
      padding: const EdgeInsets.only(right: OlukoNeumorphism.isNeumorphismDesign ? 12 : 8.0),
      child: GestureDetector(
        onTap: () {},
        child: _getCourseCard(_generateImageCourse(course.image), width: ScreenUtils.width(context) /*/ (padding + _cardsToShow())*/),
      ),
    );
  }

  Widget _getCourseCard(Image image, {double progress, double width, double height, List<String> userRecommendationsAvatarUrls}) {
    return CourseCard(
        width: width, height: height, imageCover: image, progress: progress, userRecommendationsAvatarUrls: userRecommendationsAvatarUrls);
  }

    Image _generateImageCourse(String imageUrl) {
    if (imageUrl != null) {
      return Image(
        image: CachedNetworkImageProvider(imageUrl),
        fit: BoxFit.cover,
        frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) =>
            ImageUtils.frameBuilder(context, child, frame, wasSynchronouslyLoaded, height: 120),
      );
    }
    return Image.asset("assets/courses/course_sample_7.png");
  }

  Widget _content() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          Text(OlukoLocalizations.of(context).find('cousesPanelText'),
              textAlign: TextAlign.left, style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w600, customColor: OlukoColors.white))
        ]));
  }

  BoxDecoration decorationImage() {
    return BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/courses/gray_background.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)));
  }
}
