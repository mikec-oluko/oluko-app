import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class StoriesItem extends StatefulWidget {
  final String imageUrl;
  final String name;
  final double maxRadius;
  final double progressValue;

  const StoriesItem({this.imageUrl, this.name, this.maxRadius = 35, this.progressValue = 0});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<StoriesItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Positioned(
              bottom: 0,
              top: 0,
              left: 0,
              right: 0,
              child: CircularProgressIndicator(
                value: widget.progressValue,
                strokeWidth: 5,
                valueColor: const AlwaysStoppedAnimation<Color>(OlukoColors.primary),
              ),
            ),
            if (widget.imageUrl != null) CircleAvatar(
                    backgroundImage: NetworkImage(widget.imageUrl),
                    maxRadius: widget.maxRadius,
                  ) else CircleAvatar(
                    maxRadius: widget.maxRadius,
                    child: const Icon(Icons.error),
                  ),
          ],
        ),
        if (widget.name != null) Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  widget.name,
                  style: const TextStyle(color: Colors.white60),
                ),
              ) else const SizedBox()
      ],
    );
  }
}
