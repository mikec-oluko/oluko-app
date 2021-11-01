import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachNotificationVideoCard extends StatefulWidget {
  const CoachNotificationVideoCard({this.cardImage, this.fileType});
  final String cardImage;
  final CoachFileTypeEnum fileType;

  @override
  _CoachNotificationVideoCardState createState() => _CoachNotificationVideoCardState();
}

class _CoachNotificationVideoCardState extends State<CoachNotificationVideoCard> {
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');

  bool isVisible = true;
  @override
  void initState() {
    setState(() {
      isVisible = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(headerForCard(widget.fileType),
                  overflow: TextOverflow.ellipsis,
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
            ),
            Container(
              height: 190,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(
                    image: widget.cardImage != null ? NetworkImage(widget.cardImage) : defaultImage,
                    fit: BoxFit.cover,
                  )),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                        iconSize: 32,
                        onPressed: () {
                          setState(() {
                            //TODO: Add logic to update notification state
                            isVisible = !isVisible;
                          });
                        },
                        icon: const Icon(Icons.close, color: OlukoColors.grayColor)),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                        iconSize: 64,
                        onPressed: () {
                          setState(() {
                            //TODO: Add logic to update notification state
                            isVisible = !isVisible;
                          });
                        },
                        icon: const Icon(Icons.play_circle_fill_outlined, color: OlukoColors.grayColor)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String headerForCard(CoachFileTypeEnum fileType) {
    switch (fileType) {
      case CoachFileTypeEnum.mentoredVideo:
        return OlukoLocalizations.of(context).find('mentoredVideo');

      default:
    }
  }
}
