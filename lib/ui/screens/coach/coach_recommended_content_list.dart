import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/recommendation_media.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachRecommendedContentList extends StatefulWidget {
  const CoachRecommendedContentList({this.recommendedVideoContent, this.recommendedContent, this.titleForAppBar});
  final List<RecommendationMedia> recommendedVideoContent;
  final List<CoachRecommendationDefault> recommendedContent;
  final String titleForAppBar;

  @override
  _CoachRecommendedContentListState createState() => _CoachRecommendedContentListState();
}

class _CoachRecommendedContentListState extends State<CoachRecommendedContentList> {
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.titleForAppBar,
            style: OlukoNeumorphism.isNeumorphismDesign
                ? OlukoFonts.olukoTitleFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w400)
                : OlukoFonts.olukoTitleFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
          ),
          actions: [],
          elevation: 0.0,
          backgroundColor: OlukoNeumorphismColors.appBackgroundColor,
          leading: OlukoNeumorphism.isNeumorphismDesign
              ? Neumorphic(
                  style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
        ),
        body: Container(
          width: ScreenUtils.width(context),
          height: ScreenUtils.height(context),
          color: OlukoNeumorphismColors.appBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ListView(
              shrinkWrap: true,
              children: widget.recommendedContent != null && widget.recommendedContent.isNotEmpty
                  ? getRecommendedContentByType(widget.recommendedContent)
                  : widget.recommendedVideoContent != null && widget.recommendedVideoContent.isNotEmpty
                      ? getRecommendedContentForVideo(widget.recommendedVideoContent)
                      : [const SizedBox.shrink()],
            ),
          ),
        ));
  }

  List<Widget> getRecommendedContentByType(List<CoachRecommendationDefault> recommendedContent) {
    List<Widget> recommendedContentListOfWidgets = [];
    if (recommendedContent.length ==
        recommendedContent
            .where(
              (contentRecommended) =>
                  contentRecommended.contentType == TimelineInteractionType.movement,
            )
            .length) {
      recommendedContent.forEach((movementRecommended) {
        //TODO: WIDGET FOR MOVEMENTS
        recommendedContentListOfWidgets.add(recommendedContentForCard(
          movementRecommended,
          TimelineInteractionType.movement,
        ));
      });
    } else if (recommendedContent.length ==
        recommendedContent
            .where(
              (contentRecommended) =>
                  contentRecommended.contentType == TimelineInteractionType.course,
            )
            .length) {
      recommendedContent.forEach((recommendedCourses) {
        recommendedContentListOfWidgets.add(recommendedContentForCard(
          recommendedCourses,
          TimelineInteractionType.course,
        ));
      });
    }
    return recommendedContentListOfWidgets;
  }

  Padding recommendedContentForCard(CoachRecommendationDefault contentRecommended, TimelineInteractionType recommendationType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () {
          if (recommendationType == TimelineInteractionType.course) {
            return Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                arguments: {'course': contentRecommended.courseContent, 'fromCoach': true, 'isCoachRecommendation': false});
          }
          if (recommendationType == TimelineInteractionType.movement) {
            return Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro],
                arguments: {'movement': contentRecommended.movementContent});
          }
        },
        child: Container(
            height: 180,
            width: ScreenUtils.width(context),
            decoration: UserInformationBackground.getContainerGradientDecoration(
                customBorder: false, isNeumorphic: OlukoNeumorphism.isNeumorphismDesign, useGradient: true),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            width: 150,
                            height: 170,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                  image: contentRecommended.contentImage != null
                                      ? CachedNetworkImageProvider(contentRecommended.contentImage)
                                      : defaultImage,
                                  fit: BoxFit.cover,
                                )),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                            width: ScreenUtils.width(context) / 2.1,
                            height: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: recommendationType == TimelineInteractionType.movement
                                  ? informationForMovement(contentRecommended.contentTitle)
                                  : informationForCourse(contentRecommended.contentTitle,
                                      contentRecommended.courseContent?.classes?.length.toString(), contentRecommended.contentDescription),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }

  List<Widget> informationForMovement(String movementTitle) => [
        getTitleCardWidget(OlukoLocalizations.of(context).find('notificationMovement')),
        getRecommendationTitleWidget(movementTitle),
      ];

  List<Widget> informationForCourse(String courseTitle, String classes, String duration) => [
        getTitleCardWidget(OlukoLocalizations.of(context).find('course')),
        getRecommendationTitleWidget(courseTitle),
        getTitleCardWidget(OlukoLocalizations.of(context).find('classes')),
        getRecommendationTitleWidget(classes),
        getTitleCardWidget(OlukoLocalizations.of(context).find('duration')),
        getRecommendationTitleWidget(duration + addDurationUnit()),
      ];

  List<Widget> getRecommendedContentForVideo(List<RecommendationMedia> recommendedVideoContent) => recommendedVideoContent
      .map(
        (videoRecommended) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            height: 180,
            width: ScreenUtils.width(context),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                  image:
                      videoRecommended.video.thumbUrl != null ? CachedNetworkImageProvider(videoRecommended.video.thumbUrl) : defaultImage,
                  fit: BoxFit.cover,
                )),
            child: Stack(
              children: [
                Align(
                  child: SizedBox(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                        'videoUrl': videoRecommended.video.url,
                        'aspectRatio': videoRecommended.video.aspectRatio,
                        'titleForContent': OlukoLocalizations.of(context).find('recommendedVideos')
                      });
                    },
                    child: OlukoNeumorphism.isNeumorphismDesign
                        ? Container(
                            width: 50,
                            height: 50,
                            child: OlukoBlurredButton(
                                childContent:
                                    Image.asset('assets/courses/play_arrow.png', height: 5, width: 5, scale: 4, color: OlukoColors.white)),
                          )
                        : Image.asset(
                            'assets/self_recording/play_button.png',
                            color: Colors.white,
                            height: 40,
                            width: 40,
                          ),
                  )),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: OlukoColors.blackColorSemiTransparent,
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (OlukoNeumorphism.isNeumorphismDesign)
                            Text(
                              DateFormat.yMMMd().format(videoRecommended.createdAt.toDate()),
                              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w700),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  OlukoLocalizations.get(context, 'date'),
                                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  DateFormat.yMMMd().format(videoRecommended.createdAt.toDate()),
                                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      )
      .toList();
  //TODO: RETURN FOR EACH VIDEO STYLE WIDGET

  Widget getTitleCardWidget(String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text('$value:', style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500)),
      );

  Widget getRecommendationTitleWidget(String value) =>
      Text(value, style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500));

  String addDurationUnit() => ' ${OlukoLocalizations.of(context).find('weeks')}';
}
