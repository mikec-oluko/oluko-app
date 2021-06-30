import 'package:flutter/material.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/image_and_video_preview_card.dart';
import 'package:oluko_app/ui/components/oluko_outlined_button.dart';
import 'package:oluko_app/ui/screens/profile/profile_constants.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ProfileTransformationJourneyPage extends StatefulWidget {
  @override
  _ProfileTransformationJourneyPageState createState() =>
      _ProfileTransformationJourneyPageState();
}

class _ProfileTransformationJourneyPageState
    extends State<ProfileTransformationJourneyPage> {
  List<Widget> widgetsToUse;
  String titleForContent;

  List<Content> _uploadListContent = [
    Content(imgUrl: 'assets/courses/course_sample_3.png', isVideo: true),
    Content(imgUrl: 'assets/courses/course_sample_5.png', isVideo: true),
    Content(imgUrl: 'assets/courses/course_sample_4.png', isVideo: true),
    Content(imgUrl: 'assets/courses/course_sample_6.png', isVideo: false),
    Content(imgUrl: 'assets/courses/course_sample_7.png', isVideo: false),
    Content(imgUrl: 'assets/courses/course_sample_8.png', isVideo: false),
  ];

  Widget _getImageAndVideoCard(String assetImage, {bool isVideo}) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        height: 120,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: OlukoColors.black,
        ),
        child: ImageAndVideoPreviewCard(
          imageCover: Image.asset(
            assetImage,
            fit: BoxFit.fill,
            height: 120,
            width: 120,
          ),
          isVideo: isVideo,
        ),
      ),
    );
  }

  List<Widget> buildPageContent({List<Content> uploadListContent}) {
    List<Widget> widgetListOfContentTempt = [];

    uploadListContent.forEach((content) => {
          content.isVideo
              ? widgetListOfContentTempt.add(_getImageAndVideoCard(
                  content.imgUrl,
                  isVideo: content.isVideo))
              : widgetListOfContentTempt.add(_getImageAndVideoCard(
                  content.imgUrl,
                  isVideo: content.isVideo))
        });
    return widgetListOfContentTempt;
  }

  String buildPageTitleContent({List<Content> uploadListContent}) {
    int videos = 0;
    int images = 0;
    uploadListContent
        .forEach((content) => {content.isVideo ? videos += 1 : images += 1});
    return "Uploaded  $images Images & $videos Videos";
  }

  @override
  void initState() {
    setState(() {
      widgetsToUse = buildPageContent(uploadListContent: _uploadListContent);
      titleForContent =
          buildPageTitleContent(uploadListContent: _uploadListContent);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        title: ProfileViewConstants.profileOptionsTransformationJourney,
        showSearchBar: false,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        color: OlukoColors.black,
        child: SafeArea(
          child: Stack(children: [
            Align(
                alignment: Alignment.topCenter,
                child: Expanded(
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: OlukoOutlinedButton(title: "Tap to Upload"),
                        )))),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 100, 10, 0),
              child: Align(
                  alignment: Alignment.topLeft,
                  child:
                      Text(titleForContent, style: OlukoFonts.olukoBigFont())),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 150, 10, 0),
              child: GridView.count(
                crossAxisCount: 3,
                children: widgetsToUse,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
