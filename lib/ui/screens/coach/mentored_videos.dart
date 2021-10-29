import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/annotations.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
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
      content = widget.coachAnnotation;
      filteredContent = widget.coachAnnotation;
    });
    contentSortedByDate();
    super.initState();
  }

  @override
  void dispose() {
    setState(() {
      content = [];
      filteredContent = [];
      isFavoriteSelected = false;
      isContentFilteredByDate = false;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachMentoredVideosBloc, CoachMentoredVideosState>(
      builder: (context, state) {
        if (state is CoachMentoredVideosSuccess) {
          content = state.mentoredVideos;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              OlukoLocalizations.get(context, 'mentoredVideos'),
              style: OlukoFonts.olukoTitleFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
            ),
            actions: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: IconButton(
                        icon: isContentFilteredByDate
                            ? Image.asset(
                                'assets/courses/vector.png',
                                color: Colors.white,
                                height: 20,
                                width: 20,
                              )
                            : Image.asset(
                                'assets/courses/vector.png',
                                color: Colors.grey,
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
                      icon: Icon(isFavoriteSelected ? Icons.favorite : Icons.favorite_border,
                          color: OlukoColors.grayColor),
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
    Widget contentForReturn = const SizedBox();
    return contentForReturn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          decoration: BoxDecoration(
              color: OlukoColors.listGrayColor,
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
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
                  alignment: Alignment.center,
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
                      child: Image.asset(
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
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                OlukoLocalizations.get(context, 'date'),
                                style: OlukoFonts.olukoMediumFont(
                                    customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                DateFormat.yMMMd().format(coachAnnotation.createdAt.toDate()),
                                style: OlukoFonts.olukoMediumFont(
                                    customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          IconButton(
                              icon: Icon(coachAnnotation.favorite ? Icons.favorite : Icons.favorite_outline,
                                  color: OlukoColors.white),
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
      ),
    );
  }

  ImageProvider getImage(Annotation coachAnnotation) {
    return coachAnnotation.video.thumbUrl != null
        ? NetworkImage(coachAnnotation.video.thumbUrl)
        : AssetImage("assets/home/mvtthumbnail.png") as ImageProvider;
  }

  void contentSortedByDate() {
    isContentFilteredByDate
        ? filteredContent.sort((a, b) => a.createdAt.toDate().compareTo(b.createdAt.toDate()))
        : filteredContent.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
  }
}
