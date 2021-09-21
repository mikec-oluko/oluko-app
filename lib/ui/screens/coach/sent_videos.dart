import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class SentVideosPage extends StatefulWidget {
  final List<MovementSubmission> taskSubmissions;
  const SentVideosPage({this.taskSubmissions});

  @override
  _SentVideosPageState createState() => _SentVideosPageState();
}

class _SentVideosPageState extends State<SentVideosPage> {
  List<MovementSubmission> content = [];
  List<MovementSubmission> orderContent;

  @override
  void initState() {
    setState(() {
      content = widget.taskSubmissions;
    });

    super.initState();
  }

  @override
  void dispose() {
    setState(() {
      content = [];
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          OlukoLocalizations.of(context).find('sentVideos'),
          style: OlukoFonts.olukoTitleFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
        ),
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: IconButton(
                    icon: Icon(Icons.sort, color: OlukoColors.grayColor),
                    onPressed: () {
                      setState(() {
                        content.sort((a, b) => a.createdAt.toDate().compareTo(b.createdAt.toDate()));
                      });
                    }),
              ),
              IconButton(
                  icon: Icon(Icons.favorite_border, color: OlukoColors.grayColor),
                  onPressed: () {
                    //sort List items favorite = true;
                  }),
            ],
          )
        ],
        elevation: 0.0,
        backgroundColor: OlukoColors.black,
        leading: IconButton(
          icon: Icon(
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
        child: ListView(children: segmentCard(taskSubmissions: content)),
      ),
    );
  }

  List<Widget> segmentCard({List<MovementSubmission> taskSubmissions}) {
    List<Widget> contentForSection = [];

    taskSubmissions.forEach((taskSubmitted) {
      contentForSection.add(returnCardForSegment(taskSubmitted));
    });

    return contentForSection;
  }

  Widget returnCardForSegment(MovementSubmission taskSubmitted) {
    //TODO: repeated code 1 from Mentored Video
    Widget contentForReturn = const SizedBox();
    contentForReturn = Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Container(
          decoration: BoxDecoration(
              color: OlukoColors.listGrayColor,
              borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              image: DecorationImage(
                image: getImage(taskSubmitted),
                fit: BoxFit.fitWidth,
              )),
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: Stack(
            children: [
              Align(
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                          'videoUrl': taskSubmitted.video.url,
                          'titleForView': OlukoLocalizations.of(context).find('sentVideos')
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
                                OlukoLocalizations.of(context).find('date'),
                                style: OlukoFonts.olukoMediumFont(
                                    customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                DateFormat.yMMMd().format(taskSubmitted.createdAt.toDate()),
                                style: OlukoFonts.olukoMediumFont(
                                    customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          IconButton(icon: Icon(Icons.favorite, color: OlukoColors.white), onPressed: () {})
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

  ImageProvider getImage(MovementSubmission taskSubmitted) {
    return taskSubmitted.video.thumbUrl != null
        ? NetworkImage(taskSubmitted.video.thumbUrl)
        : AssetImage('assets/home/mvt.png') as ImageProvider;
  }
}
