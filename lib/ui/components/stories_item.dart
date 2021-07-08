import 'package:flutter/material.dart';

class StoriesItem extends StatefulWidget {
  final String imageUrl;
  final String name;

  StoriesItem({this.imageUrl, this.name});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StoriesItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.imageUrl),
          maxRadius: 35,
          minRadius: 15,
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
