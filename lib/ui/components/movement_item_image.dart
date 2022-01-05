import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';

class MovementItem extends StatelessWidget {
  final double maxRadius;
  String imageUrl;
  MovementItem({Key key, this.maxRadius, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Neumorphic(
              style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
              child: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                maxRadius: maxRadius ?? 30,
              ),
            );
          
    } 
    }
}

