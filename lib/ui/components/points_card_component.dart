import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:oluko_app/models/points_card.dart';

import 'package:oluko_app/constants/theme.dart';

class PointsCardComponent extends StatefulWidget {
  final PointsCard pointsCard;

  PointsCardComponent({this.pointsCard});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<PointsCardComponent> {
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return _isOpen ? _openCard() : _closedCard();
  }

  Widget _closedCard() {
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        image: DecorationImage(fit: BoxFit.cover, image: widget.pointsCard.image != null ? CachedNetworkImageProvider(widget.pointsCard.image) : defaultImage),
      )),
      Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Column(children: [_infoIcon(), const Expanded(child: SizedBox()), _bottomSection()]))
    ]);
  }

  Widget _openCard() {
    return Stack(children: [
      Container(decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(10)), color: OlukoColors.grayColor)),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: Text(
                widget.pointsCard.name,
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700),
                textAlign: TextAlign.left,
              )),
              _closeIcon()
            ]),
            Padding(
              padding: EdgeInsets.only(right: 25),
              child: SingleChildScrollView(child: Html(data: widget.pointsCard.description)),
            )
          ]))
    ]);
  }

  Widget _infoIcon() {
    return GestureDetector(
        onTap: () => setState(() {
              _isOpen = !_isOpen;
            }),
        child: Row(children: [
          Expanded(child: SizedBox()),
          Padding(padding: EdgeInsets.only(right: 7), child: Icon(Icons.info_outline_rounded, size: 25, color: OlukoColors.primary))
        ]));
  }

  Widget _closeIcon() {
    return GestureDetector(
        onTap: () => setState(() {
              _isOpen = !_isOpen;
            }),
        child: const Icon(Icons.close, size: 25, color: OlukoColors.primary));
  }

  Widget _bottomSection() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Column(
          children: [
            Row(children: [
              _cardTag(OlukoColors.skyblue, widget.pointsCard.value.toString() + 'XP points'),
              Expanded(child: SizedBox()),
              _cardTag(OlukoColors.strongYellow, '3 cards')
            ]),
            SizedBox(height: 5),
            Text(
              widget.pointsCard.name,
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            )
          ],
        ));
  }

  Widget _cardTag(Color backgroundColor, String text) {
    return Container(
        alignment: Alignment.center,
        height: 17,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: backgroundColor),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              text,
              style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.black, customFontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            )));
  }
}
