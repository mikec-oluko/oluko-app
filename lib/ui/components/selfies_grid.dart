import 'package:flutter/material.dart';
import 'package:oluko_app/utils/collage_utils.dart';

class SelfiesGrid extends StatefulWidget {
  final List<String> images;

  const SelfiesGrid({
    this.images,
    Key key,
  }) : super(key: key);

  @override
  _SelfiesGridState createState() => _SelfiesGridState();
}

class _SelfiesGridState extends State<SelfiesGrid> {
  @override
  Widget build(BuildContext context) {
    return gridSection();
  }

  Widget gridSection() {
    return GridView.count(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 1,
      crossAxisCount: 6,
      children: CollageUtils.getCollageWidgets(widget.images, 70), //70 items
    );
  }
}
