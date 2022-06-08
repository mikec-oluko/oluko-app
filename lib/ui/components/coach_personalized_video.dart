import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_personalized_video.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/models/coach_media_message.dart';

class CoachPersonalizedVideoComponent extends StatefulWidget {
  final CoachPersonalizedVideo personalizedVideo;
  const CoachPersonalizedVideoComponent({@required this.personalizedVideo}) : super();

  @override
  State<CoachPersonalizedVideoComponent> createState() => _CoachPersonalizedVideoComponentState();
}

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
          children: [
            Align(
                child: TextButton(
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
                        'titleForContent': OlukoLocalizations.get(context, 'personalizedVideos')
                      });
                    },
                    child: OlukoNeumorphism.isNeumorphismDesign
                        ? SizedBox(
                            width: 70,
                            height: 70,
                            child: OlukoBlurredButton(
                              childContent: Image.asset(
                                'assets/self_recording/white_play_arrow.png',
                                color: Colors.white,
                                height: 50,
                                width: 50,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/self_recording/play_button.png',
                            color: Colors.white,
                            height: 40,
                            width: 40,
                          ))),
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
                            DateFormat.yMMMd().format(widget.personalizedVideo.createdAt.toDate()),
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
                                DateFormat.yMMMd().format(widget.personalizedVideo.createdAt.toDate()),
                                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        // IconButton(
                        //     icon: OlukoNeumorphism.isNeumorphismDesign
                        //         ? Icon(
                        //             coachAnnotation.favorite ? Icons.favorite : Icons.favorite_outline,
                        //             color: OlukoColors.primary,
                        //             size: 30,
                        //           )
                        //         : Icon(coachAnnotation.favorite ? Icons.favorite : Icons.favorite_outline, color: OlukoColors.white),
                        //     onPressed: () {
                        //       BlocProvider.of<CoachMentoredVideosBloc>(context).updateCoachAnnotationFavoriteValue(
                        //         coachAnnotation: coachAnnotation,
                        //         currentMentoredVideosContent: Set.from(content),
                        //       );
                        //     })
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  ImageProvider getImage(CoachPersonalizedVideo personalizedVideo) {
    return personalizedVideo.videoContent.thumbUrl != null
        ? CachedNetworkImageProvider(personalizedVideo.videoContent.thumbUrl)
        : AssetImage("assets/home/mvtthumbnail.png") as ImageProvider;
  }
}
