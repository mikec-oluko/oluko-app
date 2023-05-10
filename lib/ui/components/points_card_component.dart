import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:oluko_app/models/points_card.dart';

import 'package:oluko_app/constants/theme.dart';

class PointsCardComponent extends StatefulWidget {
  final PointsCard pointsCard;
  bool bigCard;

  PointsCardComponent({this.pointsCard, this.bigCard = false});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<PointsCardComponent> {
  final ImageProvider defaultImage = const AssetImage('assets/collage_logos/19.png');
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return _card();
  }

  Widget _card() {
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
                style: widget.bigCard
                    ? OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700)
                    : OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700),
                textAlign: TextAlign.left,
              )),
              _closeButton()
            ]),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: SingleChildScrollView(child: Html(
                data: widget.pointsCard.description)),
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

  Widget _closeButton() {
    return GestureDetector(
        onTap: () => setState(() {
              _isOpen = !_isOpen;
            }),
        child: _closeIcon());
  }

  Widget _closeIcon() {
    return const Icon(Icons.close, size: 25, color: OlukoColors.primary);
  }

  Widget _bottomSection() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.bigCard ? 20 : 10),
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
              style: !widget.bigCard
                  ? OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700)
                  : OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
          ],
        ));
  }

  Widget _cardTag(Color backgroundColor, String text) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: backgroundColor),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              text,
              style: widget.bigCard
                  ? OlukoFonts.olukoMediumFont(customColor: OlukoColors.black, customFontWeight: FontWeight.w500)
                  : OlukoFonts.olukoSmallFont(customColor: OlukoColors.black, customFontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            )));
  }
}
