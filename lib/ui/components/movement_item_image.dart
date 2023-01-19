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
    final _sizeBasedOnRadius = maxRadius * 2;
    const ImageProvider defaultImage = AssetImage('assets/home/mvtthumbnail.png');
    return Neumorphic(
      style: referenceMovementsSection
          ? OlukoNeumorphism.getNeumorphicStyleForCircleElementNegativeDepth()
          : OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
      child: CachedNetworkImage(
        width: _sizeBasedOnRadius ?? 50,
        height: _sizeBasedOnRadius ?? 50,
        maxWidthDiskCache: maxRadius != null ? (_sizeBasedOnRadius * 2.5).toInt() : 100,
        maxHeightDiskCache: maxRadius != null ? (_sizeBasedOnRadius * 2.5).toInt() : 100,
        fit: BoxFit.cover,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
          maxRadius: maxRadius ?? 30,
        ),
        imageUrl: imageUrl,
      ),
    );
  }
}
