import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/models/points_card.dart';

class PointsCardComponent extends StatefulWidget {
  final PointsCard pointsCard;
  final bool isOpen;

  PointsCardComponent({this.isOpen = false, this.pointsCard});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<PointsCardComponent> {
  final ImageProvider defaultImage = const AssetImage('assets/home/mvtthumbnail.png');
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          //color: Colors.black,
        ),
        child: widget.isOpen ? _openCard() : _openCard());
  }

  Widget _openCard() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        height: 160,
        width: 115,
        decoration: BoxDecoration(
          image:
              DecorationImage(fit: BoxFit.cover, image: widget.pointsCard.image != null ? CachedNetworkImageProvider(widget.pointsCard.image) : defaultImage),
        ),
      ),
    );
  }
}
