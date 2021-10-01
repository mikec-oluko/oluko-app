import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachContentSectionCard extends StatefulWidget {
  final String title;
  final bool needTitle;
  final bool isForCarousel;
  const CoachContentSectionCard({this.title, this.needTitle = true, this.isForCarousel});

  @override
  _CoachContentSectionCardState createState() => _CoachContentSectionCardState();
}

class _CoachContentSectionCardState extends State<CoachContentSectionCard> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: widget.needTitle
                  ? Text(
                      widget.title,
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500),
                    )
                  : SizedBox(),
            ),
            Padding(
              padding: widget.isForCarousel ? const EdgeInsets.all(0) : const EdgeInsets.all(0.0),
              child: !widget.isForCarousel
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: OlukoColors.blackColorSemiTransparent,
                      ),
                      width: 150,
                      height: 100,
                      child: Center(
                        child: Text(
                          OlukoLocalizations.get(context, 'noContent'),
                          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  : Wrap(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: OlukoColors.blackColorSemiTransparent,
                          ),
                          width: 200,
                          height: 150,
                          child: Center(
                            child: Text(
                              OlukoLocalizations.get(context, 'noContent'),
                              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.primary, custoFontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
            )
          ],
        )
      ],
    );
  }
}
