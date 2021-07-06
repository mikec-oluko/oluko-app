import 'package:flutter/material.dart';

class StoriesItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final double maxRadius;

  StoriesItem({this.imageUrl, this.name, this.maxRadius = 35});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StoriesItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.imageUrl),
          maxRadius: widget.maxRadius,
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            widget.name,
            style: TextStyle(color: Colors.white60),
          ),
        )
      ],
    );
  }
}
