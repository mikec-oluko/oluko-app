import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_get_header_for_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_blue_title_header.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachNotificationCard extends StatefulWidget {
  const CoachNotificationCard(
      {this.cardTitle,
      this.cardSubTitle,
      this.cardDescription,
      this.cardImage,
      this.date,
      this.fileType,
      this.onCloseCard,
      this.onOpenCard});
  final String cardTitle, cardSubTitle, cardImage, cardDescription;
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
                child: OlukoNeumorphism.isNeumorphismDesign
                    ? OlukoBlueHeader(textContent: headerForCard(widget.fileType))
                    : Text(headerForCard(widget.fileType),
                        overflow: TextOverflow.ellipsis,
                        style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
              ),
              Expanded(
                child: Container(
                  decoration: UserInformationBackground.getContainerGradientDecoration(
                      customBorder: false, isNeumorphic: OlukoNeumorphism.isNeumorphismDesign, useGradient: true),
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
                                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                                  child: widget.cardImage != null
                                      ? Container(
                                          width: 150,
                                          height: 180,
                                          decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              image: DecorationImage(
                                                image: CachedNetworkImageProvider(widget.cardImage),
                                                fit: BoxFit.cover,
                                              )),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: -10,
                                                left: -10,
                                                child: IconButton(
                                                    iconSize: 24,
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
                                        )
                                      : Container(
                                          width: 140,
                                          height: 170,
                                          decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(5)), color: OlukoColors.randomColor()),
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
                                              ),
                                              Align(
                                                child: Text(headerForCard(widget.fileType),
                                                    overflow: TextOverflow.ellipsis,
                                                    style: OlukoFonts.olukoSmallFont(
                                                        customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                                              )
                                            ],
                                          ),
                                        ),
                                )
                              ],
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(CoachHeders.getContentHeader(context: context, fileType: widget.fileType),
                                        style: OlukoFonts.olukoMediumFont(
                                            customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500)),
                                    Text(widget.cardTitle,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                                    const SizedBox(height: 10),
                                    Text(
                                        widget.fileType == CoachFileTypeEnum.recommendedClass
                                            ? OlukoLocalizations.of(context).find('timelineCourse')
                                            : widget.fileType == CoachFileTypeEnum.recommendedCourse
                                                ? OlukoLocalizations.of(context).find('classes')
                                                : widget.fileType == CoachFileTypeEnum.recommendedMovement
                                                    ? ''
                                                    : widget.fileType == CoachFileTypeEnum.recommendedSegment
                                                        ? OlukoLocalizations.of(context).find('class')
                                                        : '',
                                        style: OlukoFonts.olukoMediumFont(
                                            customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500)),
                                    Text(widget.cardSubTitle,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                                    if (widget.fileType == CoachFileTypeEnum.recommendedCourse)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              widget.fileType == CoachFileTypeEnum.recommendedCourse && widget.cardDescription != null
                                                  ? OlukoLocalizations.of(context).find('duration')
                                                  : '',
                                              style: OlukoFonts.olukoMediumFont(
                                                  customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500)),
                                          Text(
                                              widget.fileType == CoachFileTypeEnum.recommendedCourse && widget.cardDescription != null
                                                  ? widget.cardDescription.contains(',')
                                                      ? widget.cardDescription.split(',')[0]
                                                      : widget.cardDescription
                                                  : '',
                                              overflow: TextOverflow.ellipsis,
                                              style: OlukoFonts.olukoMediumFont(
                                                  customColor: OlukoColors.white, custoFontWeight: FontWeight.w500))
                                        ],
                                      )
                                    else
                                      const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
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
    return '';
  }
}
