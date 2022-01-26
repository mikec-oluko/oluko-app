import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class MentoredVideosPage extends StatefulWidget {
  final List<Annotation> coachAnnotation;
  const MentoredVideosPage({this.coachAnnotation});

  @override
  _MentoredVideosPageState createState() => _MentoredVideosPageState();
}

class _MentoredVideosPageState extends State<MentoredVideosPage> {
  List<Annotation> content = [];
  List<Annotation> filteredContent;
  bool isFavoriteSelected = false;
  bool isContentFilteredByDate = false;

  @override
  void initState() {
    setState(() {
      content.addAll(widget.coachAnnotation);
      filteredContent = content;
      filteredContent = contentSortedByDate();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachMentoredVideosBloc, CoachMentoredVideosState>(
      builder: (context, state) {
        if (state is CoachMentoredVideosSuccess) {
          state.mentoredVideos.forEach((mentoredVideo) {
            final sameElement = content.where((contentElement) => contentElement.id == mentoredVideo.id).toList();
            if (sameElement.isEmpty) {
              content.insert(0, mentoredVideo);
            }
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              OlukoLocalizations.get(context, 'mentoredVideos'),
              style: OlukoNeumorphism.isNeumorphismDesign
                  ? OlukoFonts.olukoTitleFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w400)
                  : OlukoFonts.olukoTitleFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
            ),
            actions: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: IconButton(
                        icon: OlukoNeumorphism.isNeumorphismDesign
                            ? Image.asset(
                                'assets/courses/vector_neumorphism.png',
                                color: isContentFilteredByDate ? Colors.white : Colors.grey,
                                height: 20,
                                width: 20,
                              )
                            : Image.asset(
                                'assets/courses/vector.png',
                                color: isContentFilteredByDate ? Colors.white : Colors.grey,
                                height: 20,
                                width: 20,
                              ),
                        onPressed: () {
                          setState(() {
                            isContentFilteredByDate = !isContentFilteredByDate;
                            contentSortedByDate();
                          });
                        }),
                  ),
                  IconButton(
                      icon: Icon(isFavoriteSelected ? Icons.favorite : Icons.favorite_border, color: OlukoColors.grayColor),
                      onPressed: () {
                        setState(() {
                          isFavoriteSelected = !isFavoriteSelected;
                          isFavoriteSelected
                              ? filteredContent = content.where((element) => element.favorite == true).toList()
                              : filteredContent = widget.coachAnnotation;
                        });
                        //sort List items favorite = true;
                      }),
                ],
              )
            ],
            elevation: 0.0,
            backgroundColor: OlukoColors.black,
            leading: IconButton(
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
            width: MediaQuery.of(context).size.width,
            color: OlukoColors.black,
            child: ListView(children: segmentCard(coachAnnotation: filteredContent)),
          ),
        );
      },
    );
  }

  List<Widget> segmentCard({List<Annotation> coachAnnotation}) {
    List<Widget> contentForSection = [];

    coachAnnotation.forEach((annotation) {
      contentForSection.add(returnCardForSegment(annotation));
    });

    return contentForSection;
  }

  Widget returnCardForSegment(Annotation coachAnnotation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
            color: OlukoColors.listGrayColor,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            image: DecorationImage(
              image: getImage(coachAnnotation),
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
                      if (coachAnnotation.videoHLS != null) {
                        videoUrl = coachAnnotation.videoHLS;
                      } else {
                        videoUrl = coachAnnotation.video.url;
                      }
                      Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                        'videoUrl': videoUrl,
                        'aspectRatio': coachAnnotation.video.aspectRatio,
                        // 'videoUrl': "https://oluko-development.s3.us-west-1.amazonaws.com/annotations/5uqbLM8I44MeGgEdtH1G/master.m3u8",
                        // 'videoUrl': "https://oluko-development.s3.us-west-1.amazonaws.com/04ZUOE5pWwPlVtBsE47q/master.m3u8",
                        // 'videoUrl': "https://oluko-development.s3.us-west-1.amazonaws.com/annotations/5uqbLM8I44MeGgEdtH1G/video.webm"
                        'titleForContent': OlukoLocalizations.get(context, 'mentoredVideos')
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
                            DateFormat.yMMMd().format(coachAnnotation.createdAt.toDate()),
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
                                DateFormat.yMMMd().format(coachAnnotation.createdAt.toDate()),
                                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        IconButton(
                            icon: OlukoNeumorphism.isNeumorphismDesign
                                ? Icon(
                                    coachAnnotation.favorite ? Icons.favorite : Icons.favorite_outline,
                                    color: OlukoColors.primary,
                                    size: 30,
                                  )
                                : Icon(coachAnnotation.favorite ? Icons.favorite : Icons.favorite_outline, color: OlukoColors.white),
                            onPressed: () {
                              BlocProvider.of<CoachMentoredVideosBloc>(context).updateCoachAnnotationFavoriteValue(
                                  coachAnnotation: coachAnnotation, currentMentoredVideosContent: content);
                            })
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  ImageProvider getImage(Annotation coachAnnotation) {
    return coachAnnotation.video.thumbUrl != null
        ? NetworkImage(coachAnnotation.video.thumbUrl)
        : AssetImage("assets/home/mvtthumbnail.png") as ImageProvider;
  }

  List<Annotation> contentSortedByDate() {
    isContentFilteredByDate
        ? filteredContent.sort((a, b) => a.createdAt.toDate().compareTo(b.createdAt.toDate()))
        : filteredContent.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
    return filteredContent;
  }
}
