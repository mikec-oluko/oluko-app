import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(
    this.minHeight,
    this.maxHeight, {
    @required this.child,
  });
  double minHeight;
  double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    
    return SizedBox.expand(child: child);
  }
  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
  
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }
}
