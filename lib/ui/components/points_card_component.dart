import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:oluko_app/models/collected_card.dart';

import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class PointsCardComponent extends StatefulWidget {
  final CollectedCard collectedCard;
  bool bigCard;

  PointsCardComponent({this.collectedCard, this.bigCard = false});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<PointsCardComponent> {
  final ImageProvider defaultImage = const AssetImage('assets/collage_logos/19.png');
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return _isOpen ? _openCard() : _closedCard();
  }

  Widget _closedCard() {
    return CachedNetworkImage(
        imageUrl: widget.collectedCard.card.image,
        imageBuilder: (context, imageProvider) => Stack(children: [
              Container(
                  decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              )),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7), child: Column(children: [_infoIcon(), const Expanded(child: SizedBox()), _bottomSection()]))
            ]));
  }

  Widget _openCard() {
    return DecoratedBox(
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoColors.black),
        child: Stack(children: [
          Align(alignment: AlignmentDirectional.topEnd, child: Padding(padding: const EdgeInsets.only(top: 8, right: 6), child: _closeButton())),
          Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10, right: 25),
              child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_getTitle(), _getDescription()]))),
        ]));
  }

  Widget _getTitle() {
    return Padding(
        padding: const EdgeInsets.only(left: 7),
        child: Text(
          widget.collectedCard.card.name,
          style: widget.bigCard
              ? OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700)
              : OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700),
          textAlign: TextAlign.left,
        ));
  }

  Widget _getDescription() {
    return Html(data: widget.collectedCard.card.description, style: {
      'body': Style(color: OlukoColors.white, fontSize: FontSize(14.0)),
    });
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
              _cardTag(OlukoColors.skyblue, widget.collectedCard.card.value.toString() + 'XP points'),
              const Expanded(child: SizedBox()),
              widget.collectedCard.multiplicity != null
                  ? _cardTag(OlukoColors.strongYellow, widget.collectedCard.multiplicity.toString() + ' cards')
                  : const SizedBox()
            ]),
            const SizedBox(height: 5),
            Text(
              widget.collectedCard.card.name,
              style: !widget.bigCard
                  ? ScreenUtils.smallScreen(context)
                      ? OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700)
                      : OlukoFonts.olukoBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700)
                  : OlukoFonts.olukoSuperBigFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: widget.bigCard ? 16 : 5),
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
                  ? OlukoFonts.olukoSmallFont(customColor: OlukoColors.black, customFontWeight: FontWeight.w500)
                  : ScreenUtils.smallScreen(context)
                      ? OlukoFonts.olukoSuperSmallFont(customColor: OlukoColors.black, customFontWeight: FontWeight.w500)
                      : OlukoFonts.olukoSmallFont(customColor: OlukoColors.black, customFontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            )));
  }
}
