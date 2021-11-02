import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_get_header_for_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachNotificationCard extends StatefulWidget {
  const CoachNotificationCard(
      {this.cardTitle, this.cardSubTitle, this.cardImage, this.date, this.fileType, this.onCloseCard, this.onOpenCard});
  final String cardTitle, cardSubTitle, cardImage;
  final DateTime date;
  final CoachFileTypeEnum fileType;
  final Function() onCloseCard;
  final Function() onOpenCard;

  @override
  _CoachNotificationCardState createState() => _CoachNotificationCardState();
}

class _CoachNotificationCardState extends State<CoachNotificationCard> {
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
        // height: 200,
        child: GestureDetector(
          onTap: widget.onOpenCard ?? () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(headerForCard(widget.fileType),
                    overflow: TextOverflow.ellipsis,
                    style:
                        OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
              ),
              Container(
                decoration: ContainerGradient.getContainerGradientDecoration(customBorder: true),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Container(
                                  width: 140,
                                  height: 170,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                                      image: DecorationImage(
                                        image: NetworkImage(widget.cardImage),
                                        fit: BoxFit.cover,
                                      )),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: -10,
                                        left: -10,
                                        child: IconButton(
                                            iconSize: 32,
                                            onPressed: widget.onCloseCard ??
                                                () {
                                                  setState(() {
                                                    isVisible = !isVisible;
                                                  });
                                                },
                                            icon: const Icon(Icons.close, color: OlukoColors.grayColor)),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(CoachHeders.getContentHeader(context: context, fileType: widget.fileType),
                                        style: OlukoFonts.olukoMediumFont(
                                            customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500)),
                                    Text(widget.cardTitle,
                                        overflow: TextOverflow.ellipsis,
                                        style: OlukoFonts.olukoMediumFont(
                                            customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                                    const SizedBox(height: 10),
                                    Text(
                                        widget.fileType == CoachFileTypeEnum.recommendedClass
                                            ? OlukoLocalizations.of(context).find('timelineCourse')
                                            : widget.fileType == CoachFileTypeEnum.recommendedCourse
                                                ? OlukoLocalizations.of(context).find('classes')
                                                : '',
                                        style: OlukoFonts.olukoMediumFont(
                                            customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500)),
                                    Text(widget.cardSubTitle,
                                        overflow: TextOverflow.ellipsis,
                                        style: OlukoFonts.olukoMediumFont(
                                            customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String headerForCard(CoachFileTypeEnum fileType) {
    switch (fileType) {
      case CoachFileTypeEnum.recommendedClass:
        return OlukoLocalizations.get(context, 'notificationClass');
      case CoachFileTypeEnum.recommendedCourse:
        return OlukoLocalizations.get(context, 'notificationCourse');

      case CoachFileTypeEnum.recommendedMovement:
        return OlukoLocalizations.get(context, 'notificationMovement');

      case CoachFileTypeEnum.recommendedSegment:
        return OlukoLocalizations.get(context, 'notificationSegment');

      default:
    }
  }
}
