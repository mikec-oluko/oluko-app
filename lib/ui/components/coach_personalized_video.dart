import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_video_message_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_personalized_video.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachPersonalizedVideoComponent extends StatefulWidget {
  final CoachPersonalizedVideo personalizedVideo;
  final UserResponse currentUser;
  final Annotation annotation;
  const CoachPersonalizedVideoComponent({@required this.personalizedVideo, @required this.currentUser, this.annotation}) : super();

  @override
  State<CoachPersonalizedVideoComponent> createState() => _CoachPersonalizedVideoComponentState();
}

const String _defaultIntroductionVideoId = 'introVideo';

class _CoachPersonalizedVideoComponentState extends State<CoachPersonalizedVideoComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
            color: OlukoColors.listGrayColor,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            image: DecorationImage(
              image: getImage(widget.personalizedVideo),
              fit: BoxFit.fitWidth,
              onError: (exception, stackTrace) {
                return Text('Your error widget...');
              },
            )),
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: Stack(
          children: [Align(child: _playButtonComponent(context)), Align(alignment: Alignment.bottomCenter, child: _carcContentText(context))],
        ),
      ),
    );
  }

  Container _carcContentText(BuildContext context) {
    return Container(
      color: OlukoColors.blackColorSemiTransparent,
      width: MediaQuery.of(context).size.width,
      height: 45,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (OlukoNeumorphism.isNeumorphismDesign)
                  Text(
                    DateFormat.yMMMd().format(widget.personalizedVideo.createdAt.toDate()),
                    style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.lightOrange, customFontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        OlukoLocalizations.get(context, 'date'),
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        DateFormat.yMMMd().format(widget.personalizedVideo.createdAt.toDate()),
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                SizedBox(
                  width: ScreenUtils.width(context) * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      widget.personalizedVideo.annotationContent.id == _defaultIntroductionVideoId
                          ? OlukoLocalizations.get(context, 'introductionVideo')
                          : widget.personalizedVideo.annotationContent != null
                              ? widget.personalizedVideo.annotationContent.segmentName ?? OlukoLocalizations.get(context, 'voiceAnnotation')
                              : widget.personalizedVideo.videoMessageContent.video.name,
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            _getLikeButton(widget.personalizedVideo)
          ],
        ),
      ),
    );
  }

  TextButton _playButtonComponent(BuildContext context) {
    return TextButton(
        onPressed: () {
          var videoUrl = null;
          if (widget.personalizedVideo.videoHls != null) {
            videoUrl = widget.personalizedVideo.videoHls;
          } else {
            videoUrl = widget.personalizedVideo.videoContent.url;
          }
          Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
            'videoUrl': videoUrl,
            'aspectRatio': widget.personalizedVideo.videoContent.aspectRatio,
            'segmentSubmissionId': widget.annotation?.segmentSubmissionId,
            'currentUser': widget.currentUser,
            'titleForContent': OlukoLocalizations.get(context, 'annotatedVideos')
          });
        },
        child: OlukoNeumorphism.isNeumorphismDesign
            ? Container(
                width: 50,
                height: 50,
                child: OlukoBlurredButton(childContent: Image.asset('assets/courses/play_arrow.png', height: 5, width: 5, scale: 4, color: OlukoColors.white)),
              )
            : Image.asset(
                'assets/self_recording/play_button.png',
                color: Colors.white,
                height: 40,
                width: 40,
              ));
  }

  ImageProvider getImage(CoachPersonalizedVideo personalizedVideo) {
    return personalizedVideo.videoContent.thumbUrl != null
        ? CachedNetworkImageProvider(personalizedVideo.videoContent.thumbUrl)
        : AssetImage("assets/home/mvtthumbnail.png") as ImageProvider;
  }

  Widget _getLikeButton(CoachPersonalizedVideo personalizedVideo) {
    bool isFavoriteContent = false;
    if (personalizedVideo.annotationContent != null) {
      isFavoriteContent = personalizedVideo.annotationContent.favorite;
    } else if (personalizedVideo.videoMessageContent != null) {
      isFavoriteContent = personalizedVideo.videoMessageContent.favorite;
    }
    return IconButton(
        icon: OlukoNeumorphism.isNeumorphismDesign
            ? Icon(
                isFavoriteContent ? Icons.favorite : Icons.favorite_outline,
                color: OlukoColors.primary,
                size: 30,
              )
            : Icon(isFavoriteContent ? Icons.favorite : Icons.favorite_outline, color: OlukoColors.white),
        onPressed: () {
          if (personalizedVideo.annotationContent != null) {
            BlocProvider.of<CoachMentoredVideosBloc>(context).updateCoachAnnotationFavoriteValue(
              coachAnnotation: personalizedVideo.annotationContent,
            );
          } else if (personalizedVideo.videoMessageContent != null) {
            BlocProvider.of<CoachVideoMessageBloc>(context).markVideoMessageAsFavorite(widget.currentUser.id, personalizedVideo.videoMessageContent);
          }
        });
  }

  String getContentTitle(CoachPersonalizedVideo personalizedVideo) {
    const String defaultIntroductionVideoId = 'introVideo';
    String titleForVideoContent = 'MVT Video';
    if (personalizedVideo.annotationContent != null) {
      if (personalizedVideo.annotationContent.segmentName != null) {
        titleForVideoContent = personalizedVideo.annotationContent?.segmentName;
      }
      if (personalizedVideo.annotationContent.id == defaultIntroductionVideoId) {
        titleForVideoContent = OlukoLocalizations.get(context, 'introductionVideo');
      }
    } else if (personalizedVideo.videoMessageContent != null) {
      if (personalizedVideo.videoMessageContent.video.name != null) {
        titleForVideoContent = personalizedVideo.videoMessageContent.video.name;
      }
    }
    return titleForVideoContent;
  }
}
