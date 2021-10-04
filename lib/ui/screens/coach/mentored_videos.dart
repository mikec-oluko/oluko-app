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

    super.initState();
  }

  @override
  void dispose() {
    setState(() {
      content = [];
      filteredContent = [];
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
                            ? const Icon(Icons.sort, color: OlukoColors.white)
                            : const Icon(Icons.sort, color: OlukoColors.grayColor),
                        onPressed: () {
                          setState(() {
                            isContentFilteredByDate ? isContentFilteredByDate = false : isContentFilteredByDate = true;
                            isContentFilteredByDate
                                ? filteredContent.sort((a, b) => a.createdAt.toDate().compareTo(b.createdAt.toDate()))
                                : filteredContent.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
                          });
                        }),
                  ),
                  IconButton(
                      icon: Icon(isFavoriteSelected ? Icons.favorite : Icons.favorite_border,
                          color: OlukoColors.grayColor),
                      onPressed: () {
                        setState(() {
                          isFavoriteSelected ? isFavoriteSelected = false : isFavoriteSelected = true;
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
    contentForReturn = Padding(
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
                        Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                          'videoUrl': coachAnnotation.video.url,
                          'titleForView': OlukoLocalizations.get(context, 'mentoredVideos')
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
    return contentForReturn;
  }

  ImageProvider getImage(Annotation coachAnnotation) {
    return coachAnnotation.video.thumbUrl != null
        ? NetworkImage(coachAnnotation.video.thumbUrl)
        : AssetImage("assets/home/mvt.png") as ImageProvider;
  }
}
