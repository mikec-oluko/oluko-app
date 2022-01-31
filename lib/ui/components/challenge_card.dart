import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChallengeCard extends StatefulWidget {
  final String image;

  ChallengeCard({this.image});

  @override
  _State createState() => _State();
}

class _State extends State<ChallengeCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          child: CachedNetworkImage(
            imageUrl: widget.image,
            height: 140,
            width: 100,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
        Image.asset(
          'assets/courses/locked_challenge.png',
          width: 60,
          height: 60,
        )
      ],
    );
  }
}
