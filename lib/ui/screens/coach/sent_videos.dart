import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class SentVideosPage extends StatefulWidget {
  final List<TaskSubmission> taskSubmissions;
  const SentVideosPage({this.taskSubmissions});

  @override
  _SentVideosPageState createState() => _SentVideosPageState();
}

class _SentVideosPageState extends State<SentVideosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          OlukoLocalizations.of(context).find('sentVideos'),
          style: OlukoFonts.olukoTitleFont(
              customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
        ),
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: IconButton(
                    icon: Icon(Icons.sort, color: OlukoColors.grayColor),
                    onPressed: () {}),
              ),
              IconButton(
                  icon:
                      Icon(Icons.favorite_border, color: OlukoColors.grayColor),
                  onPressed: () {}),
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
        child: ListView(
            children: segmentCard(taskSubmissions: widget.taskSubmissions)),
      ),
    );
  }

  segmentCard({List<TaskSubmission> taskSubmissions}) {
    List<Widget> contentForSection = [];

    taskSubmissions.forEach((taskSubmitted) {
      contentForSection.add(returnCardForSegment(taskSubmitted));
    });

    return contentForSection;
  }

  returnCardForSegment(TaskSubmission taskSubmitted) {
    //TODO: repeated code 1 from Mentored Video
    Widget contentForReturn = SizedBox();
    contentForReturn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          decoration: BoxDecoration(
              color: OlukoColors.listGrayColor,
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              image: DecorationImage(
                image: taskSubmitted.video.thumbUrl != null
                    ? NetworkImage(taskSubmitted.video.thumbUrl)
                    : AssetImage("assets/home/mvt.png"),
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
                        Navigator.pushNamed(
                            context, routeLabels[RouteEnum.coachShowVideo],
                            arguments: {
                              'videoUrl': taskSubmitted.video.url,
                              'titleForView': OlukoLocalizations.of(context)
                                  .find('sentVideos')
                            });
                      },
                      child: Image.asset(
                        'assets/assessment/play.png',
                        scale: 5,
                      ))),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: OlukoColors.blackColorSemiTransparent,
                    width: MediaQuery.of(context).size.width,
                    height: 70,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                OlukoLocalizations.of(context).find('date'),
                                style: OlukoFonts.olukoMediumFont(
                                    customColor: OlukoColors.grayColor,
                                    custoFontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                DateFormat.yMMMd()
                                    .format(taskSubmitted.createdAt.toDate()),
                                style: OlukoFonts.olukoMediumFont(
                                    customColor: OlukoColors.grayColor,
                                    custoFontWeight: FontWeight.w500),
                              )
                            ],
                          ),
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
}
