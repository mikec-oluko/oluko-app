import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class CoachContentSectionCard extends StatefulWidget {
  final String title;
  final bool needTitle;

  const CoachContentSectionCard({this.title, this.needTitle = true});

  @override
  _CoachContentSectionCardState createState() => _CoachContentSectionCardState();
}

class _CoachContentSectionCardState extends State<CoachContentSectionCard> {
  final ImageProvider _defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  final _filterForDefaultImage = true;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500),
                    )
                  : const SizedBox(),
            ),
            Padding(
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: OlukoColors.blackColorSemiTransparent,
                      image: DecorationImage(
                        colorFilter: _filterForDefaultImage ? ColorFilter.mode(Colors.black.withOpacity(0.15), BlendMode.dstATop) : null,
                        image: _defaultImage,
                        fit: BoxFit.fill,
                      )),
                  width: 150,
                  height: 100,
                ))
          ],
        )
      ],
    );
  }
}
