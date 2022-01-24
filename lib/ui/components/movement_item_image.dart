import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class MovementItem extends StatelessWidget {
  final double maxRadius;
  String imageUrl;
  bool referenceMovementsSection;
  MovementItem({Key key, this.maxRadius, this.imageUrl, this.referenceMovementsSection = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Neumorphic(
        style: referenceMovementsSection
            ? OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth()
            : OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
        child: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(imageUrl),
          maxRadius: maxRadius ?? 30,
        ),
      );
    }
  }
}
