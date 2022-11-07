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
    const ImageProvider defaultImage = AssetImage('assets/home/mvtthumbnail.png');
    return Neumorphic(
      style: referenceMovementsSection
          ? OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth()
          : OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
      child: CircleAvatar(
        backgroundImage: imageUrl == null ? defaultImage : CachedNetworkImageProvider(imageUrl),
        maxRadius: maxRadius ?? 30,
      ),
    );
  }
}
