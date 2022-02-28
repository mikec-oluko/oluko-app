import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_media_bloc.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';

import '../../../routes.dart';

class AboutCoachPage extends StatefulWidget {
  // final CoachUser coachUser;
  // const AboutCoachPage({this.coachUser});
  const AboutCoachPage();

  @override
  _AboutCoachPageState createState() => _AboutCoachPageState();
}

class _AboutCoachPageState extends State<AboutCoachPage> {
  List<CoachMedia> coachUploadedContent = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<CoachMediaBloc, CoachMediaState>(
        builder: (context, state) {
          if (state is CoachMediaContentUpdate) {
            coachUploadedContent = state.coachMediaContent;
          }
          if (state is CoachMediaContentSuccess) {
            coachUploadedContent = state.coachMediaContent;
          }
          return Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  child: CarouselSmallSection(
                    routeToGo: RouteEnum.aboutCoach,
                    title: '',
                    children: coachUploadedContent
                        .map((mediaContent) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: ImageAndVideoContainer(
                                  backgroundImage: mediaContent.video.thumbUrl,
                                  isContentVideo: true,
                                  videoUrl: mediaContent.video.url,
                                  displayOnViewNamed: ActualProfileRoute.transformationJourney,
                                  originalContent: mediaContent,
                                  isCoachMediaContent: true),
                            ))
                        .toList(),
                  )),
            ),
          );
        },
      ),
    );
  }
}
