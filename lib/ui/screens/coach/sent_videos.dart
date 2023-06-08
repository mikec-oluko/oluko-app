import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/blocs/coach/coach_sent_videos_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class SentVideosPage extends StatefulWidget {
  final List<SegmentSubmission> segmentSubmissions;
  const SentVideosPage({this.segmentSubmissions});

  @override
  _SentVideosPageState createState() => _SentVideosPageState();
}

class _SentVideosPageState extends State<SentVideosPage> {
  List<SegmentSubmission> content = [];
  List<SegmentSubmission> filteredContent;
  bool isFavoriteSelected = false;
  bool isContentFilteredByDate = false;
  @override
  void initState() {
    setState(() {
      content.addAll(widget.segmentSubmissions);
      filteredContent = content;
    });
    contentSortedByDate();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachSentVideosBloc, CoachSentVideosState>(
      builder: (context, state) {
        if (state is CoachSentVideosSuccess) {
          content = state.sentVideos.where((sentVideo) => sentVideo?.video != null)?.toList();
        }
        return Scaffold(
          backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
          appBar: OlukoAppBar(
            showTitle: true,
            showActions: true,
            title: OlukoLocalizations.get(context, 'sentVideos'),
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
                              : filteredContent = widget.segmentSubmissions;
                        });
                        //sort List items favorite = true;
                      }),
                ],
              )
            ],
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            color: OlukoNeumorphismColors.appBackgroundColor,
            child: ListView(addAutomaticKeepAlives: false, addRepaintBoundaries: false, children: segmentCard(segmentSubmissions: filteredContent)),
          ),
        );
      },
    );
  }

  void contentSortedByDate() {
    isContentFilteredByDate
        ? filteredContent.sort((a, b) => a.createdAt.toDate().compareTo(b.createdAt.toDate()))
        : filteredContent.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
  }

  List<Widget> segmentCard({List<SegmentSubmission> segmentSubmissions}) {
    List<Widget> contentForSection = [];

    segmentSubmissions.forEach((segmentSubmitted) {
      contentForSection.add(returnCardForSegment(segmentSubmitted));
    });

    return contentForSection;
  }

  Widget returnCardForSegment(SegmentSubmission segmentSubmitted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
            color: OlukoColors.listGrayColor,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            image: DecorationImage(
              image: getImage(segmentSubmitted),
              fit: BoxFit.fitWidth,
            )),
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: Stack(
          children: [
            Align(
                child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        routeLabels[RouteEnum.coachShowVideo],
                        arguments: {
                          'aspectRatio': segmentSubmitted.video.aspectRatio,
                          'videoUrl': segmentSubmitted.video.url,
                          'titleForContent': OlukoLocalizations.get(context, 'sentVideos')
                        },
                      );
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
                      Row(
                        children: [
                          _getDateWidget(segmentSubmitted),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              segmentSubmitted.segmentName ?? '',
                              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: OlukoNeumorphism.isNeumorphismDesign
                            ? Icon(
                                segmentSubmitted.favorite ? Icons.favorite : Icons.favorite_outline,
                                color: OlukoColors.primary,
                                size: 30,
                              )
                            : Icon(segmentSubmitted.favorite ? Icons.favorite : Icons.favorite_outline, color: OlukoColors.white),
                        onPressed: () {
                          BlocProvider.of<CoachSentVideosBloc>(context)
                              .updateSegmentSubmissionFavoriteValue(segmentSubmitted: segmentSubmitted, currentSentVideosContent: content);
                        },
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ImageProvider getImage(SegmentSubmission segmentSubmitted) {
    return segmentSubmitted.video.thumbUrl != null
        ? CachedNetworkImageProvider(segmentSubmitted.video.thumbUrl)
        : const AssetImage(OlukoNeumorphism.mvtLogo) as ImageProvider;
  }

  Widget _getDateWidget(SegmentSubmission segmentSubmitted) {
    if (OlukoNeumorphism.isNeumorphismDesign) {
      return Text(
        DateFormat.yMMMd().format(segmentSubmitted.createdAt.toDate()),
        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.lightOrange, customFontWeight: FontWeight.w700),
      );
    } else {
      return Column(
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
            DateFormat.yMMMd().format(segmentSubmitted.createdAt.toDate()),
            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
          ),
        ],
      );
    }
  }
}
