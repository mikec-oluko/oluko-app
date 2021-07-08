import 'package:flutter/material.dart';
import 'package:mvt_fitness/constants/theme.dart';
import 'package:mvt_fitness/ui/components/black_app_bar.dart';
import 'package:mvt_fitness/ui/components/dialog.dart';
import 'package:mvt_fitness/ui/components/image_and_video_container.dart';
import 'package:mvt_fitness/ui/components/image_and_video_preview_card.dart';
import 'package:mvt_fitness/ui/components/oluko_outlined_button.dart';
import 'package:mvt_fitness/ui/components/transformation_journey_modal_options.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_constants.dart';
import 'package:mvt_fitness/ui/screens/profile/profile_routes.dart';
import 'package:mvt_fitness/ui/screens/profile/transformation_journey_post.dart';
import 'package:mvt_fitness/utils/oluko_localizations.dart';

class ProfileTransformationJourneyPage extends StatefulWidget {
  @override
  _ProfileTransformationJourneyPageState createState() =>
      _ProfileTransformationJourneyPageState();
}

class _ProfileTransformationJourneyPageState
    extends State<ProfileTransformationJourneyPage> {
  List<Widget> _contentGallery;
  String _titleForContent;

  Widget _getImageAndVideoCard(String assetImage, {bool isVideo}) {
    return ImageAndVideoContainer(
      assetImage: assetImage,
      isVideo: isVideo,
    );
  }

  List<Widget> buildContentGallery({List<Content> uploadListContent}) {
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

  String getTitleForContent({List<Content> uploadListContent}) {
    int _videos = 0;
    int _images = 0;
    uploadListContent
        .forEach((content) => content.isVideo ? _videos += 1 : _images += 1);
    return "Uploaded $_images Images & $_videos Videos";
  }

  @override
  void initState() {
    setState(() {
      _contentGallery =
          buildContentGallery(uploadListContent: uploadListContent);
      _titleForContent =
          getTitleForContent(uploadListContent: uploadListContent);
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
                          child: OlukoOutlinedButton(
                              title: OlukoLocalizations.of(context)
                                  .find('tapToUpload'),
                              onPressed: () =>
                                  ProfileViewConstants.dialogContent(
                                      context: context,
                                      content: [
                                        TransformationJourneyOptions()
                                      ])),
                        )))),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 100, 10, 0),
              child: Align(
                  alignment: Alignment.topLeft,
                  child:
                      Text(_titleForContent, style: OlukoFonts.olukoBigFont())),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 150, 10, 0),
              child: GridView.count(
                crossAxisCount: 3,
                children: _contentGallery,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
